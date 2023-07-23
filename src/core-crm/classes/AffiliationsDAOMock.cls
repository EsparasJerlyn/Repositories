/**
 * @description Mock DAO Class for Affiliation Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                               |
 */
@isTest
public inherited sharing class AffiliationsDAOMock extends DmlBaseMock implements IAffiliationsDAO {
    
    public Map<Id, hed__Affiliation__c> affiliationMap;

    public AffiliationsDAOMock() {
        super(new Map<Id, hed__Affiliation__c>(), Schema.hed__Affiliation__c.SObjectType);
        this.affiliationMap = (Map<Id, hed__Affiliation__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Affiliation__c.SObjectType;
    }

    public List<hed__Affiliation__c> getAffiliationByContactIds(
        Set<Id> contactIds,
        String affilationStatus,
        String accessLevel
    ) {
        List<hed__Affiliation__c> affiliationList = new List<hed__Affiliation__c>();

        for (hed__Affiliation__c record : affiliationMap.values()) {
            if (contactIds.contains(record.hed__Contact__c)) {
                affiliationList.add(record);
            }
        }

        return affiliationList;
    }
}