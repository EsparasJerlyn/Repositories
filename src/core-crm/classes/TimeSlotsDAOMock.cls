/**
 * @description Mock DAO Class for Time Slots Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
 *    | john.aldric.s.seril            | Aug 12, 2024          | DEPP-9834              | Created file                                       |
*/
@isTest
public inherited sharing class TimeSlotsDAOMock extends DmlBaseMock implements ITimeSlotsDAO {

    public Map<Id, TimeSlot> timeSlotMap;
    
    public Schema.SObjectType getSObjectType() {
        return TimeSlot.SObjectType;
    }
    
    public TimeSlotsDAOMock() {
        super(new Map<Id, TimeSlot>(), Schema.TimeSlot.SObjectType);
        this.timeSlotMap = (Map<Id, TimeSlot>) super.records;
    }
    
    public List<TimeSlot> getTimeSlotRecords(
        List<OperatingHours> operatingHoursRecordList,
        AccessLevel accessLevel
    ) {
        List<TimeSlot> timeSlotList = new List<TimeSlot>();

        for (TimeSlot record : timeSlotMap.values()) {
            if (new Map<Id, OperatingHours>(operatingHoursRecordList).keySet().contains(record.OperatingHoursId)) {
                timeSlotList.add(record);
            }
        }

        return timeSlotList;
    }
}