/**
 * @description trigger for object Milestone
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | created file
 */
trigger MilestoneTrigger on Milestone__c (after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Milestone__c'),
        Trigger.operationType
    );
}