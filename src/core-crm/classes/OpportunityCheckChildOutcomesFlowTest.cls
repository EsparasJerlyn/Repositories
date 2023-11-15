/**
* @description Test Class for Opportunity - Check Child Outcomes Flow
*
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                   | Change Summary               |
     |--------------------------------|-----------------------|------------------------|------------------------------|
     | kenneth.f.alsay                | November 15,2023      | DEPP-6938              | Created file                 |
*/
@isTest
public class OpportunityCheckChildOutcomesFlowTest {
    @testSetup static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Corporate_Partnership_Manager'});
        Id corporateOppId = OpportunitiesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        Id corporateOppOutcomeId = OpportunityOutcomesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        System.RunAs(TestDataFactory.getCorporatePartnershipsManager()){
            List<Opportunity> corpPartnershipOpp = TestDataFactory.createOpportunityRecords(200, 'Opportunity', 'Negotiate');
            for(Opportunity opp : corpPartnershipOpp){
                opp.RecordTypeId = corporateOppId;
            }
            OpportunitiesDAO.newInstance().insertRecords(corpPartnershipOpp, false, AccessLevel.USER_MODE);
            
            List<Opportunity_Outcome__c> corpPartnershipOutcome = TestDataFactory.createOpportunityOutcome(200, corporateOppOutcomeId, null);
            
            Integer oppNum = 0;
            for(Integer i = 0; i<100; i++){
                corpPartnershipOutcome[i].Opportunity__c = corpPartnershipOpp[i].Id;
                corpPartnershipOutcome[i].Outcome_Tangible_Value__c = 200;
                corpPartnershipOutcome[i].Outcome_Is_Active__c = true;
            }
            for(Integer i = 100; i<200; i++){
                corpPartnershipOutcome[i].Opportunity__c = corpPartnershipOpp[i].Id;
                corpPartnershipOutcome[i].Outcome_Tangible_Value__c = 200;
                corpPartnershipOutcome[i].Outcome_Is_Active__c = false;
                corpPartnershipOpp[i].Amount = 200;
            }
            OpportunityOutcomesDAO.newInstance().insertRecords(corpPartnershipOutcome, false, AccessLevel.USER_MODE);
        }
        
    }
    @isTest
    static void testOpportunityWithActiveOutcomes(){
        System.RunAs(TestDataFactory.getCorporatePartnershipsManager()){
            Test.startTest();
            List<Opportunity_Outcome__c> oppOutcomes = [SELECT Id, Opportunity__c FROM Opportunity_Outcome__c WHERE Outcome_Is_Active__c = true];
            Set<Id> opportunityIds = new Set<Id>();
            for(Opportunity_Outcome__c outcome : oppOutcomes){
                opportunityIds.add(outcome.Opportunity__c);
            }
            Set<Id> oppOutcomeIds = (new Map<Id,Opportunity_Outcome__c>(oppOutcomes)).keySet();
            List<Opportunity> oppList = [SELECT Id, Name, StageName FROM Opportunity WHERE Id IN: opportunityIds];
            for(Opportunity opp : oppList){
                opp.StageName = 'Proposal';
            }
            OpportunitiesDAO.newInstance().updateRecords(oppList, false, AccessLevel.USER_MODE);
            List<Opportunity> results = [SELECT Id, Name, StageName FROM Opportunity WHERE StageName = 'Proposal'];
            System.assertEquals(100, results.size(), 'List must be 100');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testOpportunityWithOutActiveOutcomes(){
        System.RunAs(TestDataFactory.getCorporatePartnershipsManager()){
            Test.startTest();
            List<Opportunity> oppList = [SELECT Id, Name, StageName FROM Opportunity WHERE StageName = 'Negotiate'];
            for(Opportunity opp : oppList){
                opp.StageName = 'Proposal';
            }
            OpportunitiesDAO.newInstance().updateRecords(oppList, false, AccessLevel.USER_MODE);
            List<Opportunity> results = [SELECT Id, Name, StageName FROM Opportunity WHERE StageName = 'Negotiate'];
            System.assertEquals(100, results.size(), 'List must be 100');
            Test.stopTest();
        }
    }
    
}