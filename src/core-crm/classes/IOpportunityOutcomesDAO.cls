/**
 * @description Interface for Opportunity Outcome DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
      |--------------------------------|-----------------------|------------------------|---------------------------------|
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | created file                    |
      | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added methods                   | 
      | carl.alvin.cabiles             | June 13, 2023         | DEPP-5409              | added methods
      | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | added getRecordsWithOpportunity |
      | kenneth.f.alsay                | February 1, 2024      | DEPP-6938              | added getActiveCorporateOutcomes|     
 */
public interface IOpportunityOutcomesDAO extends DmlInterface {
    List<Opportunity_Outcome__c> getRecordsSortByCodeAsc();
    List<Opportunity_Outcome__c> getRecordsWithLikeCodeSortAsc(String codeIsLike);
    List<Opportunity_Outcome__c> getRecordsWithEqualEndDate(Date endDate);
    List<Opportunity_Outcome__c> getRecordsWithNotEqualEndDate(Date endDate);
    List<Opportunity_Outcome__c> getRecordsWithStartDate(Date startDate);
    List<Opportunity_Outcome__c> getRecordsWithOpportunity(List<Id> opportunityList);
    List<Opportunity_Outcome__c> getRecordsWithFutureDateAsDecommissionedDate();
    List<Opportunity_Outcome__c> getRecordsWithPastDateAsDecommissionedDate();
    List<Opportunity_Outcome__c> getActiveCorporateOutcomes(AccessLevel accessLevel);
}
