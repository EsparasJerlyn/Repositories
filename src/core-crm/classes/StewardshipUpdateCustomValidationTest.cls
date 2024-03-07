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
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Donor_Engagement_Manager'});
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Plan_Activity__c> newPlanActivityList = new List<Plan_Activity__c>();
            List<Plan_Activity__c> planActivityList = TestDataFactory.createPlanActivityRecords(5);
            List<Stewardship__c> stewardshipList = TestDataFactory.createStewardshipRecords(StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID,1);

            StewardshipsDAO.newInstance().insertRecords(stewardshipList, false, AccessLevel.SYSTEM_MODE);

            for(Plan_Activity__c plan : planActivityList){
                plan.Stewardship__c = stewardshipList[0].Id;
                newPlanActivityList.add(plan);
            }

            PlanActivitiesDAO.newInstance().insertRecords(newPlanActivityList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void checkStageUpdateWithPendingPlanActivity() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            Test.startTest();
            List<Stewardship__c> stewardshipRecords = StewardshipsDAO.getStewardshipByRecordTypeIds(new Set<Id>{StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID},AccessLevel.USER_MODE);

            stewardshipRecords[0].Stage__c = 'Completed';
            StewardshipsDAO.newInstance().updateRecords(stewardshipRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Stewardship__c> stewardshipUpdatedRecords = StewardshipsDAO.getStewardshipBySetIds(new Set<Id>{stewardshipRecords[0].Id},AccessLevel.USER_MODE);
            System.assert(stewardshipUpdatedRecords[0].Stage__c.equals('Active'), 'Stage is Active.');
        }
    }
}