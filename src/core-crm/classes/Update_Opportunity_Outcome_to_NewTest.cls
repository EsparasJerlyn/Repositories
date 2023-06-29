@isTest
public class Update_Opportunity_Outcome_to_NewTest {
   	private static string companyName = 'TestCompany';
    private static string projectName = 'project';
    private static string code= '0';
    private static Id recordTypeId = OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID;
    private static Integer numOfOppOutcome = 5;
    private static Date currentDate = System.today();
 @testSetup
    static void setupOpportunity(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
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
    private static void checkStageNameUponStartDateUpdate(){ 
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()){  
        	List<Opportunity_Outcome__c> opportunityOutcomeListToUpdate = OpportunityOutcomesDAO.newInstance().getRecordsWithStartDate(currentDate - 10); 
        	Test.startTest();  
            updateStartDate(opportunityOutcomeListToUpdate);
            Test.stopTest();
            List<Opportunity_Outcome__c> oppOutcomes = OpportunityOutcomesDAO.newInstance().getRecordsWithStartDate(currentDate + 30);         
            for(Opportunity_Outcome__c oppOutcome : oppOutcomes){                
                System.assertEquals(OpportunityOutcomesDAO.NEW_STAGE, oppOutcome.Stage_Name__c,'Not equal');
            }  
        }
    }
    
     private static void updateStartDate(List<Opportunity_Outcome__c> opportunityOutcomes){
        List<Opportunity_Outcome__c> oppOutcomesToUpdate = new List<Opportunity_Outcome__c>();
        
        for(Opportunity_Outcome__c opp_outcome : oppOutcomesToUpdate) {
            opp_outcome.Start_Date__c = currentDate + 30;
        }
       OpportunityOutcomesDAO.newInstance().updateRecords(oppOutcomesToUpdate, false,AccessLevel.USER_MODE);
    }
}