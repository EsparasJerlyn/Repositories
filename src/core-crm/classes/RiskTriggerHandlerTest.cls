/**
 * @description Test Class for RiskTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | August 08, 2023       | DEPP-6335              | Created file
 */
@isTest
private class RiskTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Operations_Manager' });
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
            List<Risk__c> newRisks = TestDataFactory.createTestRiskRecords(
                1,
                oppOutcomes[0].Id,
                'Health and Safety	'
            );

            System.assert(
                RisksDAO.newInstance()
                        .insertRecords(newRisks, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Risk record should be created'
            );

            newRisks[0].Risk_Type__c = 'Logistical';

            System.assert(
                RisksDAO.newInstance()
                        .updateRecords(newRisks, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Risk record should be updated'
            );
            Test.stopTest();
        }
    }
}
