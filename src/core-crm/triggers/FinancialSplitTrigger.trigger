/**
 * @description trigger for object Financial Split
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | created file
 */
trigger FinancialSplitTrigger on Financial_Split__c (after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Financial_Split__c'),
        Trigger.operationType
    );
}