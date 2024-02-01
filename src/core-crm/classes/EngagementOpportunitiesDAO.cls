/**
 * @description DAO Class for Engagement Opportunity Object. Contains soql and constants related to the Engagement Opportunity object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                       |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------|
      | nicole.genon                   | December 18, 2023     | DEPP-6949              | created file                                         |
 */
public inherited sharing class EngagementOpportunitiesDAO extends DmlBase implements IEngagementOpportunitiesDAO{
    public static final Id ALUMNI_ENGAGEMENT_RECTYPE_ID = Schema.SObjectType.Engagement_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Alumni_Engagement').getRecordTypeId();
    public static final Id CORPORATE_ENGAGEMENT_RECTYPE_ID = Schema.SObjectType.Engagement_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Corporate_Engagement').getRecordTypeId();
     
    public Schema.SObjectType getSObjectType(){
		return Engagement_Opportunity__c.SObjectType;
	}

    public static IEngagementOpportunitiesDAO newInstance(){
		return (IEngagementOpportunitiesDAO) ImplementationSelector.DAO.newInstance(Engagement_Opportunity__c.SObjectType);
	}

    public static List<Engagement_Opportunity__c> getEngagementOpportunitiesBySetIds(Set<Id> engagementOpportunityIds, AccessLevel accessLevel){
        return Database.query(
            'SELECT Id, Engagement_Opportunity_Name__c, Summary__c, Requestor_Name__c ' +
                'FROM Engagement_Opportunity__c ' +
                'WHERE Id IN: engagementOpportunityIds',
                accessLevel
        );
    }
}