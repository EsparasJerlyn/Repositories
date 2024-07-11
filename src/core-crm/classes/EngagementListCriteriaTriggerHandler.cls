/**
 * @description trigger handler class for object Engagement List Criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 27, 2024          | DEPP-8745              | created file
 */
public with sharing class EngagementListCriteriaTriggerHandler implements Disableable, BeforeUpdate {
    /**
     * @description Handles the before update trigger event.
     * @param newItems Map of new SObject records being updated, keyed by record Id.
     * @param oldItems Map of old SObject records for comparison, keyed by record Id.
     */
    public void beforeUpdate(Map<Id, Sobject> newItems, Map<Id, Sobject> oldItems) {
        // Instantiate the helper class
        EngagementListCriteriaTriggerHelper helper = new EngagementListCriteriaTriggerHelper();
        
        // Call the instance method of the helper class
        helper.fastFieldUpdateAndValidation(
            (List<Engagement_List_Criteria__c>) newItems.values(),
            (Map<Id, Engagement_List_Criteria__c>) oldItems
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
