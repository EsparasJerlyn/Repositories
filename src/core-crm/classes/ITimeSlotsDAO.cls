
public interface ITimeSlotsDAO extends DmlInterface {
    List<TimeSlot> getTimeSlotRecords(List<OperatingHours> operatingHoursRecordList, AccessLevel accessLevel);
}
