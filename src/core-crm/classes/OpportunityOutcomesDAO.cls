/**
 * @description DAO Class for Opportunity Outcome Object. Contains soql and constants related to the Opportunity Outcome object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | Created file
 */
public inherited sharing class OpportunityOutcomesDAO extends DmlBase implements IOpportunityOutcomesDAO {
    public static final Id RT_OPPTYOC_RPP_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName().get('Research_Partnership_Project').getRecordTypeId();
    public static final Id RT_OPPTYOC_INP_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName().get('IPU_Project').getRecordTypeId();
    public static final Id RT_OPPTYOC_RCP_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName().get('Research_Commercialisation_Project').getRecordTypeId();
    public static final Id RT_OPPTYOC_RCC_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName().get('StartUp').getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return Opportunity_Outcome__c.SObjectType;
    }

    public static IOpportunityOutcomesDAO newInstance() {
        return (IOpportunityOutcomesDAO) ImplementationSelector.DAO.newInstance(Opportunity_Outcome__c.SObjectType);
    }

    public static List<Opportunity_Outcome__c> getRecordsSortByCodeAsc() {
        return [
            SELECT Id, Code__c 
            FROM Opportunity_Outcome__c 
            WITH SYSTEM_MODE 
            ORDER BY Code__c ASC
            ];
    }

    public static List<Opportunity_Outcome__c> getRecordsWithLikeCodeSortAsc(String codeIsLike) {
        return [
            SELECT Id, Code__c 
            FROM Opportunity_Outcome__c 
            WHERE Code__c LIKE :codeIsLike 
            WITH SYSTEM_MODE 
            ORDER BY Code__c ASC
            ];
    }
}
