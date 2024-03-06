/**
 * @description Test Class for Stewardship Update - Custom Validation flow
 *
 * @see ../flows/Stewardship Update - Custom Validation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary         |
      |---------------------------|-----------------------|--------------|------------------------|
      | nicole.genon    	      | March 6, 2024         | DEPP-7922    | Created file           |
*/
@isTest
public with sharing class StewardshipUpdateCustomValidationTest {
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager'});
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Plan_Activity__c> newPlanActivityList = new List<Plan_Activity__c>();
            List<Plan_Activity__c> planActivityList = TestDataFactory.createPlanActivityRecords(5);
            List<Stewardship__c> stewardshipList = TestDataFactory.createStewardshipRecords(1);

            // StewardshipsDAO.newInstance().insertRecords(planActivityList, false, AccessLevel.SYSTEM_MODE);
            for(Plan_Activity__c plan : planActivityList){
                plan.Stewardship__c = stewardshipList[0].Id;
                newPlanActivityList.add(plan);
            }

            PlanActivitiesDAO.newInstance().insertRecords(newPlanActivityList, false, AccessLevel.SYSTEM_MODE);

        }
    }
}