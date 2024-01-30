/**
 * @description Mock DAO Class for List Member Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    |carl.alvin.cabiles              | September 18, 2023    | DEPP-6510              | Created file
 */
@isTest
public inherited sharing class ListsDAOMock extends DmlBaseMock implements IListsDAO {
    public Map<Id, List__c> listsMap;

    public Schema.SObjectType getSObjectType() {
        return List__c.SObjectType;
    } 

    public ListsDAOMock() {
        super(new Map<Id, List__c>(), Schema.List__c.SObjectType);
        this.listsMap = (Map<Id, List__c>) super.records;
    }

    public List<List__c> getListRecords(Integer recordscount) {
        List<List__c> listRecords = new List<List__c>();
        Integer count = 0;
        for (List__c record : listsMap.values()) {
            if(count <recordscount){
                listRecords.add(record);
                count+=1;
            }
        }
        return listRecords;
    }

    public List<List__c> getListRecordsByRelatedEngagementOpportunitySetIds(Set<Id> recordIds,
    AccessLevel accessLevel) {
        List<List__c> listRecList = new List<List__c>();

        for (List__c record : listsMap.values()) {
            if (recordIds.contains(record.Engagement_Opportunity__c)) {
                listRecList.add(record);
            }
        }

        return listRecList;
    }
}
