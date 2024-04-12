/**
 * @description Test Class for ExpenseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | carl.alvin.cabiles             | August 22, 2023       | DEPP-6410              | Created file
 */
@isTest
private class ExpenseTriggerHandlerTest {
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
            List<Expense__c> newExpenses = TestDataFactory.createTestExpenseRecords(
                1,
                oppOutcomes[0].Id,
                'Airfare'
            );

            System.assert(
                ExpensesDAO.newInstance()
                        .insertRecords(newExpenses, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Expense record should be created'
            );

            newExpenses[0].Expense_Type__c = 'Meals';

            System.assert(
                ExpensesDAO.newInstance()
                        .updateRecords(newExpenses, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Expense record should be updated'
            );
            Test.stopTest();
        }
    }
}