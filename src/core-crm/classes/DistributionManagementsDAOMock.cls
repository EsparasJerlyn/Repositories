/**
 * @description Mock DAO Class for Distribution Management Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                   |
*/
@isTest
public inherited sharing class DistributionManagementsDAOMock extends DmlBaseMock implements IDistributionManagementsDAO{
    public Map<Id, Distribution_Management__c> distributionManagementMap;
    
    public Schema.SObjectType getSObjectType() {
        return Distribution_Management__c.SObjectType;
    }
    
    public DistributionManagementsDAOMock() {
        super(new Map<Id, Distribution_Management__c>(), Schema.Distribution_Management__c.SObjectType);
        this.distributionManagementMap = (Map<Id, Distribution_Management__c>) super.records;
    }
    
    public List<Distribution_Management__c> getDistributionManagementByDesignationId(
        Set<Id> designationIds,
        AccessLevel accessLevel
    ){
        List<Distribution_Management__c> distributionManagementList = new List<Distribution_Management__c>();
        for (Distribution_Management__c record : distributionManagementMap.values()) {
            if (designationIds.contains(record.Designation__c)) {
                distributionManagementList.add(record);
            }
        }
        return distributionManagementList;
    }
}