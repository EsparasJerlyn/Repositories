/**
 * @description DAO Class for List Member Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                 |
      | kenneth.f.alsay                | January 26, 2024      | DEPP-6964              | Added getListMembersByStatus |
 */
public inherited sharing class ListMembersDAO extends DmlBase implements IListMembersDAO{
    public static final String ACCEPTED_ACTIVITY_STATUS = 'Accepted';
    public static final String DUPLICATE_ERROR_MESSAGE = 'List Member is already in the list';
    public Schema.SObjectType getSObjectType() {
        return List_Member__c.SObjectType; 
    } 

    public List<List_Member__c> getexistingListMembersWithMatchingList(Set<Id> listIds,Set<Id> listMemberIds,String accessLevel) {
        return Database.query(
            'SELECT Id, List_Member__c, List__c, Name, List_Member__r.Name, ' +
                'Email__c, Mobile__c, Column_1_Value__c, Column_2_Value__c, ' +
                'Column_3_Value__c, Column_4_Value__c, Column_5_Value__c, Column_6_Value__c, Column_7_Value__c, ' +
                'List_Contributor__c, List_Member_Status__c ' +
                'FROM List_Member__c ' +
                'WHERE List_Member__c != null ' +
                'AND List__c != null ' +
                'AND (List__c in :listIds ' +
                'OR List_Member__c in :listMemberIds) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<List_Member__c> getListMembersByStatus(
        Integer recordCount, 
        AccessLevel accessLevel,
        String status){
        return Database.query(
            'SELECT Id, List_Member_Status__c ' +
                'FROM List_Member__c ' +
                'WHERE List_Member_Status__c =: status ' +
                ' LIMIT :recordCount',
                accessLevel
        );        
    }

    public static IListMembersDAO newInstance()
	{
		return (IListMembersDAO) ImplementationSelector.DAO.newInstance(List_Member__c.SObjectType);
	}
}