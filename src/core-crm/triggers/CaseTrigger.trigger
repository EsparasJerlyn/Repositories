/**
 * @description Trigger for Case object
 * @see CaseTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Sept 11, 2023         | DEPP-6421              | Created file                 |
 */
trigger CaseTrigger on Case(after insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Case'),
        Trigger.operationType
    );
}