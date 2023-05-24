/**
 * @description Mock DAO Class for Opportunity Outcome Code Auto Number custom setting. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | created file
 */
@isTest
public inherited sharing class OpportunityOutcomeCodeAutoNumbersDAOMock extends DmlBaseMock implements IOpportunityOutcomeCodeAutoNumbersDAO {
    public Map<Id, Opportunity_Outcome_Code_Auto_Number__c> opportunityOutcomesCodeAutoNumMap;

    public Schema.SObjectType getSObjectType() {
        return Opportunity_Outcome_Code_Auto_Number__c.SObjectType;
    }

    public OpportunityOutcomeCodeAutoNumbersDAOMock() {
        super(new Map<Id, Opportunity_Outcome_Code_Auto_Number__c>(), Schema.Opportunity_Outcome_Code_Auto_Number__c.SObjectType);
        this.opportunityOutcomesCodeAutoNumMap = (Map<Id, Opportunity_Outcome_Code_Auto_Number__c>) super.records;
    }
}
