/**
 * @description Interface for Opportunity Outcome DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | created file
      | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added methods
 */
public interface IOpportunityOutcomesDAO extends DmlInterface {
     List<Opportunity_Outcome__c> getRecordsSortByCodeAsc();
     List<Opportunity_Outcome__c> getRecordsWithLikeCodeSortAsc(String codeIsLike);
     List<Opportunity_Outcome__c> getRecordsWithEqualEndDate(Date endDate);
     List<Opportunity_Outcome__c> getRecordsWithNotEqualEndDate(Date endDate);
     List<Opportunity_Outcome__c> getRecordsWithStartDate(Date startDate);

}