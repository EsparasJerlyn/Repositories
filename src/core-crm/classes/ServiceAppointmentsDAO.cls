/**
 * @description DAO Class for Service Appointment Object. Contains soql and constants related to the Service Appointment object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | created file                               |
 *    | neil.s.h.lesidan               | November 29, 2023     | DEPP-7280              | Added getServiceAppointmentByEmail         |
 */
public inherited sharing class ServiceAppointmentsDAO extends DmlBase implements IServiceAppointmentsDAO {

    public static IServiceAppointmentsDAO newInstance() {
        return (IServiceAppointmentsDAO) ImplementationSelector.DAO.newInstance(ServiceAppointment.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return ServiceAppointment.SObjectType;
    }

    public List<ServiceAppointment> getServiceAppointmentByEmail(
        String email,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Mobile_No_Locale__c, First_Name__c, Last_Name__c, Email, Contact__c, LeadId__c ' +
                'FROM ServiceAppointment ' +
                'WHERE Email =: email ',
                accessLevel
        );
    }
}