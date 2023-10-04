/**
 * @description Mock DAO Class for Package Component Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | arsenio.jr.dayrit              | August 15, 2023       | DEPP-6370              | Created File                               |
      | eccarius.munoz                 | August 21, 2023       |DEPP-6252               | Added getPackageComponentsByAppPrefIdSet   | 
 */
@isTest
public inherited sharing class PackageComponentDAOMock extends DmlBaseMock implements IPackageComponentDAO {
    
    public Map<Id, Package_Component__c> packageComponentMap;

    public PackageComponentDAOMock() {
        super(new Map<Id, Package_Component__c>(), Schema.Package_Component__c.SObjectType);
        this.packageComponentMap = (Map<Id, Package_Component__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Package_Component__c.SObjectType;
    }

    public List<Package_Component__c> getPackageComponentsByAppPrefIdSet(
        Set<Id> applicationPreferenceIds,
        AccessLevel accessLevel
    ) {
        List<Package_Component__c> packageComponentList = new List<Package_Component__c>();

        for (Package_Component__c record : packageComponentMap.values()) {
            if (applicationPreferenceIds.contains(record.Id)) {
                packageComponentList.add(record);
            }
        }

        return packageComponentList;
    }
}