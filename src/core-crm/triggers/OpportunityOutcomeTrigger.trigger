/**
 * @description trigger for object opportunity outcome
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 12, 2023          | DEPP-5594              | created file
 */
trigger OpportunityOutcomeTrigger on Opportunity_Outcome__c (before insert) {
	TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Opportunity_Outcome__c'),
        Trigger.operationType
    );
}