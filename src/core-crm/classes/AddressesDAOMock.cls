/**
 * @description Mock DAO Class for hed__Address__c Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | sep 22, 2023          | DEPP-6652              | Created file
 */
@isTest
public inherited sharing class AddressesDAOMock extends DmlBaseMock implements IAddressesDAO {
    public Map<Id, hed__Address__c> addressesMap;

    public Schema.SObjectType getSObjectType() {
        return hed__Address__c.SObjectType;
    }

    public AddressesDAOMock() {
        super(new Map<Id, hed__Address__c>(), Schema.hed__Address__c.SObjectType);
        this.addressesMap = (Map<Id, hed__Address__c>) super.records;
    }
}
