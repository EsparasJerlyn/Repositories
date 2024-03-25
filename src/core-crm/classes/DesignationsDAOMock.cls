/**
 * @description Mock DAO Class for Designation Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
*/
@isTest
public inherited sharing class DesignationsDAOMock extends DmlBaseMock implements IDesignationsDAO {
    public Map<Id, Designation__c> donationCausesMap;

    public Schema.SObjectType getSObjectType() {
        return Designation__c.SObjectType;
    }

    public DesignationsDAOMock() {
        super(new Map<Id, Designation__c>(), Schema.Designation__c.SObjectType);
        this.donationCausesMap = (Map<Id, Designation__c>) super.records;
    }

    public Database.QueryLocator queryLocatorGetDonatioCausesForStageUpdate() {
        return null;
    }

    public List<Designation__c> getDesignationsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Designation__c> donationCauseList = new List<Designation__c>();
        for (Designation__c record : donationCausesMap.values()) {
            if (recordIds.contains(record.Id)) {
                donationCauseList.add(record);
            }
        }
        return donationCauseList;
    }
}
