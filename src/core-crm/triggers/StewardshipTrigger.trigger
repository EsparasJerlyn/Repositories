/**
 * @description trigger for object Stewardship
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | May 17, 2024          | DEPP-8789              | created file
 */
trigger StewardshipTrigger on Designation__c(after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Stewardship'),
        Trigger.operationType
    );
}