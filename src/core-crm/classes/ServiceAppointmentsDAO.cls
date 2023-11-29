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
 */
public inherited sharing class ServiceAppointmentsDAO extends DmlBase implements IServiceAppointmentsDAO {

    public static IServiceAppointmentsDAO newInstance() {
        return (IServiceAppointmentsDAO) ImplementationSelector.DAO.newInstance(ServiceAppointment.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return ServiceAppointment.SObjectType;
    }
} 