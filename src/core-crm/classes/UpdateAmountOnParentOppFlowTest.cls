/**
 * @description Test Class for Update_Amount_On_Parent_Opportunity Flow
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | November 7,2023       | DEPP-7000              | Created file                 |
*/
@isTest
public class UpdateAmountOnParentOppFlowTest {
	
    @testSetup 
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserCorporatePartnershipsManager();
        Test.stopTest();

        Id corporateOppId = OpportunitiesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        Id corporateOppOutcomeId = OpportunityOutcomesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
            List<Opportunity> corpPartnershipOpp = TestDataFactory.createOpportunityRecords(100, 'Opportunity', 'Identify');
            for(Opportunity opp : corpPartnershipOpp){
            	opp.RecordTypeId = corporateOppId;
            }
            OpportunitiesDAO.newInstance().insertRecords(corpPartnershipOpp, false, AccessLevel.USER_MODE);
            
            List<Opportunity_Outcome__c> corpPartnershipOutcome = TestDataFactory.createOpportunityOutcome(200, corporateOppOutcomeId, null);

            Integer oppNum = 0;
            for(Integer i = 0; i<200; i++){
            	corpPartnershipOutcome[i].Opportunity__c = corpPartnershipOpp[oppNum].Id;
                corpPartnershipOutcome[i].Outcome_Tangible_Value__c = 200;
                corpPartnershipOutcome[i].Outcome_Is_Active__c = true;
                if(System.Math.mod(i, 2) != 0){
                	oppNum++;
                }
            }
            OpportunityOutcomesDAO.newInstance().insertRecords(corpPartnershipOutcome, false, AccessLevel.USER_MODE);
        }

    }
    
    @isTest
    static void testAmountOnOpportunityAfterInsert(){
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
        	Test.startTest();
                List<Opportunity> oppList = [SELECT Id, Name, Amount FROM Opportunity WHERE Amount = 400];
                System.assertEquals(100, oppList.size(), 'List must be 100');
            Test.stopTest();
        }
    }
        
    @isTest
    static void testAmountOnOpportunityAfterUpdate(){
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
            List<Opportunity_Outcome__c> oppOutcomeList = [SELECT Id, Outcome_Tangible_Value__c FROM Opportunity_Outcome__c];
            for(Opportunity_Outcome__c outcome: oppOutcomeList){
                outcome.Outcome_Tangible_Value__c = 300;
            }
            OpportunityOutcomesDAO.newInstance().updateRecords(oppOutcomeList, false, AccessLevel.USER_MODE);
            Test.startTest();
				List<Opportunity> oppList2 = [SELECT Id, Name, Amount FROM Opportunity WHERE Amount = 600];
                System.assertEquals(100, oppList2.size(), 'List must be 100');
            Test.stopTest();
        }
    }
}