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
        Set<Id> recordIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id, Contact__c ' +
             'FROM Lead_Score_Detail__c ' +
             'WHERE Contact__c IN: recordIds ' +
             'WITH ' +
             String.escapeSingleQuotes(accessLevel)
        );
    }
}
