/**
 * @description DynamicQueryService testclass
 * @see ../class/DynamicQueryService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created file                   |
 */
@isTest
private class DynamicQueryServiceTest {
    @testSetup
    static void testSetup() {
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
            System.runAs(TestDataFactory.getOperationsManager()) {
                List<Opportunity_Outcome__c> oppOutcomes = TestDataFactory.createTestOpportunityOutcomeRecords(
                    1,
                    'Sample Company',
                    OpportunityOutcomesDAO.STARTUP_RECTYPE_ID
                );
                oppOutcomes[0].Company_Name__c = 'Test Company';
    
                OpportunityOutcomesDAO.newInstance()
                    .insertRecords(oppOutcomes, false, AccessLevel.USER_MODE);
    
                List<Finance_Summary__c> newFinSummaries = TestDataFactory.createFinanceSummaryRecords(
                    1,
                    FinanceSummariesDAO.VALUATION_RECTYPE_ID,
                    oppOutcomes[0].Id
                );
                FinanceSummariesDAO.newInstance()
                        .insertRecords(newFinSummaries, false, AccessLevel.USER_MODE);
            }
    }

    @isTest
    private static void getRelatedRecordsWithOffSetInOrderTest() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Test.startTest();
             List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();
             oppOutcomes = OpportunityOutcomesDAO.newInstance()
                .getRecordsSortByCodeAsc();
            String filterValue = String.valueOf(System.Today().year());
            String filter = 'AND Year__c ' + ' = \'' + filterValue + '\'';

            Map<String, String> parametersMap = new Map<String, String>{
                'recordId' => oppOutcomes[0].Id,
                'relatedRecord' => 'Finance_Summary__c',
                'relatedField' => 'Opportunity_Outcome__c',
                'relatedFieldApiNames' => 'Year__c',
                'relatedListFilters' => filter,
                'rowOffSet' => '0',
                'rowLimit' => '10',
                'sortOrder' => 'DESC',
                'sortField' => 'CreatedDate'
            };

            System.assert(
                !DynamicQueryService.getRelatedRecordsWithOffSetInOrder(
                        parametersMap,
                        AccessLevel.USER_MODE
                    )
                    .isEmpty(),
                'query is empty'
            );

            Test.stopTest();
        }
    }

    @isTest
    private static void getRecordWithFilterTest() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Test.startTest();
            List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();
            oppOutcomes = OpportunityOutcomesDAO.newInstance()
                .getRecordsSortByCodeAsc();

            String filterValue = 'Test Company';
            String filter = 'Company_Name__c ' + ' = \'' + filterValue + '\'';

            Map<String, String> parametersMap = new Map<String, String>{
                'recordId' => oppOutcomes[0].Id,
                'sObjectApiName' => 'Opportunity_Outcome__c',
                'filter' => filter
            };

            System.assert(
                !DynamicQueryService.getRecordWithFilter(parametersMap, AccessLevel.USER_MODE)
                    .isEmpty(),
                'no opportunity outcome records queried'
            );

            Test.stopTest();
        }
    }

    @isTest
    private static void getRelatedRecordsCountWithFilterTest() {
        System.runAs(TestDataFactory.getOperationsManager()) {
            Test.startTest();
            List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();
            oppOutcomes = OpportunityOutcomesDAO.newInstance()
                .getRecordsSortByCodeAsc();

            String filterValue = String.valueOf(System.Today().year());
            String filter = 'AND Year__c ' + ' = \'' + filterValue + '\'';

            Map<String, String> parametersMap = new Map<String, String>{
                'recordId' => oppOutcomes[0].Id,
                'relatedRecord' => 'Finance_Summary__c',
                'relatedField' => 'Opportunity_Outcome__c',
                'relatedListFilters' => filter
            };

            System.assert(
                DynamicQueryService.getRelatedRecordsCountWithFilter(
                    parametersMap,
                    AccessLevel.USER_MODE
                ) == 1,
                'count is not equal to 1'
            );

            Test.stopTest();
        }
    }
}