/**
 * @description trigger for object Opportunity Contact Role
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Aug 24, 2023          | DEPP-6367              | created file
 */
trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('OpportunityContactRole'),
        Trigger.operationType
    );
}