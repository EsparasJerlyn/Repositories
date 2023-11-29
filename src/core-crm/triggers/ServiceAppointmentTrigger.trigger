/**
 * @description Trigger for Service Appointment Object
 * @see ServiceAppointmentTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dyrit               | November 21,2023      | DEPP-7264              | Created file                 |
 */
trigger ServiceAppointmentTrigger on ServiceAppointment (before insert) {
    TriggerDispatcher.dispatch(
      TriggerHandlerFactory.getHandlersForSObjectType('ServiceAppointment'),
      Trigger.operationType
    );
}