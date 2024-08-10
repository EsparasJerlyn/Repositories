/**
 * @description Trigger for Engagement Opportunity Object
 * @see EngagementOpportunityTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                        |
      |--------------------------------|-----------------------|------------------------|---------------------------------------|
      | nicole.genon                   | December 18,2023      | DEPP-6949              | Created file                          |
 */
trigger EngagementOpportunityTrigger on Engagement_Opportunity__c (after insert) {
    TriggerDispatcher.dispatch(
      TriggerHandlerFactory.getHandlersForSObjectType('Engagement_Opportunity__c'),
      Trigger.operationType
    );
}