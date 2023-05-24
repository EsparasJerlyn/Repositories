/**
 * @description Mock DAO Class for Opportunity Code Auto Number custom setting. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | created file
 */
@isTest
public inherited sharing class OpportunityCodeAutoNumbersDAOMock extends DmlBaseMock implements IOpportunityCodeAutoNumbersDAO {
    public Map<Id, Opportunity_Code_Auto_Number__c> opportunityCodeAutoNumMap;

    public Schema.SObjectType getSObjectType() {
        return Opportunity_Code_Auto_Number__c.SObjectType;
    }

    public OpportunityCodeAutoNumbersDAOMock() {
        super(new Map<Id, Opportunity_Code_Auto_Number__c>(), Schema.Opportunity_Code_Auto_Number__c.SObjectType);
        this.opportunityCodeAutoNumMap = (Map<Id, Opportunity_Code_Auto_Number__c>) super.records;
    }
}
