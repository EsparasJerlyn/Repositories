/**
 * @description Interface for Engagements DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 16, 2023          | DEPP-5594              | Created file
 */
public interface IEngagementsDAO extends DmlInterface {
    List<Engagement__c> getRecordsSortByEngagementCodeAsc();
    List<Engagement__c> getRecordsWithLikeEngagementCodeSortAsc(String codeIsLike);
}
