/**
 * @description Interface for List Contributors DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | December 12, 2023     | DEPP-7186              | Created file                 |
 */
public interface IListContributorsDAO extends DmlInterface {
     List<List_Contributor__c> getListContributorByListID(Set<Id> listID, AccessLevel accessLevel);
} 