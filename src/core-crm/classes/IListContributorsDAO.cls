/**
 * @description Interface for List Contributors DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | carl.alvin.cabiles             | December 12, 2023     | DEPP-7186              | Created file                                             |
      |nicole.genon                    | February 1, 2024      | DEPP-7003              | Added getListContributorByUserID        |
      | neil.s.h.lesidan               | Feb 2, 2024           | DEPP-7005              | Adding method getListContributorByUserID                 |
 */
public interface IListContributorsDAO extends DmlInterface {
    List<List_Contributor__c> getListContributorByListID(Set<Id> listID, AccessLevel accessLevel);
    List<List_Contributor__c> getListContributorByUserID(Set<Id> listID, Set<Id> userId, AccessLevel accessLevel);
    List<List_Contributor__c> getRecordIdListContributorByListID(Set<Id> recordId, Set<Id> listID, AccessLevel accessLevel);
}
