/**
 * @description Interface for ListMembers DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                      |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------|
      | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Created file                                        |
      | kenneth.f.alsay                | January 26, 2024      | DEPP-6964              | Added getListMembersByStatus                        |
      | kenneth.f.alsay                | January 26, 2024      | DEPP-6953              | Added getListMembersByListIdAndStatus               |
      | nicole.genon                   | February 1, 2024      | DEPP-7003              | Added getexistingListMembersWithMatchingContactList |
 */
public interface IListMembersDAO extends DmlInterface {
     List<List_Member__c> getexistingListMembersWithMatchingList(Set<Id> listIds,Set<Id> listMemberIds,String accessLevel);
     List<List_Member__c> getListMembersByStatus(Integer recordCount, AccessLevel accessLevel, String status);
     List<List_Member__c> getexistingListMembersWithMatchingContactList(Set<Id> listIds,Set<Id> listMemberIds,String accessLevel);
     List<List_Member__c> getListMembersByListIdAndStatus(Set<Id> listId, String status, AccessLevel accessLevel);
     List<List_Member__c> getListMembersByActivityStatus(Integer recordCount, String status, AccessLevel accessLevel);
}
