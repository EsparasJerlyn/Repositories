/**
 * @description trigger for object Engagement List criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 27, 2024          | DEPP-8745              | created file
 */
trigger EngagementListCriteriaTrigger on Engagement_List_Criteria__c (before update) {
	TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Engagement_List_Criteria__c'),
        Trigger.operationType
    );
}