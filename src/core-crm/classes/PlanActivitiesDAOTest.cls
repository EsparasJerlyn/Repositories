/**
 * @description test class for PlanActivitiesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file
      | nicole.genon                   | March 7, 2024         | DEPP-7922              | Added getPlanActivityRecordsWithStewardshipIds
 */
@isTest
public with sharing class PlanActivitiesDAOTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
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
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(PlanActivitiesDAO.newInstance() != null, 'PlanActivitiesDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(
                new PlanActivitiesDAO().getSObjectType() == Plan_Activity__c.SObjectType,
                'SObject is not Plan_Activity__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getPlanActivityRecordsWithStewardshipIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Plan_Activity__c> planActivitiesList = PlanActivitiesDAO.newInstance()
                .getPlanActivityRecordsWithStewardshipIds(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(planActivitiesList.isEmpty(), 'planActivitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPlanActivityRecordsWithStewardshipIdsNotEmpty() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            MockIdGenerator stewardshipMock = new MockIdGenerator(Stewardship__c.SObjectType);
            List<Plan_Activity__c> planActivitiesList = PlanActivitiesDAO.newInstance()
                .getPlanActivityRecordsWithStewardshipIds(
                    new Set<Id>{stewardshipMock.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(planActivitiesList.isEmpty(), 'planActivitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPlanActivityRecordsWithOpportunityIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Plan_Activity__c> planActivitiesList = PlanActivitiesDAO.newInstance()
                .getPlanActivityRecordsWithOpportunityIds(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(planActivitiesList.isEmpty(), 'planActivitiesList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPlanActivityRecordsWithOpportunityIdsNotEmpty() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            MockIdGenerator opportunityMock = new MockIdGenerator(Opportunity.SObjectType);
            List<Plan_Activity__c> planActivitiesList = PlanActivitiesDAO.newInstance()
                .getPlanActivityRecordsWithOpportunityIds(
                    new Set<Id>{opportunityMock.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(planActivitiesList.isEmpty(), 'planActivitiesList should not be empty');
        }
        Test.stopTest();
    }
}