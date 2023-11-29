/**
 * @description Mock DAO Class for Service Appointment Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | Created File                               |
 */
@isTest
public inherited sharing class ServiceAppointmentsDAOMock extends DmlBaseMock implements IServiceAppointmentsDAO {
    
    public Map<Id, ServiceAppointment> serviceAppointmentMap;

    public ServiceAppointmentsDAOMock() {
        super(new Map<Id, ServiceAppointment>(), Schema.ServiceAppointment.SObjectType);
        this.serviceAppointmentMap = (Map<Id, ServiceAppointment>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return ServiceAppointment.SObjectType;
    }

}