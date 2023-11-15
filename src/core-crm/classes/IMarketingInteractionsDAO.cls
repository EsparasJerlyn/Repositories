/**
 * @description Interface for Marketing Interactions DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | Sept 18, 2023         | DEPP-6667              | Created file                 |
 */
public interface IMarketingInteractionsDAO extends DmlInterface{
    List<Marketing_Interaction__c> getMarketingInteractionByApplicantIds(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    );

    List<Marketing_Interaction__c> getMarketingInteractionsByContactOrLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );

    Database.QueryLocator queryLocatorGetMarketingInteractionsByContactOrLeadIds(
        Set<Id> recordIds
    );
    
}
