/**
 * @description Interface for ListMembers DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Created file                 |
 */
public interface IListMembersDAO extends DmlInterface {
     List<List_Member__c> getexistingListMembersWithMatchingList(Set<Id> listIds,Set<Id> listMemberIds,String accessLevel);
}