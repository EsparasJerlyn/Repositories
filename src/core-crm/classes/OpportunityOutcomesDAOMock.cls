/**
 * @description Mock DAO Class for Opportunity Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | created file
 */
@isTest
public inherited sharing class OpportunityOutcomesDAOMock extends DmlBaseMock implements IOpportunityOutcomesDAO {
    public Map<Id, Opportunity_Outcome__c> opportunityOutcomesMap;

    public Schema.SObjectType getSObjectType() {
        return Opportunity_Outcome__c.SObjectType;
    }

    public OpportunityOutcomesDAOMock() {
        super(new Map<Id, Opportunity_Outcome__c>(), Schema.Opportunity_Outcome__c.SObjectType);
        this.opportunityOutcomesMap = (Map<Id, Opportunity_Outcome__c>) super.records;
    }

    public List<Opportunity_Outcome__c> getRecordsSortByCodeAsc() {
        return opportunityOutcomesMap.values();
    }

    public List<Opportunity_Outcome__c> getRecordsWithLikeCodeSortAsc(String codeIsLike) {
        return opportunityOutcomesMap.values();
    }
}
