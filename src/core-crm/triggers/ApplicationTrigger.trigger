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
      | mark.j.mahilum                 | April 30, 2024        | DEPP-7987              | Added before update trigger  |
 */
trigger ApplicationTrigger on hed__Application__c(before insert, after insert, before update, after update) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('hed__Application__c'),
    Trigger.operationType
  );
}