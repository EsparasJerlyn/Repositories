/**
 * @description Adhoc Communication object trigger helper class
 * @see AdhocCommunicationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan	           | October 10, 2023      | DEPP-6612              | Created file                 |
 */
public with sharing class AdhocCommunicationTriggerHelper {
    
    /**
     * @description calls the ManageAdhocCommsSection.sendEmailToRegisteredLearners to send an email when adhoc communication
     * record is created/updated today wherein send date = today and was not included in the batch - every 7am 
     *
     * @param newItems  List of new Adhoc_Communication__c records
     * @param oldItems  Map of old Adhoc_Communication__c records (Id => Adhoc_Communication__c)
     */
     public static void getAdhocCommunicationToSendEmail(List<Adhoc_Communication__c> newItems, Map<Id, Adhoc_Communication__c> oldItems) {
        try{
            List<Adhoc_Communication__c> adhocCommunicationRecords = new List<Adhoc_Communication__c>();

            // Get Adhoc Communication records created or updated where Send Date is today and IsSent is false
            for (Adhoc_Communication__c ac : newItems) {
                if (ac.Send_Date__c != null && Date.valueOf(ac.Send_Date__c) == System.today() && !ac.IsSent__c) {
                    adhocCommunicationRecords.add(ac);
                }
            }
    
            // Send an Email if there are records to process
            if (!adhocCommunicationRecords.isEmpty()) {
                ManageAdhocCommsSectionCtrl.sendEmailToRegisteredLearners(adhocCommunicationRecords);
    
                // Update IsSent Field from False to True
                for (Adhoc_Communication__c acToUpdate : adhocCommunicationRecords) {
                    acToUpdate.IsSent__c = true;
                }
            }
        }catch(Exception e){
            Logger.error('Exception caught in method execute in class AdhocCommunicationsTriggerHelper.').setExceptionDetails(e);
        }finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
}