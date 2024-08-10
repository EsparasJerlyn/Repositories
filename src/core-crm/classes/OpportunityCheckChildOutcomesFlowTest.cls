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
    @testSetup 
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserCorporatePartnershipsManager();
        Test.stopTest();

        Id corporateOppId = OpportunitiesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        Id corporateOppOutcomeId = OpportunityOutcomesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
            List<Opportunity> corpPartnershipOpp = TestDataFactory.createOpportunityRecords(200, 'Opportunity', 'Negotiate');
            for(Opportunity opp : corpPartnershipOpp){
                opp.RecordTypeId = corporateOppId;
            }
            OpportunitiesDAO.newInstance().insertRecords(corpPartnershipOpp, false, AccessLevel.USER_MODE);
            
            List<Opportunity_Outcome__c> corpPartnershipOutcome = TestDataFactory.createOpportunityOutcome(200, corporateOppOutcomeId, null);
            
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
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
            Test.startTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getActiveCorporateOutcomes(AccessLevel.USER_MODE);
            Set<Id> opportunityIds = new Set<Id>();
            for(Opportunity_Outcome__c outcome : oppOutcomes){
                opportunityIds.add(outcome.Opportunity__c);
            }
            List<Opportunity> oppList = OpportunitiesDAO.newInstance().getRecordsBySetIds(opportunityIds);
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            for(Opportunity opp : oppList){
                oppToUpdate.add(new Opportunity (
                    Id = opp.Id,
                    StageName = 'Proposal'));
            }
            OpportunitiesDAO.newInstance().updateRecords(oppToUpdate, false, AccessLevel.USER_MODE);
            List<Opportunity> results = OpportunitiesDAO.newInstance().getRecordsByStageName('Proposal');
            System.assertEquals(100, results.size(), 'List must be 100');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testOpportunityWithOutActiveOutcomes(){
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
            Test.startTest();
            List<Opportunity> oppList = OpportunitiesDAO.newInstance().getRecordsByStageName('Negotiate');
            for(Opportunity opp : oppList){
                opp.StageName = 'Proposal';
            }
            OpportunitiesDAO.newInstance().updateRecords(oppList, false, AccessLevel.USER_MODE);
            List<Opportunity> results = OpportunitiesDAO.newInstance().getRecordsByStageName('Negotiate');
            System.assertEquals(100, results.size(), 'List must be 100');
            Test.stopTest();
        }
    }   
}