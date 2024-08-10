/**
 * @description Mock DAO Class for Opportunity Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | created file
      | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added methods
      | carl.alvin.cabiles             | June 13, 2023         | DEPP-5409              | added methods
      | kenneth.f.alsay                | June 19, 2023         | DEPP-5434,5399         | added getRecordsWithOpportunity method
      | kenneth.f.alsay                | February 1, 2024      | DEPP-6938              | added getActiveCorporateOutcomes method
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
    public List<Opportunity_Outcome__c> getRecordsWithEqualEndDate(Date endDate){
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(endDate == record.End_Date__c){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }
    public List<Opportunity_Outcome__c> getRecordsWithNotEqualEndDate(Date endDate){
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(endDate != record.End_Date__c){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }
    public List<Opportunity_Outcome__c> getRecordsWithStartDate(Date startDate){
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(startDate == record.Start_Date__c){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }

    public List<Opportunity_Outcome__c> getRecordsWithOpportunity(List<Id> opportunityList) {
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(opportunityList.contains(record.Opportunity__c)){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }

    public List<Opportunity_Outcome__c> getRecordsWithPastDateAsDecommissionedDate(){
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(record.Decommissioned_Date__c <= System.today()){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }
    public List<Opportunity_Outcome__c> getRecordsWithFutureDateAsDecommissionedDate(){
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(record.Decommissioned_Date__c > System.today()){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }
    public List<Opportunity_Outcome__c> getActiveCorporateOutcomes(AccessLevel accessLevel){
        List<Opportunity_Outcome__c> opportunityOutcomeList = new List<Opportunity_Outcome__c>();
        for (Opportunity_Outcome__c record: opportunityOutcomesMap.values()){
            if(record.Outcome_Is_Active__c = true){
                opportunityOutcomeList.add(record);
            }
        }
        return opportunityOutcomeList;
    }
}