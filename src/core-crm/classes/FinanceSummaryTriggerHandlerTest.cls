/**
 * @description Test Class for FinanceSummaryTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | July 14, 2023         | DEPP-5473              | Created file                   |
 */
@isTest
private class FinanceSummaryTriggerHandlerTest {
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
            List<Finance_Summary__c> newFinSummaries = TestDataFactory.createFinanceSummaryRecords(
                1,
                FinanceSummariesDAO.VALUATION_RECTYPE_ID,
                oppOutcomes[0].Id
            );

            System.assert(
                FinanceSummariesDAO.newInstance()
                        .insertRecords(newFinSummaries, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Finance Summary is not created'
            );

            newFinSummaries[0].Year__c = '2025';

            System.assert(
                FinanceSummariesDAO.newInstance()
                        .updateRecords(newFinSummaries, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Finance Summary is not updated'
            );
            Test.stopTest();
        }
    }
}
