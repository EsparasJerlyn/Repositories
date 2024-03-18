/**
 * @description trigger for Plan Activity Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created File
 */
trigger PlanActivityTrigger on Plan_Activity__c (after insert , after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Plan_Activity__c'),
        Trigger.operationType
    );
}