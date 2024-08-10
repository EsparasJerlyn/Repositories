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
        Test.startTest();
        TestDataFactoryUser.generateUserDonorEngagementManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Stewardship__c> stewardshipList = TestDataFactory.createStewardshipRecords(StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID,1);
            StewardshipsDAO.newInstance().insertRecords(stewardshipList, false, AccessLevel.USER_MODE);

            List<Plan_Activity__c> planActivityList = TestDataFactory.createPlanActivityRecordsWithStewardship(5,stewardshipList[0].Id);
            PlanActivitiesDAO.newInstance().insertRecords(planActivityList, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void checkStageUpdateWithPendingPlanActivity() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            Test.startTest();
            List<Stewardship__c> stewardshipRecords = StewardshipsDAO.getStewardshipByRecordTypeIds(new Set<Id>{StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID},AccessLevel.USER_MODE);

            stewardshipRecords[0].Stage__c = 'Completed';
            StewardshipsDAO.newInstance().updateRecords(stewardshipRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Stewardship__c> stewardshipUpdatedRecords = StewardshipsDAO.getStewardshipBySetIds(new Set<Id>{stewardshipRecords[0].Id},AccessLevel.USER_MODE);
            System.assert(stewardshipUpdatedRecords[0].Stage__c.equals('Active'), 'Stage is Active.');
        }
    }

    @isTest
    private static void checkStageUpdateWithNoPendingPlanActivity() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            Test.startTest();
            List<Plan_Activity__c> updatePlanActivityList = new List<Plan_Activity__c>();
            List<Stewardship__c> stewardshipRecords = StewardshipsDAO.getStewardshipByRecordTypeIds(new Set<Id>{StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID},AccessLevel.USER_MODE);
            List<Plan_Activity__c> planActivityList = PlanActivitiesDAO.getPlanActivityRecordsWithStewardshipIds(new Set<Id>{stewardshipRecords[0].Id},AccessLevel.USER_MODE);

            for(Plan_Activity__c plan : planActivityList){
                plan.Status__c = 'Completed';
                updatePlanActivityList.add(plan);
            }
            PlanActivitiesDAO.newInstance().updateRecords(updatePlanActivityList, false, AccessLevel.USER_MODE);

            stewardshipRecords[0].Stage__c = 'Completed';
            StewardshipsDAO.newInstance().updateRecords(stewardshipRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Stewardship__c> stewardshipUpdatedRecords = StewardshipsDAO.getStewardshipBySetIds(new Set<Id>{stewardshipRecords[0].Id},AccessLevel.USER_MODE);
            System.assert(stewardshipUpdatedRecords[0].Stage__c.equals('Completed'), 'Stage is successfully changed to Completed.');
        }
    }
}