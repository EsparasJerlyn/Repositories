/**
 * @description trigger handler class for object Completed Cadence
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 23, 2024         | DEPP-8255              | Created file                 |
 */

public with sharing class CompletedCadenceTriggerHandler implements Disableable, BeforeUpdate {
    
    /**
     * @description Handles the before update trigger event.
     * @param newItems Map of new SObject records being updated, keyed by record Id.
     * @param oldItems Map of old SObject records for comparison, keyed by record Id.
     */
    public void beforeUpdate(Map<Id, Sobject> newItems, Map<Id, Sobject> oldItems) {
        // Instantiate the helper class
        CompletedCadenceTriggerHelper helper = new CompletedCadenceTriggerHelper();
        
        // Call the instance method of the helper class
        helper.fastFieldUpdateAndValidation(
            (List<Completed_Cadence__C>) newItems.values(),
            (Map<Id, Completed_Cadence__c>) oldItems
        );
    }

    /**
     * @description Checks if the trigger is disabled.
     *              This is typically used to prevent recursion or bypass certain trigger logic.
     * @return Boolean indicating whether the trigger is disabled.
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}