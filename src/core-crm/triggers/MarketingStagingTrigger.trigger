/**
 * @description Trigger for Marketing_Staging__c
 * @see MarketingStagingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 23, 2022          | DEPP-2103              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger MarketingStagingTrigger on Marketing_Staging__c (after insert) {
    TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType(
      'Marketing_Staging__c'
    ),
    Trigger.operationType
  );
}