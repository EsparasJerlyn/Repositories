/**
 * @description DAO Class for Opportunity Outcome Code Auto Number custom setting
 * Contains soql and constants related to the Opportunity Outcome object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | Created file
 */
public inherited sharing class OpportunityOutcomeCodeAutoNumbersDAO extends DmlBase implements IOpportunityOutcomeCodeAutoNumbersDAO {
    public Schema.SObjectType getSObjectType() {
        return Opportunity_Outcome_Code_Auto_Number__c.SObjectType;
    }

    public static IOpportunityOutcomeCodeAutoNumbersDAO newInstance() {
        return (IOpportunityOutcomeCodeAutoNumbersDAO) ImplementationSelector.DAO.newInstance(Opportunity_Outcome_Code_Auto_Number__c.SObjectType);
    }

    public static Opportunity_Outcome_Code_Auto_Number__c getOrganizationalDefaults() {
        return Opportunity_Outcome_Code_Auto_Number__c.getOrgDefaults();
    }
}
