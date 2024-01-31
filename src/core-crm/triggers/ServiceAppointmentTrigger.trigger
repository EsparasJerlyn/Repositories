/**
 * @description Trigger for Service Appointment Object
 * @see ServiceAppointmentTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                        |
      |--------------------------------|-----------------------|------------------------|---------------------------------------|
      | arsenio.jr.dyrit               | November 21,2023      | DEPP-7264              | Created file                          |
      | nicole.genon                   | November 21, 2023     | DEPP-7259              | Added after insert and after update   |
 */
trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, after insert, before update, after update) {
    TriggerDispatcher.dispatch(
      TriggerHandlerFactory.getHandlersForSObjectType('ServiceAppointment'),
      Trigger.operationType
    );
}