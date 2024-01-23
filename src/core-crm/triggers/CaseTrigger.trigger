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
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | Added before insert          |
 */
trigger CaseTrigger on Case(before insert, before update, after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Case'),
        Trigger.operationType
    );
}