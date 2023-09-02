/**
 * @description Trigger for Application trigger class
 * @see ApplicationTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | June 19,2023          | DEPP-5846              | Created file                 |
 */
trigger ApplicationTrigger on hed__Application__c(before insert, after insert, after update) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('hed__Application__c'),
    Trigger.operationType
  );
}