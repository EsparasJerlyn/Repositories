/**
 * @description Mock DAO Class for Operating Hours Holiday Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
 *    | john.aldric.s.seril            | Aug 12, 2024          | DEPP-9834              | Created file                                       |
*/
@isTest
public inherited sharing class OperatingHoursHolidaysDAOMock extends DmlBaseMock implements IOperatingHoursHolidaysDAO{
    public Map<Id, OperatingHoursHoliday> operatingHoursHolidayMap;
    
    public Schema.SObjectType getSObjectType() {
        return OperatingHoursHoliday.SObjectType;
    }
    
    public OperatingHoursHolidaysDAOMock() {
        super(new Map<Id, OperatingHoursHoliday>(), Schema.OperatingHoursHoliday.SObjectType);
        this.operatingHoursHolidayMap = (Map<Id, OperatingHoursHoliday>) super.records;
    }
    
    public List<OperatingHoursHoliday> getOperatingHoursHolidayRecords(
        List<OperatingHours> operatingHoursRecordList,
        AccessLevel accessLevel
    ) {
        List<OperatingHoursHoliday> operatingHrsHolidayList = new List<OperatingHoursHoliday>();

        for (OperatingHoursHoliday record : operatingHoursHolidayMap.values()) {
            if (new Map<Id, OperatingHours>(operatingHoursRecordList).keySet().contains(record.OperatingHoursId)) {
                operatingHrsHolidayList.add(record);
            }
        }

        return operatingHrsHolidayList;
    }
}