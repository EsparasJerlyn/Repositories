/**
 * @description Helper class for Completed Cadence
 *
 * @author Accenture
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 23, 2024         | DEPP-8255              | Created file                 |
 */

public with sharing class CompletedCadenceTriggerHelper {
   /**
     * @description Performs fast field updates and validation on a list of Completed Cadence records.
     *              Handles updates to specific fields and performs validation.
     *              Additionally, it does cross-object logic
     *              This should be used in Before Insert/Update only
     * @param newItems List of new Completed_Cadence__c records being processed.
     * @param oldItems Map of old Completed_Cadence__c records for comparison, keyed by record Id.
     */
    public void fastFieldUpdateAndValidation(
        List<Completed_Cadence__c> newItems,
        Map<Id, Completed_Cadence__c> oldItems
    ) {
        // Initialize a Set to Store the Completed Cadence Id
        Set<Id> completedCadenceIdSet = new Set<Id>();

        for(Completed_Cadence__c newCompletedCadence : newItems) {

            Completed_Cadence__c oldCompletedCadence = oldItems.get(newCompletedCadence.Id);
            // Compled Date will be set when the Completed cadence record Status is updated to Successful
            // This will also populate the set of Id to update the related task 
            if(newCompletedCadence.Completed_Cadence_Status__c == CompletedCadencesDAO.SUCCESSFUL_STATUS &&
                oldCompletedCadence.Completed_Cadence_Status__c != CompletedCadencesDAO.SUCCESSFUL_STATUS){
                    newCompletedCadence.Completed_Date__c = Date.Today();
                    completedCadenceIdSet.add(newCompletedCadence.Id);
                }
        }
        
        if(!completedCadenceIdSet.isEmpty()){
            completedCadenceUpdate(completedCadenceIdSet);
        }
    }


    private void completedCadenceUpdate (Set<Id> completedCadenceIdSet){
        // Query the task for associated cadences
        List<Task> tasksToUpdate = TasksDAO.newInstance().getTaskByCompeltedCadence(completedCadenceIdSet, AccessLevel.USER_MODE);

        Map<Id, Integer> taskCountMap = new Map<Id, Integer>();

        //Iterate each task that relates to the Completed Cadence
        for (Task task : tasksToUpdate) {
            if (!taskCountMap.containsKey(task.Completed_Cadence__c)) {
                taskCountMap.put(task.Completed_Cadence__c, 0);
            }
            taskCountMap.put(task.Completed_Cadence__c, taskCountMap.get(task.Completed_Cadence__c) + 1);
        }

        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        for (Id completedCadenceId : completedCadenceIdSet) {
            Completed_Cadence__c completedCadence = new Completed_Cadence__c(Id = completedCadenceId);
            completedCadence.Cadence_Tasks__c = taskCountMap.containsKey(completedCadenceId) ? taskCountMap.get(completedCadenceId) : 0;
            completedCadenceList.add(completedCadence);
        }

        if(!completedCadenceList.isEmpty()) {
            try{
                CompletedCadencesDAO.newInstance().updateRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE); 
            }catch (Exception e) {
                Logger.error('Exception caught in Completed Cadence Trigger Helper - completedCadenceUpdate Method').setExceptionDetails(e);
            }finally {
                if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
                }            
            }
        }
    }
}