/**
 * @description Mock DAO Class for Operating Hours Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
 *    | john.aldric.s.seril            | July 25, 2024         | DEPP-9834              | Created file                                       |
*/
@isTest
public inherited sharing class OperatingHoursDAOMock extends DmlBaseMock implements IOperatingHoursDAO{
	public Map<Id, OperatingHours> operatingHoursMap;
    
    public Schema.SObjectType getSObjectType() {
        return OperatingHours.SObjectType;
    }
    
    public OperatingHoursDAOMock() {
        super(new Map<Id, OperatingHours>(), Schema.OperatingHours.SObjectType);
        this.operatingHoursMap = (Map<Id, OperatingHours>) super.records;
    }
    
    public Database.QueryLocator queryLocatorGetVoiceOperatingHours() {
        return null;
    }
    
    public List<OperatingHours> getOperatingHoursByIdAndChannel(
        Set<Id> operatingHrsIds,
        String channelType,
        AccessLevel accessLevel
    ) {
        List<OperatingHours> operatingHrsList = new List<OperatingHours>();

        for (OperatingHours record : operatingHoursMap.values()) {
            if (operatingHrsIds.contains(record.Id) && channelType == record.Channel_Type__c) {
                operatingHrsList.add(record);
            }
        }

        return operatingHrsList;
    }

}