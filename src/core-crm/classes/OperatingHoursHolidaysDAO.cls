public inherited sharing class OperatingHoursHolidaysDAO extends DmlBase implements IOperatingHoursHolidaysDAO{
    public Schema.SObjectType getSObjectType() {
        return OperatingHoursHoliday.SObjectType;
    }
    
    public static IOperatingHoursHolidaysDAO newInstance() {
        return (IOperatingHoursHolidaysDAO) ImplementationSelector.DAO.newInstance(
            OperatingHoursHoliday.SObjectType
        );
    }

    public List<OperatingHoursHoliday> getOperatingHoursHolidayRecords(
        List<OperatingHours> operatingHoursRecordList,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, OperatingHoursId, DateAndTime, Holiday.ActivityDate ' +
              'FROM OperatingHoursHoliday ' +
             'WHERE OperatingHoursId =: operatingHoursRecordList',
            accessLevel
        );
    }
}
