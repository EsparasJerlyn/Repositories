/**
 * @description Batch class for LeadSourceCanNurtureFlagBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                     |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------------------------|
      | arsenio.jr.dayrit              | March 05, 2024        | DEPP-8069              | Created file                                                                       |
      |                                |                       |                        |                                                                                    | 
      | mark.j.mahilum                 | March 15, 2024        | DEPP-8314              | Added logic for contact can nurture reset after 3 years with no action application |
 */
public with sharing class LeadSourceCanNurtureFlagBatch implements Database.Batchable<sObject>{
    
    private static date afterThreeYears = System.today().addYears(-3);
    private static final String NURTURE_TRACK_PARTNER_SOURCED = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED;
    private static final String PARTNER_SOURCED = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;
    
    /**
    * @description Retrieve scheduled communication queue that is created/last modified by communication automation user
    * @param bc - BatchableContext
    * @return query - filtered query of scheduled communication queue
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryFilter =  'SELECT Id,Lead__c,Lead__r.Calculated_Cadence__c, Lead__r.Lead_Source_Category__c, Lead__r.Can_Nurture__c, CreatedDate, Contact__c ' +
                              'FROM Completed_Cadence__c ' + 
                              'WHERE CreatedDate <: afterThreeYears AND Cadence_Name__c =: NURTURE_TRACK_PARTNER_SOURCED ' +
                              'AND ((Contact__c != NULL AND Contact__r.Can_Nurture__c = TRUE AND Contact__r.Lead_Source_Category__c =: PARTNER_SOURCED) ' +
                              'OR (Lead__c != NULL AND Lead__r.Can_Nurture__c = TRUE AND Lead__r.Lead_Source_Category__c =: PARTNER_SOURCED)) ';
        return Database.getQueryLocator(queryFilter);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param completedCadenceList - List of Completed Cadence
    */
    public void execute(Database.BatchableContext bc, List<Completed_Cadence__c> completedCadenceList){
        try{ 
            
            Set<String> leadOrContactIds = new Set<String>();
            Set<Id> leadsWithApplication = new Set<Id>();
            Set<Id> contactsWithApplication = new Set<Id>();
            Map<Id,Lead> leadListToUpdateMap = new Map<Id,Lead>();
            Map<Id,Contact> contactListToUpdateMap = new Map<Id,Contact>();

            for(Completed_Cadence__c completeCadence : completedCadenceList){
                //get the lead id of completed cadence
                if(String.isNotEmpty(completeCadence.Lead__c)){
                   leadOrContactIds.add(completeCadence.Lead__c); 
                }
                //get the Contact id of completed cadence
                if(String.isNotEmpty(completeCadence.Contact__c)){
                   leadOrContactIds.add(completeCadence.Contact__c);  
                }              
            }
            
            //check if lead or contact is associated with application record
            checkAssociatedActiveApplicationRecords(leadOrContactIds,leadsWithApplication,contactsWithApplication);
            
            for(Completed_Cadence__c completedCadenceToProcess : completedCadenceList){
                //check if the lead is not associated with active application record
                //and if the completed cadences leadId is not blank then set the Can Nurture to false
                if(String.isNotEmpty(completedCadenceToProcess.Lead__c) && !leadsWithApplication.contains(completedCadenceToProcess.Lead__c)){
                    leadListToUpdateMap.put(completedCadenceToProcess.Lead__c,
                    new Lead(
                            id = completedCadenceToProcess.Lead__c,
                            Can_Nurture__c = false
                        )
                    );
                }
                //check if the contact is not associated with active application record
                //and if the completed cadences contactId is not blank then set the Can Nurture to false
                if(String.isNotEmpty(completedCadenceToProcess.Contact__c) && !contactsWithApplication.contains(completedCadenceToProcess.Contact__c)){
                    contactListToUpdateMap.put(completedCadenceToProcess.Contact__c,
                    new Contact(
                            id = completedCadenceToProcess.Contact__c,
                            Can_Nurture__c = false
                        )
                    );
                }
            }
            
            //update contact can nurture flag to false
            updateContactCanNurtureFlag(contactListToUpdateMap.values());
            //update lead can nurture flag to false
            updateLeadCanNurtureFlag(leadListToUpdateMap.values());

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadSourceCanNurtureFlagBatch.').setExceptionDetails(e);
        } 
        finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    /**
    * @description chain current batch job to Complete Cadence job
    * @param bc - BatchableContext
    */
    public void finish(Database.BatchableContext bc) {}//NOPMD
    
   /**
    * @description checkAssociatedActiveApplicationRecords: method to check if contact or lead has active application
    * @param Set<String> leadOrContactIds
    * @param Set<Id> leadsWithApplication
    * @param Set<Id> contactsWithApplication
    */
    private static void checkAssociatedActiveApplicationRecords(
        Set<String> leadOrContactIds,
        Set<Id> leadsWithApplication,
        Set<Id> contactsWithApplication
    ) {
        
        for(hed__Application__c app : ApplicationsDAO.newInstance().getApplicationsByLeadIdOrContactId(leadOrContactIds, 'SYSTEM_MODE')){            
            if(!ApplicationsDAO.STUDYLINK_TERMINAL_STATUSES.contains(app.Application_Status__c)){                   
                if(leadOrContactIds.contains(app.hed__Applicant__c)){
                    contactsWithApplication.add(app.hed__Applicant__c);
                }                    
                if(leadOrContactIds.contains(app.Lead__c)){
                    leadsWithApplication.add(app.Lead__c);
                }
            }
        }
    }
    
    /**
     * @description update contact can nurture flag to false
     * 
     * @param List<Contact> contactRecords - contact records to update
     */
    private static void updateContactCanNurtureFlag(List<Contact> contacts) {
        if(!contacts.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contacts, false, AccessLevel.SYSTEM_MODE);
        }    
    }
    
    /**
     * @description update lead can nurture flag to false
     * 
     * @param List<Lead> leadRecords - lead records to update
     */
    private static void updateLeadCanNurtureFlag(List<Lead> leads) {
        if(!leads.isEmpty()){
            LeadsDAO.newInstance().updateRecords(leads, false, AccessLevel.SYSTEM_MODE);
        }   
    }
}