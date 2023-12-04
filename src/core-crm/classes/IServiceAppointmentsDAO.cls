/**
 * @description Interface for Service Appointment DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | Created File                               |
      | neil.s.h.lesidan               | November 29, 2023     | DEPP-7280              | Added getServiceAppointmentByEmail         |

 */
public interface IServiceAppointmentsDAO extends DmlInterface{
     List<ServiceAppointment> getServiceAppointmentByEmail(
          String email,
          AccessLevel accessLevel
     );
}