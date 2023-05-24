/**
 * @description Interface for Opportunity DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods
 */
public interface IOpportunitiesDAO extends DmlInterface {
     List<Opportunity> getRecordsSortByOpportunityCodeAsc();
     List<Opportunity> getRecordsWithLikeOpportunityCodeSortAsc(String codeIsLike);
}