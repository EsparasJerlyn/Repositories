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
     * @param newItems List of new Completed_Cadence__c records being processed, keyed by record Id.
     * @param oldItems Map of old Completed_Cadence__c records for comparison, keyed by record Id.
     * @return - void
     */
    public void fastFieldUpdateAndValidation(
        Map<Id, Completed_Cadence__c> newItems,
        Map<Id, Completed_Cadence__c> oldItems
    ) {
        completedCadenceUpdate(newItems, oldItems);
    }


    /**
     * @description Updates the Cadence Task and the Completed Date when Status is Successful
     * @param completedCadenceMap Map of the new items from fastFieldUpdateValidation
     * @param completedCadenceOldMap Map of the old items from fastFieldUpdateValidation
     * @return - void
     */
    private void completedCadenceUpdate (Map<Id, Completed_Cadence__c> completedCadenceMap , Map<Id, Completed_Cadence__c> completedCadenceOldMap ){
        // Query the task for associated cadences
        try{
            Set<Id> completedCadenceIdSet = new Set<Id>();
            for(Completed_Cadence__c newCompletedCadence : completedCadenceMap.values()) {

                Completed_Cadence__c completedCadenceOld = completedCadenceOldMap.get(newCompletedCadence.Id);

                // Compled Date will be set when the Completed cadence record Status is updated to Successful
                // This will also populate the set of Id to update the related task when successful
                if(newCompletedCadence.Completed_Cadence_Status__c == CompletedCadencesDAO.SUCCESSFUL_STATUS &&
                    completedCadenceOld.Completed_Cadence_Status__c != CompletedCadencesDAO.SUCCESSFUL_STATUS){
                        newCompletedCadence.Completed_Date__c = Date.Today();
                        completedCadenceIdSet.add(newCompletedCadence.Id);
                    }
            }
            
            List<Task> tasksToUpdate = TasksDAO.newInstance().getTaskByCompeltedCadence(completedCadenceIdSet, AccessLevel.SYSTEM_MODE);

            Map<Id, Integer> taskCountMap = new Map<Id, Integer>();
    
            //Iterate each task that relates to the Completed Cadence
            for (Task task : tasksToUpdate) {
                if (!taskCountMap.containsKey(task.Completed_Cadence__c)) {
                    taskCountMap.put(task.Completed_Cadence__c, 0);
                }
                taskCountMap.put(task.Completed_Cadence__c, taskCountMap.get(task.Completed_Cadence__c) + 1);
            }
    
            for (Id completedCadenceId : completedCadenceIdSet) {
                //Assign the count to the Cadence Task field by getting it through the map 
                if(completedCadenceMap.containsKey(completedCadenceId)){
                    completedCadenceMap.get(completedCadenceId).Cadence_Tasks__c = taskCountMap.containsKey(completedCadenceId) ? taskCountMap.get(completedCadenceId) : 0;
                }
            }
    
        }catch (Exception e) {
            Logger.error('Exception caught in Completed Cadence Trigger Helper - completedCadenceUpdate Method').setExceptionDetails(e);
        }finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }            
        }
    }
}