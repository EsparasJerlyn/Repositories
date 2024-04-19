/**
 * @description test class for DistributionSplitsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | neil.s.h.lesidan               | April 12, 2024        | DEPP-8392              | Created file                                 |
 */
@isTest
public inherited sharing class DistributionSplitsDAOMock extends DmlBaseMock implements IDistributionSplitsDAO {
    public Map<Id, Distribution_Split__c> distributionSplitMap;

    public Schema.SObjectType getSObjectType() {
        return Distribution_Split__c.SObjectType;
    }

    public DistributionSplitsDAOMock() {
        super(new Map<Id, Distribution_Split__c>(), Schema.Distribution_Split__c.SObjectType);
        this.distributionSplitMap = (Map<Id, Distribution_Split__c>) super.records;
    }

    public List<Distribution_Split__c> getDistributionSplitByDistributionManagement(Set<Id> ids, AccessLevel accessLevel){
        List<Distribution_Split__c> distributionSplitList = new List<Distribution_Split__c>();

        for (Distribution_Split__c record : distributionSplitMap.values()) {
            if (ids.contains(record.Distribution_Management__c)) {
                distributionSplitList.add(record);
            }
        }

        return distributionSplitList;
    }
}