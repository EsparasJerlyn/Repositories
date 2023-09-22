/**
 * @description DAO Class for List Member Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                 |
 */
public inherited sharing class ListMembersDAO extends DmlBase implements IListMembersDAO{
    public static final String ACCEPTED_ACTIVITY_STATUS = 'Accepted';
    public static final String DUPLICATE_ERROR_MESSAGE = 'List Member is already in the list';
    public Schema.SObjectType getSObjectType() {
        return List_Member__c.SObjectType;
    }
    
    public List<List_Member__c> getexistingListMembersWithMatchingList(Set<Id> listIds,Set<Id> listMemberIds,String accessLevel) {
        return Database.query(
            'SELECT  Id,List_Member__c,List__c, Name ' +
                'FROM List_Member__c ' +
                'WHERE List_Member__c != null ' +
                'AND List__c != null ' +
                'AND (List__c in :listIds ' +
                'OR List_Member__c in :listMemberIds) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static IListMembersDAO newInstance()
	{
		return (IListMembersDAO) ImplementationSelector.DAO.newInstance(List_Member__c.SObjectType);
	}
} 