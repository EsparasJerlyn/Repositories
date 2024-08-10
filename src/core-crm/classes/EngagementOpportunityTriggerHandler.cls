/**
 * @description Engagement Opportunity object trigger handler class
 * @see EngagementOpportunityTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | nicole.genon              | December 18,2023      | DEPP-6949    | Created file                                                          								|                             |
 */
public with sharing class EngagementOpportunityTriggerHandler implements Disableable, AfterInsert {
    /**
     * @description afterInsert trigger event
     * @param newItems - List of Engagement_Opportunity__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        EngagementOpportunityTriggerHelper.createListRecordOnEngagementOpportunityCreation((List<Engagement_Opportunity__c>) newItems.values());
    }

    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}