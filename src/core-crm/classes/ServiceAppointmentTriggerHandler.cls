/**
 * @description Service Appointment object trigger handler class
 * @see ServiceAppointmentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------------------|
      | arsenio.jr.dayrit         | November 21,2023      | DEPP-7264    | Created file                                                          |
      | kenneth.f.alsay           | November 30, 2023     | DEPP-7265    | Added matchExistingContactOrLeadToAppointment in beforeInsert         |
*/
public with sharing class ServiceAppointmentTriggerHandler implements Disableable, BeforeInsert{

    /**
   * @description beforeInsert trigger event
   * @param newItems - List of ServiceAppointment.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) {
        ServiceAppointmentTriggerHelper.updateContactLeadLinkedtoServiceAppointment((List<ServiceAppointment>) newItems);
      	ServiceAppointmentTriggerHelper.matchExistingContactOrLeadToAppointment((List<ServiceAppointment>) newItems);
  }

    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
} 