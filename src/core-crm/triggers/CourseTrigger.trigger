/**
 * @description Trigger for hed__course__c to populate external Id during before insert
 * @see CourseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger CourseTrigger on hed__Course__c (before insert) {
    TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType(
      'hed__course__c'
    ),
    Trigger.operationType
  );
}