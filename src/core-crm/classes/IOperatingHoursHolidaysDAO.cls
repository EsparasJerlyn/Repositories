/**
 * @description Interface for Operating Hours Holiday DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | john.aldric.s.seril            | Aug 12, 2024          | DEPP-9834              | Created file                                   |
*/
public interface IOperatingHoursHolidaysDAO extends DmlInterface{
    List<OperatingHoursHoliday> getOperatingHoursHolidayRecords(List<OperatingHours> operatingHoursRecordList, AccessLevel accessLevel);
}