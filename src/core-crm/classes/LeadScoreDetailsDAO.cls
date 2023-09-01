/**
 * @description DAO Class for Lead_Score_Detail__c Object. Contains soql and constants related to the Lead_Score_Detail__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 */
public inherited sharing class LeadScoreDetailsDAO extends DmlBase implements ILeadScoreDetailsDAO{
    
    public Schema.SObjectType getSObjectType(){
		return Lead_Score_Detail__c.SObjectType;
	}

    public static ILeadScoreDetailsDAO newInstance(){
		return (ILeadScoreDetailsDAO) ImplementationSelector.DAO.newInstance(Lead_Score_Detail__c.SObjectType);
	}

    public static List<Lead_Score_Detail__c> getLeadScoreDetailByContactSetIds(
        Set<Id> contactIds,
		String accessLevel
    ) {
        return Database.query(
            'SELECT Id, Email, Work_Email__c, AccountId ' +
             'FROM Contact ' +
             'WHERE Id IN : contactIds ' +
			 'AND Parent_Person_Contact__c = null ' +
             String.escapeSingleQuotes(accessLevel)
        );
    }
}
