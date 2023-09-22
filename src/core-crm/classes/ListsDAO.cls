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

    public Schema.SObjectType getSObjectType() {
        return List__c.SObjectType;
    }
    
    public List<List__c> getListRecords(Integer recordsCount) {
        return [ //NOPMD
            SELECT Id from List__c
            WITH USER_MODE    
            LIMIT :recordsCount
        ];
    }

    public static IListsDAO newInstance()
	{
		return (IListsDAO) ImplementationSelector.DAO.newInstance(List__c.SObjectType);
	}
} 