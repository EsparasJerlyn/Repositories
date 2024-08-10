/**
 * @description Test Class for PlanActivityTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                   |
 */
@isTest
private class PlanActivityTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactoryUser.generateUserAdvancementManager();
    }
    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            List<Opportunity> opps = TestDataFactory.createTestOpportunityRecords(1, 'OppGiving',OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID);
            for( Opportunity opp: opps){
            opp.StageName = 'Cultivation';
            }
            List<Plan_Activity__c> newPlanActivities = TestDataFactory.createPlanActivityRecords(
                1,
                opps[0].Id
            );
            System.assert(
                PlanActivitiesDAO.newInstance()
                        .insertRecords(newPlanActivities, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Plan Activity record is not created'
            );
            newPlanActivities[0].Status__c = 'Completed';
            System.assert(
                PlanActivitiesDAO.newInstance()
                        .updateRecords(newPlanActivities, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Plan Activity is not updated'
            );
            Test.stopTest();
        }
    }
}