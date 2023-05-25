/**
 * @description DAO Class for Opportunity Object. Contains soql and constants related to the Opportunity object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods
 */
public inherited sharing class OpportunitiesDAO extends DmlBase implements IOpportunitiesDAO {
    public static final Id RT_OPPTY_RCO_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Commercialisation').getRecordTypeId();
    public static final Id RT_OPPTY_INPO_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('International_Projects_Unit').getRecordTypeId();
    public static final Id RT_OPPTY_RPO_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Research_Partnership').getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return Opportunity.SObjectType;
    }

    public static IOpportunitiesDAO newInstance() {
        return (IOpportunitiesDAO) ImplementationSelector.DAO.newInstance(Opportunity.SObjectType);
    }

    public static List<Opportunity> getRecordsSortByOpportunityCodeAsc() {
        return [
            SELECT Id, Opportunity_Code__c 
            FROM Opportunity 
            WITH SYSTEM_MODE 
            ORDER BY Opportunity_Code__c ASC
            ];
    }

    public static List<Opportunity> getRecordsWithLikeOpportunityCodeSortAsc(String codeIsLike) {
        return [
            SELECT Id, Opportunity_Code__c 
            FROM Opportunity 
            WHERE Opportunity_Code__c LIKE :codeIsLike 
            WITH SYSTEM_MODE 
            ORDER BY Opportunity_Code__c ASC
            ];
    }
}
