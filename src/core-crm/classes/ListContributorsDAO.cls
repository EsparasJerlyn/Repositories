/**
 * @description DAO Class for List Contributor Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | carl.alvin.cabiles             | December 12, 2023     | DEPP-7186              | Created file                                             |
      | nicole.genon                   | February 1, 2024      | DEPP-7003              | Added getListContributorByUserID     |
      | neil.s.h.lesidan               | Feb 2, 2024           | DEPP-7005              | Adding method getListContributorByUserID                 |
      | kenneth.f.alsay                | Feb 14, 2024          | DEPP-8040              | Added getAllListContributors                             |
 *
 */
public inherited sharing class ListContributorsDAO extends DmlBase implements IListContributorsDAO{
    public Schema.SObjectType getSObjectType() {
        return List_Contributor__c.SObjectType;
    }

    public static IListContributorsDAO newInstance() {
        return (IListContributorsDAO) ImplementationSelector.DAO.newInstance(List_Contributor__c.SObjectType);
    }

    public List<List_Contributor__c> getListContributorByListID(set<Id> listID, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, Name, Task_Due_Date__c, List_Contributor__c, List_Contributor__r.Name, List__c ' +
            'FROM List_Contributor__c ' +
            'WHERE List__c =: listID', accessLevel
        );
    }

    public List<List_Contributor__c> getListContributorByUserID(set<Id> listId, set<Id> userId, AccessLevel accessLevel) {
        return Database.query(
        'SELECT Id, List_Contributor__c, Name, List_Contributor__r.Name ' +
        'FROM List_Contributor__c ' +
        'WHERE List_Contributor__c IN :userId ' +
        'AND List__c IN :listId', accessLevel
        );
    }

    public List<List_Contributor__c> getRecordIdListContributorByListID(Set<Id> recordId, Set<Id> listID, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, List_Contributor__c, Name, List_Contributor__r.Name ' +
            'FROM List_Contributor__c ' +
            'WHERE Id IN :recordId ' +
            'AND List__c IN :listID',
            accessLevel
        );
    }

    public List<List_Contributor__c> getAllListContributors(Set<Id> listID, AccessLevel accessLevel){
        return Database.query(
            'SELECT Id, List_Contributor__c, List_Contributor__r.Name ' +
            'FROM List_Contributor__c ' +
            'WHERE List__c IN :listID',
            accessLevel
        );
    }
}
