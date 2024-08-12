public inherited sharing class TimeSlotsDAO extends DmlBase implements ITimeSlotsDAO{
    public Schema.SObjectType getSObjectType() {
        return TimeSlot.SObjectType;
    }
    
    public static ITimeSlotsDAO newInstance() {
        return (ITimeSlotsDAO) ImplementationSelector.DAO.newInstance(
            TimeSlot.SObjectType
        );
    }

    public List<TimeSlot> getTimeSlotRecords(
        List<OperatingHours> operatingHoursRecordList,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, OperatingHoursId, DayOfWeek, StartTime, EndTime ' +
              'FROM TimeSlot ' +
             'WHERE OperatingHoursId =: operatingHoursRecordList',
            accessLevel
        );
    }
}

