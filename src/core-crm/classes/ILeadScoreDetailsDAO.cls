/**
 * @description Interface for LeadScoreDetailsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 */
public interface ILeadScoreDetailsDAO extends DmlInterface{

    List<Lead_Score_Detail__c> getLeadScoreDetailByContactSetIds(
        Set<Id> recordIds,    
        String accessLevel
    );
}
