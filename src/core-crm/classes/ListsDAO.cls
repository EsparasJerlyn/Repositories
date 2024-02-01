/**
 * @description DAO Class for List Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Created file                 |
 */
public inherited sharing class ListsDAO extends DmlBase implements IListsDAO{
    public static final Id ENGAGEMENT_OPPORTUNITY_RECTYPE_ID = Schema.SObjectType.List__c.getRecordTypeInfosByDeveloperName().get('Engagement_Opportunity').getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return List__c.SObjectType;
    } 
    
    public List<List__c> getListRecords(Integer recordsCount) {
        return [ //NOPMD
            SELECT Id, Due_Date__c from List__c
            WITH USER_MODE    
            LIMIT :recordsCount
        ];
    }

    public static IListsDAO newInstance()
	{
		return (IListsDAO) ImplementationSelector.DAO.newInstance(List__c.SObjectType);
	}

    public List<List__c> getListRecordsByRelatedEngagementOpportunitySetIds(Set<Id> recordIds,
    AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, Engagement_Opportunity__c, RecordTypeId, List_Name__c, List_Purpose__c, Stage__c, Column_1__c, Column_2__c, Column_3__c ' +
                'FROM List__c ' +
                'WHERE Engagement_Opportunity__c IN: recordIds ',
                accessLevel
        );
    }
} 