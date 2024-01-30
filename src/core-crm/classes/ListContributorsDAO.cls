/**
 * @description DAO Class for List Contributor Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | December 12, 2023     | DEPP-7186              | Created file                 |
 */
public inherited sharing class ListContributorsDAO extends DmlBase implements IListContributorsDAO{
     public Schema.SObjectType getSObjectType() {
          return List_Contributor__c.SObjectType;
      }

      public List<List_Contributor__c> getListContributorByListID(set<Id> listID, AccessLevel accessLevel) {
          return Database.query(
              'SELECT Id, Task_Due_Date__c ' +
              'FROM List_Contributor__c ' +
              'WHERE List__c =: listID', accessLevel
          );
  
     }
 
     public static IListContributorsDAO newInstance() {
          return (IListContributorsDAO) ImplementationSelector.DAO.newInstance(List_Contributor__c.SObjectType);
     }
     
} 