/**
 * @description DAO Class for Operating Hours Holiday Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | john.aldric.s.seril            | Aug 12, 2024          | DEPP-9834              | Created file                                   |
*/
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
