@isTest
public class Update_Opp_Outcome_to_CompletedTest {
   	private static string companyName = 'TestCompany';
    private static string projectName = 'project';
    private static string code= '0';
    private static Id recordTypeId = OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID;
    private static Integer numOfOppOutcome = 5;
    private static Date currentDate = System.today();
 @testSetup
    static void setupOpportunity(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager', 'QUT_Operations_Manager'});
        List<Opportunity> opportunities = TestDataFactory.createOpportunityRecords(1, 'OpportunityTest', OpportunitiesDAO.IDENTIFY_STAGE);
        OpportunitiesDAO.newInstance().insertRecords(opportunities, false,AccessLevel.USER_MODE);
    }
	
    static void setupOpportunityOutcome(){
        Id opportunityId = OpportunitiesDAO.newInstance().getRecordsBySetName(new Set<String>{'Opportunity Test'}).iterator().next().Id;
        
		List<Opportunity_Outcome__c> opportunityList = TestDataFactory.createOpportunityOutcome(
            numOfOppOutcome,
        	recordTypeId,
 			opportunityId
        );
        
        OpportunityOutcomesDAO.newInstance().insertRecords(opportunityList, false,AccessLevel.USER_MODE);
    }
 
    @isTest 
    private static void checkStageNameForNewOpportunityOutcome(){ 
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()){  
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithEqualEndDate(currentDate);          
            for(Opportunity_Outcome__c oppOutcome : oppOutcomes){                
                System.assertEquals(OpportunityOutcomesDAO.COMPLETED_STAGE, oppOutcome.Stage_Name__c,'Not equal');
            }  
        }
    }
     @isTest 
    private static void checkStageNameForUpdatedOpportunityOutcomeForOperationsManager(){ 
        System.runAs(TestDataFactory.getOperationsManager()){  
        	List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithEqualEndDate(currentDate);
            Test.startTest();  
            updateEndDate(oppOutcomes);
            Test.stopTest();
            List<Opportunity_Outcome__c> opportunityOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithEqualEndDate(currentDate);         
            for(Opportunity_Outcome__c oppOutcome : opportunityOutcomes){                
                System.assertNotEquals(OpportunityOutcomesDAO.COMPLETED_STAGE, oppOutcome.Stage_Name__c,'Should Not be equal');
            }  
        }
    }
    
    @isTest 
    private static void checkStageNameForUpdatedOpportunityOutcome(){ 
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()){  
        	List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance().getRecordsWithNotEqualEndDate(currentDate); 
        	Test.startTest();  
            updateEndDate(opportunityOutcomeListToUpdate);
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithEqualEndDate(currentDate);         
            for(Opportunity_Outcome__c oppOutcome : oppOutcomes){                
                System.assertEquals(OpportunityOutcomesDAO.COMPLETED_STAGE, oppOutcome.Stage_Name__c,'Not equal');
            }  
        }
    }
    
     private static void updateEndDate(List<Opportunity_Outcome__c> opportunityOutcomes){
        List<Opportunity_Outcome__c> oppOutcomesToUpdate = new List<Opportunity_Outcome__c>();
        
        for(Opportunity_Outcome__c opp_outcome : oppOutcomesToUpdate) {
            opp_outcome.End_Date__c = currentDate -1;
        }
       OpportunityOutcomesDAO.newInstance().updateRecords(oppOutcomesToUpdate, false,AccessLevel.USER_MODE);
    }
}