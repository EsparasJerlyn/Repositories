/**
 * @description Interface for LeadScoreDetailsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 *    | eccarius.munoz                 | October 04, 2023      |DEPP-5866               | Added method to get by con/lead     |
 */
public interface ILeadScoreDetailsDAO extends DmlInterface{

    List<Lead_Score_Detail__c> getLeadScoreDetailWithLimit(
        Integer recordsCount
    );

    List<Lead_Score_Detail__c> getLeadScoreDetailsByContactOrLeadId(
        Set<Id> contactLeadIdSet, 
        AccessLevel accessLevel)
    ;

    Database.QueryLocator getLeadScoreDetailsWithContactOrLead();
    
}
