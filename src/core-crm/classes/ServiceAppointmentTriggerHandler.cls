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
      | nicole.genon              | November 20, 2023     | DEPP-7259    | Added AfterInsert, AfterUpdate                                        |
      | kenneth.f.alsay           | November 30, 2023     | DEPP-7265    | Added matchExistingContactOrLeadToAppointment in beforeInsert         |
*/
public with sharing class ServiceAppointmentTriggerHandler implements Disableable, BeforeInsert, AfterInsert, AfterUpdate{

        /**
     * @description beforeInsert trigger event
     * @param newItems - List of ServiceAppointment.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        ServiceAppointmentTriggerHelper.updateContactLeadLinkedtoServiceAppointment((List<ServiceAppointment>) newItems);
        ServiceAppointmentTriggerHelper.matchExistingContactOrLeadToAppointment((List<ServiceAppointment>) newItems);
    }

    /**
     * 
     * @param newItems - Map of ServiceAppointment.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        ServiceAppointmentTriggerHelper.sendEmailOnServiceAppointmentCreation((List<ServiceAppointment>) newItems.values());
    }

     /**
    * @description performs afterUpdate event for ServiceAppointment object
    * @param newItems - Map of ServiceAppointment.Trigger.newMap
    * @param oldItems - Map of ServiceAppointment.Trigger.oldMap
    */
    public void afterUpdate(Map<Id, SObject> newItems,Map<Id, Sobject> oldItems) {
        ServiceAppointmentTriggerHelper.sendEmailAfterUpdate((List<ServiceAppointment>) newItems.values(),(Map<Id, ServiceAppointment>) oldItems);
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