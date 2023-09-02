/**
 * @description Calls ESBEndpointMDMStudent when contact is inserted/updated
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | February 14, 2023     | DEPP-5040    | Created file                                | 
      |                           |                       |              |                                             | 
 */
public with sharing class ContactTriggerMDMIntegration implements Database.AllowsCallouts {

    private static final String ENDPOINT_ESB_MDM_STUDENT = System.Label.ESBEndpointMDMStudent;

    /**
     * Sends request to ESB Endpoint and creates log if http response is non 200
     * @param List of Contact
     */
    public static void logMDMStudents(List<Contact> newContacts){
        Integration_Settings__c integrationSettings = Integration_Settings__c.getOrgDefaults();  
        if(integrationSettings.Allow_ESB_Integration__c && Userinfo.getName() != 'ESB Integration User'){
            List<Contact> contactToUse = new List<Contact>();
            for(Contact contact : newContacts){
                Contact contactToAdd = new Contact();
                contactToAdd.Id = contact.Id;
                contactToAdd.QUT_Identity_ID__c = contact.QUT_Identity_ID__c;
                contactToAdd.Salutation = contact.Salutation;
                contactToAdd.FirstName = contact.FirstName;
                contactToAdd.MiddleName = contact.MiddleName;
                contactToAdd.LastName = contact.LastName;
                contactToAdd.Preferred_Given_Name__c = contact.Preferred_Given_Name__c;
                contactToAdd.Birthdate = contact.Birthdate;
                contactToAdd.ATSI_Code__c = contact.ATSI_Code__c;
                contactToAdd.hed__Citizenship__c = contact.hed__Citizenship__c;
                contactToAdd.hed__Citizenship_Status__c = contact.hed__Citizenship_Status__c;
                contactToAdd.ContactMobile_Validation__c = contact.ContactMobile_Validation__c;
                contactToAdd.ContactMobile_Locale__c = contact.ContactMobile_Locale__c;
                contactToAdd.MobilePhone = contact.MobilePhone;
                contactToAdd.Phone = contact.Phone;
                contactToAdd.OtherStreet = contact.OtherStreet;
                contactToAdd.OtherState = contact.OtherState;
                contactToAdd.OtherPostalCode = contact.OtherPostalCode;
                contactToAdd.OtherCountry = contact.OtherCountry;
                contactToAdd.MailingStreet = contact.MailingStreet;
                contactToAdd.MailingState = contact.MailingState;
                contactToAdd.MailingPostalCode = contact.MailingPostalCode;
                contactToAdd.MailingCountry = contact.MailingCountry;
                contactToAdd.Email = contact.Email;
                contactToAdd.QUT_Learner_Email__c = contact.QUT_Learner_Email__c;
                contactToAdd.Work_Email__c = contact.Work_Email__c;
                contactToAdd.QUT_Employee_ID__c = contact.QUT_Employee_ID__c;
                contactToAdd.QUT_Student_ID__c = contact.QUT_Student_ID__c;
                contactToUse.add(contactToAdd);
            }
            if(!contactToUse.isEmpty()){ 
                doCallout(contactToUse);     
            } 
        }
    }
    
    private static void doCallout(List<Contact> contacts) {
        HTTPResponse httpResponse;
        try{
            String endpoint = 'callout:ESB' + ENDPOINT_ESB_MDM_STUDENT;
            httpResponse = IntegrationCallOutCtrl.doCallout(endpoint, 'POST', JSON.serialize(contacts));
            if(httpResponse.getStatusCode() != 200){
               Logger.error('Callout Exception on Inserting/Updating Contact ').setHttpResponseDetails(httpResponse);
            }

        }catch(Exception e){
            Logger.error('Callout Exception on Inserting/Updating Contact ').setExceptionDetails(e).setHttpResponseDetails(httpResponse);
        } finally {
            Logger.saveLog();
        }
    }
}