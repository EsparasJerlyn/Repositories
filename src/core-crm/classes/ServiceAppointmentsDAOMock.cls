/**
 * @description Mock DAO Class for Service Appointment Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | Created File                               |
 *    | nicole.genon                   | November 27, 2023     | DEPP-7259              | Added getServiceAppointmentsBySetIds       |
 *    | neil.s.h.lesidan               | November 29, 2023     | DEPP-7280              | Add method getServiceAppointmentByEmail    |
 *    | arsenio.jr.dayrit              | December 14, 2023     |DEPP-7357               | Added method getServiceAppointmentByLeadId |
 */
@isTest
public inherited sharing class ServiceAppointmentsDAOMock extends DmlBaseMock implements IServiceAppointmentsDAO{
    public Map<Id, ServiceAppointment> serviceAppointmentMap;

    public ServiceAppointmentsDAOMock() {
        super(new Map<Id, ServiceAppointment>(), Schema.ServiceAppointment.SObjectType);
        this.serviceAppointmentMap = (Map<Id, ServiceAppointment>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return ServiceAppointment.SObjectType;
    }

    public List<ServiceAppointment> getServiceAppointmentsBySetIds(Set<Id> serviceAppointmentIds, List<String> fields, AccessLevel accessLevel) {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();

        for (ServiceAppointment record : serviceAppointmentMap.values()) {
            if (serviceAppointmentIds.contains(record.Id)) {
                serviceAppointmentList.add(record);
            }
        }

        return serviceAppointmentList;
    }

    public List<ServiceAppointment> getServiceAppointmentByEmail(
        String email,
        AccessLevel accessLevel
    ) {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        for (ServiceAppointment record : serviceAppointmentMap.values()) {
            if (record.Email == email) {
                serviceAppointmentList.add(record);
            }
        }
        
        return serviceAppointmentList;
    }

    public List<ServiceAppointment> getServiceAppointmentByAppointmentEmail(
        String email,
        AccessLevel accessLevel
    ) {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        for (ServiceAppointment record : serviceAppointmentMap.values()) {
            if (record.Appointment_Email__c == email) {
                serviceAppointmentList.add(record);
            }
        }
        
        return serviceAppointmentList;
    }

    public List<ServiceAppointment> getServiceAppointmentByLeadId(
        Set<Id> leadId
    ) {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        for (ServiceAppointment record : serviceAppointmentMap.values()) {
            if (leadId.contains(record.LeadId__c)) {
                serviceAppointmentList.add(record);
            }
        }
        
        return serviceAppointmentList;
    }
}