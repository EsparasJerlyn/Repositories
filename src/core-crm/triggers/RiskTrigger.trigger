/**
 * @description trigger for object Risk
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | August 08, 2023       | DEPP-6335              | Created file
 */
trigger RiskTrigger on Risk__c(after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Risk__c'),
        Trigger.operationType
    );
}
