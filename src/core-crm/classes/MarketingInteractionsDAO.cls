/**
 * @description DAO Class for Marketing_Interaction__c Object. Contains SOQL and Constants related to the Marketing_Interaction__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | September 18, 2023    |DEPP-6667               | Created File                        |
 */
public inherited sharing class MarketingInteractionsDAO extends DmlBase implements IMarketingInteractionsDAO {
    public static IMarketingInteractionsDAO newInstance() {
        return (IMarketingInteractionsDAO) ImplementationSelector.DAO.newInstance(Marketing_Interaction__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Marketing_Interaction__c.SObjectType;
    }

    public static List<Marketing_Interaction__c> getMarketingInteractionByApplicantIds(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    ) {
        String marketingInteractionQuery = 
            'SELECT' +
            ' Id, Contact__c, Lead_Source__c' +
            ' FROM' + 
            ' Marketing_Interaction__c' +
            ' WHERE' +
            ' Contact__c IN:applicantIds' +
            ' AND Lead_Source__c != \'QTAC\'';
        
        return Database.query(marketingInteractionQuery, accessLevel);
    }
}
