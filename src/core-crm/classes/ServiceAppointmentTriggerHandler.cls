/**
 * @description Service Appointment object trigger handler class
 * @see ServiceAppointmentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | arsenio.jr.dayrit         | November 21,2023      | DEPP-7264    | Created file                                                          								|
 *    | nicole.genon              | November 20, 2023     | DEPP-7259    | Added AfterInsert, AfterUpdate                                        								|
 *    | kenneth.f.alsay           | November 30, 2023     | DEPP-7265    | Added matchExistingContactOrLeadToAppointment in beforeInsert         								|
 *    | ryan.j.a.dela.cruz        | December 6, 2023      | DEPP-7369    | Confirmation email sending fix                                        								|
 *    | arsenio.jr.dayrit         | December 12, 2023     | DEPP-7357    | Added ServiceAppointmentTriggerHelper.updateContactLeadLinkedtoServiceAppointment on afterUpdate                                        |
 */
public with sharing class ServiceAppointmentTriggerHandler implements Disableable, BeforeInsert,BeforeUpdate,AfterUpdate{

    /**
     * @description beforeInsert trigger event
     * @param newItems - List of ServiceAppointment.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        ServiceAppointmentTriggerHelper.matchExistingContactOrLeadToAppointment((List<ServiceAppointment>) newItems);
        ServiceAppointmentTriggerHelper.generateGUID((List<ServiceAppointment>) newItems);
    }

    /**
     * @description beforeUpdate trigger event
     * @param newItems - Map of ServiceAppointment.Trigger.newMap
     * @param oldItems - Map of ServiceAppointment.Trigger.oldMap
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ServiceAppointmentTriggerHelper.generateGUID((List<ServiceAppointment>) newItems.values());
    }

    /**
    * @description performs afterUpdate event for ServiceAppointment object
    * @param newItems - Map of ServiceAppointment.Trigger.newMap
    * @param oldItems - Map of ServiceAppointment.Trigger.oldMap
    */
    public void afterUpdate(Map<Id, SObject> newItems,Map<Id, Sobject> oldItems) {
        ServiceAppointmentTriggerHelper.updateContactLeadLinkedtoServiceAppointment((List<ServiceAppointment>) newItems.values());
        ServiceAppointmentTriggerHelper.sendEmailOnServiceAppointmentUpdate((List<ServiceAppointment>) newItems.values(),(Map<Id, ServiceAppointment>) oldItems);
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