/**
 * @description Trigger for Marketing_Interaction__c
 * @see MarketingInteractionTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | w.li                           | June 05, 2022         | DEPP-1058              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger MarketingInteractionTrigger on Marketing_Interaction__c(
  after insert,
  after update
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Marketing_Interaction__c'),
    Trigger.operationType
  );
}