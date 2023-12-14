/**
 * @description Interface for Service Appointment DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                        |
      |--------------------------------|-----------------------|------------------------|---------------------------------------|
      | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | Created File                          |
      | nicole.genon                   | November 24, 2023     | DEPP-7259              | Added getServiceAppointmentsBySetIds  |
      | neil.s.h.lesidan               | November 29, 2023     | DEPP-7280              | Added getServiceAppointmentByEmail    |
      |                                |                       |                        |                                       |
 */
public interface IServiceAppointmentsDAO extends DmlInterface{
    List<ServiceAppointment> getServiceAppointmentsBySetIds(
          Set<Id> serviceAppointmentIds, 
          List<String> fields, 
          AccessLevel accessLevel);
    List<ServiceAppointment> getServiceAppointmentByEmail(
          String email,
          AccessLevel accessLevel
     );
     List<ServiceAppointment> getServiceAppointmentByAppointmentEmail(
        String email,
        AccessLevel accessLevel
    );
}
