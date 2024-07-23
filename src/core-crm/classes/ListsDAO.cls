/**
 * @description DAO Class for List Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                             |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
 *    | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Created file                                               |
 *    | neil.s.h.lesidan               | Feb 6, 2024           | DEPP-6510              | Adding method getListByRecordIdName                        |
 *    | ryan.j.a.dela.cruz             | April 30, 2024        | N/A - ST FIX           | Convert getListRecords to Database.query and code cleanup  |
 */
public inherited sharing class ListsDAO extends DmlBase implements IListsDAO {
    public static final Id ENGAGEMENT_OPPORTUNITY_RECTYPE_ID = Schema.SObjectType.List__c.getRecordTypeInfosByDeveloperName()
        .get('Engagement_Opportunity')
        .getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return List__c.SObjectType;
    }

    public List<List__c> getListRecords(Integer recordsCount, AccessLevel accessLevel) {
        if (recordsCount == null) {
            return new List<List__c>();
        }

        return Database.query(
            'SELECT Id, List_Name__c, Due_Date__c FROM List__c LIMIT :recordsCount ',
            accessLevel
        );
    }

    public static IListsDAO newInstance() {
        return (IListsDAO) ImplementationSelector.DAO.newInstance(List__c.SObjectType);
    }

    public List<List__c> getListRecordsByRelatedEngagementOpportunitySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Engagement_Opportunity__c, RecordTypeId, List_Name__c, List_Purpose__c, Stage__c, Column_1__c, Column_2__c, Column_3__c ' +
                'FROM List__c ' +
                'WHERE Engagement_Opportunity__c IN: recordIds ',
            accessLevel
        );
    }

    public List<List__c> getListByRecordIdName(
        Id recordId,
        String filterString,
        AccessLevel accessLevel
    ) {
        if (String.isEmpty(filterString)) {
            return new List<List__c>();
        }

        String toFilterString = '%' + filterString + '%';
        return Database.query(
            'SELECT Id, Name, List_Name__c, Column_1__c, Column_2__c, Column_3__c, Column_4__c, Column_5__c, ' +
                'Column_6__c, Column_7__c, Column_8__c, Column_9__c, Column_10__c ' +
                'FROM List__c ' +
                'WHERE (List_Name__c LIKE :toFilterString OR List_Name__c = :toFilterString) ' +
                'AND Id != :recordId ',
            accessLevel
        );
    }
}
