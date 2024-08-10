/**
 * @description trigger for object List_Member
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | created file
 */
trigger ListMemberTrigger on List_Member__c (before insert, before update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('List_Member__c'),
        Trigger.operationType
    );
}