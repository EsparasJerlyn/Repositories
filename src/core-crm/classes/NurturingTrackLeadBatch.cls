/**
 * @description Batch class for NurturingTrackLeadBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                      |
      |--------------------------------|-----------------------|------------------------|-------------------------------------|
      | mark.j.mahilum                 | July 23, 2023         | DEPP-6105              | Created file                        |
      | arsenio.jr.dayrit              | September 08, 2023    | DEPP-5652              | Added field in Lead Query           |
      | arsenio.jr.dayrit              | October 12, 2023      | DEPP-6901              | Added field in Lead Query filter    |
 */
public class NurturingTrackLeadBatch implements Database.Batchable<sObject> {

   /**
    * @description 
    * @param BatchableContext
    * @return query - filtered query records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryFilter =  'SELECT Id, Can_Nurture__c, Lead_Score__c, Calculated_Cadence__c, Lead_Source_Category__c, HasOptedOutOfEmail, ' +
                              'Marketing_Segmentation__r.My_Citizenship_Status__c, Marketing_Segmentation__r.My_Country_Of_Citizenship__c, Marketing_Segmentation__r.My_Primary_Study_Level__c ' +
                              'FROM Lead ' + 
                              'WHERE (Can_Nurture__c = TRUE ' +
            				  'OR Calculated_Cadence__c !=NULL) ' +
            				  'AND IsConverted = FALSE ' +
                              'AND Marketing_Segmentation__r.My_Citizenship_Status__c !=NULL ';
        return Database.getQueryLocator(queryFilter);
    }

   /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param 
    */
    public void execute(Database.BatchableContext bc, List<Lead> leadList){
        try{
            //all leads
            Map<Id, Lead> leadToProcess = new Map<Id, Lead>(leadList);
            
            //process entry and exit criteria logic
            List<Lead> updateLeadList = NurturingTrackLeadService.processLeadForEntryAndExit(leadToProcess);
            
            //Update Lead record
            if(!updateLeadList.isEmpty()){
                LeadsDAO.newInstance().updateRecords(updateLeadList, false, AccessLevel.SYSTEM_MODE);
            }
            
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class NurturingTrackLeadBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }      
    } 

    public void finish(Database.BatchableContext bc) {}//NOPMD
}