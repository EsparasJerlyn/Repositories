/**
 * @description Calls ESBEndpointMDMStudent when contact is inserted/updated
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | February 14, 2023     | DEPP-5040    | Created file                                | 
      | eccarius.munoz            | August 12, 2024       | DEPP-10490   | Used platform event                         | 
      |                           |                       |              |                                             | 
 */
public with sharing class ContactTriggerMDMIntegration {

    /**
     * Validate if students will be processed in MDM Integration
     * 
     * @param newContacts List of Contact records to process
     */
    public static void logMDMStudents(List<Contact> newContacts){

        Integration_Settings__c integrationSettings = Integration_Settings__c.getOrgDefaults();  
        if(integrationSettings.Allow_ESB_Integration__c && Userinfo.getName() != 'ESB Integration User'){

            List<MDM_Callout_Event__e> mdmCalloutEventList = new List<MDM_Callout_Event__e>();

            String objectName = Contact.getSObjectType().toString();

            for(Contact contact : newContacts){
                if(contact.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID){
                    mdmCalloutEventList.add(
                        new MDM_Callout_Event__e(
                            Contact_Id__c = contact.Id,
                            Triggering_Record__c = objectName
                        )
                    );
                }
            }

            if(!mdmCalloutEventList.isEmpty()){ 
                try {
                    EventBus.publish(mdmCalloutEventList);
                } catch (Exception e) {
                    // prettier-ignore
                    NebulaLoggerService.logExceptionDetails('Exception caught in validateAddress method.', e);
                }
            } 
        }
    }
    
}