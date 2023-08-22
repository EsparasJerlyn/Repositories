/**
 * @description trigger for Expense Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | August 21, 2023       | DEPP-6410              | Created file                 |
 */
trigger ExpenseTrigger on Expense__c (after insert , after update) {
	TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Expense__c'),
        Trigger.operationType
    );
}