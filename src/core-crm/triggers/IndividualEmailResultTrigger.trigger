/**
 * @description Trigger for IER
 * @see IndividualEmailResultTrigger
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
trigger IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c(
  after insert,
  after update
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('et4ae5__IndividualEmailResult__c'),
    Trigger.operationType
  );
}