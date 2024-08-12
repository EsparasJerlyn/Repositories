public interface IOperatingHoursHolidaysDAO extends DmlInterface{
    List<OperatingHoursHoliday> getOperatingHoursHolidayRecords(List<OperatingHours> operatingHoursRecordList, AccessLevel accessLevel);
}