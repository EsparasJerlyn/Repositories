/**
 * @description test class Update_Opp_Outcome_to_Decommissioned Record trigger Flow
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | June 13, 2023         | DEPP-5409              | Created file
 */
@isTest
	public class Update_Opp_Outcome_to_DecommissionedTest {
        private static string companyName = 'TestCompany';
        private static string projectName = 'project';
        private static Id recordTypeId = OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID;
        private static Integer numOfOppOutcome = 200;
        private static Date currentDate = System.today();
    
 @testSetup
        
    static void setup(){
        	//setup for auto number
        	Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            opptyCodeAutoNum.Commercialisation__c = 1;
            opptyCodeAutoNum.International_Projects_Unit__c = 1;
            opptyCodeAutoNum.Research_Partnership__c = 1;
            OpportunityCodeAutoNumbersDAO.newInstance().upsertRecords(
                new List<Opportunity_Code_Auto_Number__c>{opptyCodeAutoNum}, 
                false, 
                AccessLevel.USER_MODE
            );
            Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            oppOutcomeCodeAutoNum.Research_Partnership_Project__c = 1;
            oppOutcomeCodeAutoNum.IPU_Project__c = 1;
            oppOutcomeCodeAutoNum.Research_Commercialisation_Project__c = 1;
            oppOutcomeCodeAutoNum.Start_Up__c = 1;
            OpportunityOutcomeCodeAutoNumbersDAO.newInstance().upsertRecords(
                new List<Opportunity_Outcome_Code_Auto_Number__c>{oppOutcomeCodeAutoNum}, 
                false, 
                AccessLevel.USER_MODE
            );
        
            TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });
            System.runAs(TestDataFactory.getOperationsManager()){
                
            //creation of opportunity 
            List<Opportunity> opportunities = TestDataFactory.createOpportunityRecords(1, 'Opportunity Test', OpportunitiesDAO.IDENTIFY_STAGE); 
        	OpportunitiesDAO.newInstance().insertRecords(opportunities, false,AccessLevel.USER_MODE);
        	
            //creation of opportunity outcome
            Id opportunityId = OpportunitiesDAO.newInstance().getRecordsSortByOpportunityCodeAsc().iterator().next().Id;
            List<Opportunity_Outcome__c> opportunityOutcomeList = TestDataFactory.createOpportunityOutcome(
            numOfOppOutcome,
            recordTypeId,
            opportunityId
            );
           OpportunityOutcomesDAO.newInstance().insertRecords(opportunityOutcomeList, false,AccessLevel.USER_MODE);
        }
    }
    
    @isTest 
    private static void checkStageNameUponUpdate(){
        System.runAs(TestDataFactory.getOperationsManager()){  
        	List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance().getRecordsSortByCodeAsc(); 
        	System.assertEquals(true, opportunityOutcomeListToUpdate.Size() > 0, 'Empty');
            Test.startTest();  
            	updateDecommissionedDatetoPastDate(opportunityOutcomeListToUpdate);
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithPastDateAsDecommissionedDate();         
            System.assertEquals(true, oppOutcomes.Size() >0, 'Empty'); 
            for(Opportunity_Outcome__c oppOutcome : oppOutcomes){               
            	System.assertEquals(OpportunityOutcomesDAO.DECOMMISSIONED_STAGE, oppOutcome.Stage_Name__c,'Not equal');
            	System.assertEquals( null , oppOutcome.End_Date__c,'Not equal');
            }  
        }
    }
    
    @isTest 
    private static void checkEndDateForDecommissionedDateinFutureDate(){ 
        System.runAs(TestDataFactory.getOperationsManager()){  
        	List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance().getRecordsSortByCodeAsc(); 
        	Test.startTest();  
            	updateDecommissionedDatetoFutureDate(opportunityOutcomeListToUpdate);
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithFutureDateAsDecommissionedDate();         
            System.assertEquals(true, oppOutcomes.Size() >0, 'Empty');
            for(Opportunity_Outcome__c oppOutcome : oppOutcomes){                
                System.assertNotEquals(OpportunityOutcomesDAO.DECOMMISSIONED_STAGE, oppOutcome.Stage_Name__c,'Should Not be equal');
                System.assertEquals( null , oppOutcome.End_Date__c,'Not equal');
            }  
        }
    }
    
     private static void updateDecommissionedDatetoPastDate(List<Opportunity_Outcome__c> opportunityOutcomes){
        for(Opportunity_Outcome__c opp_outcome : opportunityOutcomes) {
            	opp_outcome.Decommissioned_Date__c = currentDate - 10;
            	opp_outcome.Decommissioned_Reason__c = 'Test Reason for Past Dates';
        }
       OpportunityOutcomesDAO.newInstance().updateRecords(opportunityOutcomes, false,AccessLevel.USER_MODE);
    }
    
    private static void updateDecommissionedDatetoFutureDate(List<Opportunity_Outcome__c> opportunityOutcomes){
        for(Opportunity_Outcome__c opp_outcome : opportunityOutcomes) {
            	opp_outcome.Decommissioned_Date__c = currentDate + 30;
            	opp_outcome.Decommissioned_Reason__c = 'Test Reason for future date';
        }
       OpportunityOutcomesDAO.newInstance().updateRecords(opportunityOutcomes, false,AccessLevel.USER_MODE);
    }
}