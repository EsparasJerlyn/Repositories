/**
 * @description Mock DAO Class for Stewardship Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
 *    | nicole.genon                   | March 6, 2024         | DEPP-7922              | Created file                                       |
*/
@isTest
public inherited sharing class StewardshipsDAOMock extends DmlBaseMock implements IStewardshipsDAO {
    public Map<Id, Stewardship__c> stewardshipsMap;

    public Schema.SObjectType getSObjectType() {
        return Stewardship__c.SObjectType;
    }

    public StewardshipsDAOMock() {
        super(new Map<Id, Stewardship__c>(), Schema.Stewardship__c.SObjectType);
        this.stewardshipsMap = (Map<Id, Stewardship__c>) super.records;
    }

    public List<Stewardship__c> getStewardshipBySetIds(
        Set<Id> stewardshipIds,
        AccessLevel accessLevel
    ) {
        List<Stewardship__c> stewardshipList = new List<Stewardship__c>();

        if(!stewardshipIds.isEmpty()){
            for (Stewardship__c record : stewardshipsMap.values()) {
                if (stewardshipIds.contains(record.Id)) {
                    stewardshipList.add(record);
                }
            }
        }

        return stewardshipList;
    }

    public List<Stewardship__c> getStewardshipByRecordTypeIds(
        Set<Id> recordTypeIds,
        AccessLevel accessLevel
    ) {
        List<Stewardship__c> stewardshipList = new List<Stewardship__c>();

        if(!recordTypeIds.isEmpty()){
            for (Stewardship__c record : stewardshipsMap.values()) {
                if (recordTypeIds.contains(record.RecordTypeId)) {
                    stewardshipList.add(record);
                }
            }
        }

        return stewardshipList;
    }
}