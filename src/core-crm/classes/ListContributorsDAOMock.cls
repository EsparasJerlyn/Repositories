/**
 * @description Mock DAO Class for List Member Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
 *    | neil.s.h.lesidan               | Feb 2, 2024           | DEPP-7005              | Created file                                       |
 *    | nicole.genon                   | Feb 3, 2024           | DEPP-7003              | Added getListContributorByUserID                   |
 *    | kenneth.f.alsay                | Feb 14, 2024          | DEPP-8040              | Added getAllListContributors                       |
 *    |                                |                       |                        |                                                    |
 */
@isTest
public inherited sharing class ListContributorsDAOMock extends DmlBaseMock implements IListContributorsDAO {
    public Map<Id, List_Contributor__c> listContributorsMap;

    public Schema.SObjectType getSObjectType() {
        return List_Contributor__c.SObjectType;
    }

    public ListContributorsDAOMock() {
        super(new Map<Id, List_Contributor__c>(), Schema.List_Contributor__c.SObjectType);
        this.listContributorsMap = (Map<Id, List_Contributor__c>) super.records;
    }

    public List<List_Contributor__c> getListContributorByListID(Set<Id> listID, AccessLevel accessLevel) {
        List<List_Contributor__c> listContributorRecords = new List<List_Contributor__c>();
        for (List_Contributor__c record : listContributorsMap.values()) {
            if (record.List__c != null && listID.contains(record.List__c)) {
                listContributorRecords.add(record);
            }
        }

        return listContributorRecords;
    }

    public List<List_Contributor__c> getListContributorByUserID(set<Id> listId, set<Id> userId, AccessLevel accessLevel) {
        List<List_Contributor__c> listContributorRecords = new List<List_Contributor__c>();
        for (List_Contributor__c record : listContributorsMap.values()) {
            if (record.List__c != null && record.List_Contributor__c != null &&
                listId.contains(record.List__c) && userId.contains(record.List_Contributor__c)) {
                listContributorRecords.add(record);
            }
        }

        return listContributorRecords;
    }

    public List<List_Contributor__c> getRecordIdListContributorByListID(Set<Id> recordId, Set<Id> listID, AccessLevel accessLevel) {
        List<List_Contributor__c> listContributorRecords = new List<List_Contributor__c>();
        for (List_Contributor__c record : listContributorsMap.values()) {
            if (record.List__c != null && record.Id != null &&
                listId.contains(record.List__c) && recordId.contains(record.Id)) {
                listContributorRecords.add(record);
            }
        }

        return listContributorRecords;
    }

    public List<List_Contributor__c> getAllListContributors(Set<Id> listID, AccessLevel accessLevel){
        List<List_Contributor__c> listContributorRecords = new List<List_Contributor__c>();
        for (List_Contributor__c record : listContributorsMap.values()) {
            if (record.List__c != null && record.Id != null &&
                listId.contains(record.List__c)) {
                listContributorRecords.add(record);
            }
        }

        return listContributorRecords;
    }
}
