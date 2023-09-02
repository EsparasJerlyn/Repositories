/**
 * @description trigger for object Engagement
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 12, 2023          | DEPP-5594              | created file
 */
trigger EngagementTrigger on Engagement__c (before insert) {
	TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Engagement__c'),
        Trigger.operationType
    );
}