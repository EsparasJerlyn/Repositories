/**
 * @description Mock DAO Class for List Member Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | carl.alvin.cabiles             | September 18, 2023    | DEPP-6510              | Created file                        |
 *    | ryan.j.a.dela.cruz             | February 5, 2024      | DEPP-7005              | Added method getListByRecordIdName  |
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
    
    public List<List__c> getListByRecordIdName(
        Id recordId,
        String filterString,
        AccessLevel accessLevel
    ) {
        List<List__c> listRecList = new List<List__c>();

        for (List__c record : listsMap.values()) {
            if ((record.Name.startsWith(filterString) || record.Name.endsWith(filterString)) && recordId != record.Id) {
                List__c tempList = new List__c();

                // Deserialize JSON to add Name and CreatedDate
                String listString = '{"attributes":{"type":"List__c","url":"/services/data/v59.0/sobjects/List__c/'+record.Id+'"},' +
                '"Id":"'+record.Id+'","Name":"'+record.Name+'","CreatedDate":"'+String.valueOf(System.today())+'"}';
                tempList = (List__c)JSON.deserialize(listString, List__c.class);
                tempList.RecordTypeId = record.RecordTypeId;
                tempList.Stage__c = record.Stage__c;
                listRecList.add(tempList);
            }
        }

        return listRecList;
    }
}