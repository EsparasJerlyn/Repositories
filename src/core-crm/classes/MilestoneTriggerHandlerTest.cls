/**
 * @description Test Class for MilestoneTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | Created file                   |
 */
@isTest
private class MilestoneTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });
        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
            .insertRecords(
                new List<Opportunity_Outcome_Code_Auto_Number__c>{ oppOutcomeCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
    }

    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(testDataFactory.getOperationsManager()) {
            List<Opportunity_Outcome__c> oppOutcomes = TestDataFactory.createTestOpportunityOutcomeRecords(
                1,
                'Sample Company',
                OpportunityOutcomesDAO.STARTUP_RECTYPE_ID
            );

            OpportunityOutcomesDAO.newInstance()
                .insertRecords(oppOutcomes, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Milestone__c> newMilestones = TestDataFactory.createTestMileStoneRecords(
                1,
                oppOutcomes[0].Id,
                'Compliance'
            );

            System.assert(
                MilestonesDAO.newInstance()
                        .insertRecords(newMilestones, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Milestone is not created'
            );

            newMilestones[0].Milestone_Type__c = 'Financial';

            System.assert(
                MilestonesDAO.newInstance()
                        .updateRecords(newMilestones, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Milestone is not updated'
            );
            Test.stopTest();
        }
    }
}
