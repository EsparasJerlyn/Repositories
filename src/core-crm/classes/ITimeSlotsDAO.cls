/**
 * @description Interface for Time Slots DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | john.aldric.s.seril            | Aug 12, 2024          | DEPP-9834              | Created file                                   |
*/
public interface ITimeSlotsDAO extends DmlInterface {
    List<TimeSlot> getTimeSlotRecords(List<OperatingHours> operatingHoursRecordList, AccessLevel accessLevel);
}
