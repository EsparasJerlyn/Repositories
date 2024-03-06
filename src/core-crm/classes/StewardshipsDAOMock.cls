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
public inherited sharing class StewardshipsDAOMock extends DmlBaseMock implements IStewardshipsDAOMock {
    public Map<Id, Stewardship__c> stewardshipsMap;

    public Schema.SObjectType getSObjectType() {
        return Stewardship__c.SObjectType;
    }

    public StewardshipsDAOMock() {
        super(new Map<Id, Stewardship__c>(), Schema.Stewardship__c.SObjectType);
        this.stewardshipsMap = (Map<Id, Stewardship__c>) super.records;
    }
}