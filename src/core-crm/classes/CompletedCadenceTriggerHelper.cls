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
        for(Completed_Cadence__c newCompletedCadence : newItems.values()) {
            Completed_Cadence__c completedCadenceOld = oldItems.get(newCompletedCadence.Id);

            completedCadenceUpdate(newCompletedCadence, completedCadenceOld);
        }
    }


    /**
     * @description Updates the Cadence Task and the Completed Date when Status is Successful
     * @param completedCadenceNew new Value of the Completed_Cadence__c
     * @param completedCadenceOld old Value of the Completed_Cadence__c
     * @return - void
     */
    private void completedCadenceUpdate (Completed_Cadence__c completedCadenceNew , Completed_Cadence__c completedCadenceOld ){
        try{
            // Completed Date will be set when the Completed cadence record Status is updated to Successful
            if(completedCadenceNew.Completed_Cadence_Status__c == CompletedCadencesDAO.SUCCESSFUL_STATUS &&
                completedCadenceOld.Completed_Cadence_Status__c != CompletedCadencesDAO.SUCCESSFUL_STATUS){
                    completedCadenceNew.Completed_Date__c = Date.Today();
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