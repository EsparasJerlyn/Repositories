/**
 * @description Interface for Opportunity DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods
 *    | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added getRecordsBySetName method
 */
public interface IOpportunitiesDAO extends DmlInterface {
    List<Opportunity> getRecordsSortByOpportunityCodeAsc();
    List<Opportunity> getRecordsWithLikeOpportunityCodeSortAsc(String codeIsLike);
    List<Opportunity> getRecordsBySetName(Set<String> names);
    List<Opportunity> getRecordsLikeName(String name, Boolean wildCardBeforeName, String wildCard);
    List<Opportunity> getRecordsByStageName(String stageName);
    List<Opportunity> getRecordsBySetIds(Set<Id> ids);
    List<Opportunity> getOpportunityByAccountIds(
        Set<Id> accountIds,
        String accessLevel
    );
    List<Opportunity> getOpportunityByRecordTypeIds(
        Set<Id> recordTypeIds,
        AccessLevel accessLevel
    );
} 
