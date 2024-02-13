/**
 * @description Interface for Engagement Opportunity DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
      | nicole.genon                   | December 18, 2023     | DEPP-6949              | Created File                              |
      | carl.alvin.cabiles             | February 12, 2024     | DEPP-7134              | Add getEngagementOpportunitiesBySetNames  |
 */
public interface IEngagementOpportunitiesDAO extends DmlInterface{
     List<Engagement_Opportunity__c> getEngagementOpportunitiesBySetIds(
               Set<Id> engagementOpportunityIds,
               AccessLevel accessLevel);
     List<Engagement_Opportunity__c> getEngagementOpportunitiesBySetNames(
          Set<String> engagementOpportunityNames, AccessLevel accessLevel);
} 
