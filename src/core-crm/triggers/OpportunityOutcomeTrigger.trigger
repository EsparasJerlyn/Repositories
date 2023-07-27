/**
 * @description trigger for object opportunity outcome
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | alexander.cadalin              | May 12, 2023          | DEPP-5594              | created file                 |
 *    | kenneth.f.alsay                | Jul 13, 2023          | DEPP-5457,5468         | added after insert           |
 *    | ryan.j.a.dela.cruz             | Jul 26, 2023          | DEPP-6208              | added after update           |
 */
trigger OpportunityOutcomeTrigger on Opportunity_Outcome__c (before insert, after insert, after update) {
	TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Opportunity_Outcome__c'),
        Trigger.operationType
    );
}