/**
 * @description DAO Class for Opportunity Object. Contains soql and constants related to the Opportunity object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
      |--------------------------------|-----------------------|------------------------|----------------------------------------|
      | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file                           |
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods                          |
      | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added getRecordsBySetName method       |
      | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | added getRecordsByStartingName method  |
 */
public inherited sharing class OpportunitiesDAO extends DmlBase implements IOpportunitiesDAO {
    public static final Id COMMERCIALIZATION_RECTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Commercialisation').getRecordTypeId();
    public static final Id INTERNATIONALPROJECTSUNIT_RECTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('International_Projects_Unit').getRecordTypeId();
    public static final Id RESEARCHPARTNERSHIP_RECTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Research_Partnership').getRecordTypeId();
    public static final String IDENTIFY_STAGE = 'Identify';
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

    public static List<Opportunity> getRecordsBySetName(Set<String> names) {
        return [
            SELECT Id 
            FROM Opportunity 
            WHERE Name IN: names 
            WITH USER_MODE
            ];
    }

    public List<Opportunity> getRecordsLikeName(String name, boolean wildCardBeforeName, String wildCard) {
		name = wildCardBeforeName ? (wildCard + name) : (name + wildCard);                
        return [
            SELECT Id 
            FROM Opportunity 
            WHERE Name LIKE :name 
            WITH USER_MODE
        ];
    } 
}