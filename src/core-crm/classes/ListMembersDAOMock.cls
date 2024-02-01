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
public inherited sharing class ListMembersDAOMock extends DmlBaseMock implements IListMembersDAO {
    public Map<Id, List_Member__c> listMembersMap;

    public Schema.SObjectType getSObjectType() {
        return List_Member__c.SObjectType;
    }

    public ListMembersDAOMock() {
        super(new Map<Id, List_Member__c>(), Schema.List_Member__c.SObjectType);
        this.listMembersMap = (Map<Id, List_Member__c>) super.records;
    }

    public List<List_Member__c> getexistingListMembersWithMatchingList(Set<Id> listIds,Set<Id> listMemberIds,String accessLevel) {
        List<List_Member__c> listMemberRecords = new List<List_Member__c>();
        for (List_Member__c record : listMembersMap.values()) {
            if (record.List__c != null && record.List_Member__c != null &&
                (listIds.contains(record.List__c)|| listMemberIds.contains(record.List_Member__c))) {
                listMemberRecords.add(record);
            }
        }
        return listMemberRecords;
    }

    public List<List_Member__c> getListMembersByStatus(
        Integer recordCount, 
        AccessLevel accessLevel,
        String status){
        List<List_Member__c> listMemberRecords = new List<List_Member__c>();

        Integer count = 0;
        for (List_Member__c record : listMembersMap.values()) {
            if (record.List_Member_Status__c == status) {
                listMemberRecords.add(record);
                count++;
            }
            if(count==recordCount){
                break;
            }
        }
        return listMemberRecords;       
    }

    
}
