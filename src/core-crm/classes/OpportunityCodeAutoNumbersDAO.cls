/**
 * @description DAO Class for Opportunity Auto Number custom setting
 * Contains soql and constants related to the Opportunity Auto Number custom setting
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | Created file
 */
public inherited sharing class OpportunityCodeAutoNumbersDAO extends DmlBase implements IOpportunityCodeAutoNumbersDAO {
    public Schema.SObjectType getSObjectType() {
        return Opportunity_Code_Auto_Number__c.SObjectType;
    }

    public static IOpportunityCodeAutoNumbersDAO newInstance() {
        return (IOpportunityCodeAutoNumbersDAO) ImplementationSelector.DAO.newInstance(Opportunity_Code_Auto_Number__c.SObjectType);
    }

    public static Opportunity_Code_Auto_Number__c getOrganizationalDefaults() {
        return Opportunity_Code_Auto_Number__c.getOrgDefaults();
    }
}
