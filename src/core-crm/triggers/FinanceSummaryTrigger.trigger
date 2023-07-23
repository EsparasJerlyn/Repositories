/**
 * @description trigger for Finance Summary Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 12, 2023         | DEPP-5473              | Created File
 */
trigger FinanceSummaryTrigger on Finance_Summary__c (after insert , after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Finance_Summary__c'),
        Trigger.operationType
    );
}