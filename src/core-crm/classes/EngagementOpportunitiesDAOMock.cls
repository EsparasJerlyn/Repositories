/**
 * @description Mock DAO Class for Engagement Opportunity Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | nicole.genon                   | December 18, 2023     | DEPP-6949              | Created File                               |
 *    | carl.alvin.cabiles             | February 12, 2024     | DEPP-7134              | Added getEngagementOpportunitiesBySetNames |

 */
@isTest
public inherited sharing class EngagementOpportunitiesDAOMock  extends DmlBaseMock implements IEngagementOpportunitiesDAO{
    public Map<Id, Engagement_Opportunity__c> engagementOpportunityMap;
 
    public EngagementOpportunitiesDAOMock() {
        super(new Map<Id, Engagement_Opportunity__c>(), Schema.Engagement_Opportunity__c.SObjectType);
        this.engagementOpportunityMap = (Map<Id, Engagement_Opportunity__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Engagement_Opportunity__c.SObjectType;
    }

    public List<Engagement_Opportunity__c> getEngagementOpportunitiesBySetIds(Set<Id> engagementOpportunityIds, AccessLevel accessLevel) {
        List<Engagement_Opportunity__c> engagementOpportunityList = new List<Engagement_Opportunity__c>();

        for (Engagement_Opportunity__c record : engagementOpportunityMap.values()) {
            if (engagementOpportunityIds.contains(record.Id)) {
                engagementOpportunityList.add(record);
            }
        }

        return engagementOpportunityList;
    }

    public List<Engagement_Opportunity__c> getEngagementOpportunitiesBySetNames(Set<String> engagementOpportunityNames, AccessLevel accessLevel) {
        List<Engagement_Opportunity__c> engagementOpportunityList = new List<Engagement_Opportunity__c>();

        for (Engagement_Opportunity__c record : engagementOpportunityMap.values()) {
            if (engagementOpportunityNames.contains(record.Engagement_Opportunity_Name__c)) {
                engagementOpportunityList.add(record);
            }
        }

        return engagementOpportunityList;
    }
}