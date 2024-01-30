/**
 * @description Interface for Engagement Opportunity DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
      | nicole.genon                   | December 18, 2023     | DEPP-6949              | Created File                              |
 */
public interface IEngagementOpportunitiesDAO extends DmlInterface{
     List<Engagement_Opportunity__c> getEngagementOpportunitiesBySetIds(
               Set<Id> engagementOpportunityIds,
               AccessLevel accessLevel);
} 