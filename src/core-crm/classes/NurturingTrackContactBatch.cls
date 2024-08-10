/**
 * @description Batch class for NurturingTrackContactBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | mark.j.mahilum                 | July 23, 2023         | DEPP-6105              | Created file                                          |
      | arsenio.jr.dayrit              | September 08, 2023    | DEPP-5652              | Added field in Contact Query                          |
 */
public class NurturingTrackContactBatch implements Database.Batchable<sObject> {

    /**
     * @description 
     * @param BatchableContext
     * @return query - filtered query records
     */
     public Database.QueryLocator start(Database.BatchableContext bc){
         String queryFilter =  'SELECT Id, Can_Nurture__c, Lead_Score__c, Citizenship_Country__c, Lead_Source_Category__c, Calculated_Cadence__c, hed__Citizenship_Status__c, HasOptedOutOfEmail, Marketing_Segmentation__r.My_Primary_Study_Level__c ' + 
                               'FROM Contact ' + 
                               'WHERE Can_Nurture__c = TRUE ' +
                               'OR Calculated_Cadence__c !=NULL ';
         return Database.getQueryLocator(queryFilter);
     }
 
    /**
     * @description Method to execute the batch
     * @param bc - BatchableContext
     * @param 
     */
     public void execute(Database.BatchableContext bc, List<Contact> contactList){
         try{
             Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
             //process entry and exit criteria logic
             List<Contact> updateContactList = NurturingTrackContactService.processContactForEntryAndExit(contactMap);
             
             //Update Contact record
             if(!updateContactList.isEmpty()){
                 ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
             }
             
         }catch(Exception e){
             Logger.error('Exception caught in method execute in Apex class NurturingTrackContactBatch.').setExceptionDetails(e);
         } finally {
             if(Logger.getBufferSize() > 0) {
                 Logger.saveLog();
             }
         }      
     } 
 
     public void finish(Database.BatchableContext bc) {}//NOPMD
 }