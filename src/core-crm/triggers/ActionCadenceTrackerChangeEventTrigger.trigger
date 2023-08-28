/**
 * @description Trigger for ActionCadenceTrackerChangeEvent object
 * @see ActionCadenceTrackerChangeEventTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Aug 23,2023           | DEPP-6215              | Created file                 |
 */
trigger ActionCadenceTrackerChangeEventTrigger on ActionCadenceTrackerChangeEvent(after insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('ActionCadenceTrackerChangeEvent'),
        Trigger.operationType
    );
}