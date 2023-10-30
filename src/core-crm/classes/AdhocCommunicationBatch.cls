/**
 * @description Batch class to send adhoc communication email to registered learners
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | October 06, 2023      | DEPP-6616              | Created file                 |
 */
public with sharing class AdhocCommunicationBatch implements Database.Batchable<sObject>
{

    /**
    * @description Method to query Adhoc Communications
    * @param bc - BatchableContext
    * @return query - filtered query of Adhoc Commmuincation reocrds
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        /**
         * Gets the Adhoc Communication records when send date is today or in the future 
         */
        Date today = Date.today(); //NOPMD Used in string below for dynamic query
        return AdhocCommunicationsDAO.newInstance().getAdhocCommunicationsByDate(today);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param adhocCommunicationsList - List of Adhoc Communications
    */
    public void execute(Database.BatchableContext bc, List<Adhoc_Communication__c> adhocCommunicationsList)
    {
        try{
            Boolean emailResult;
            List<Adhoc_Communication__c> adhocCommunicationsToUpdateList = new List <Adhoc_Communication__c>();
            if(!adhocCommunicationsList.isEmpty()){
                //Call the method that will send an email
                emailResult = ManageAdhocCommsSectionCtrl.sendEmailToRegisteredLearners(adhocCommunicationsList);
               
                for(Adhoc_Communication__c adhocCommunication : adhocCommunicationsList){
                    if(adhocCommunication.IsSent__c == false){
                        adhocCommunication.IsSent__c = true;
                        adhocCommunicationsToUpdateList.add(adhocCommunication);
                    }
                }
            }
            // Update Adhoc Communication IsSent field to True once the email has been sent
            if(!adhocCommunicationsToUpdateList.isEmpty() && emailResult == true){
                AdhocCommunicationsDAO.newInstance().updateRecords(adhocCommunicationsToUpdateList, false, AccessLevel.USER_MODE);
            }
        }catch(Exception e){
            Logger.error('Exception caught in method execute in class AdhocCommunicationsBatch.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    public void finish(Database.BatchableContext bc) {}//NOPMD
}
