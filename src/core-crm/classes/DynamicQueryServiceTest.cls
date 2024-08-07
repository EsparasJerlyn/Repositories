/**
 * @description DynamicQueryService testclass
 * @see ../class/DynamicQueryService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------------|
 *    | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created file                                  |
 *    | eccarius.munoz                 | September 2, 2023     | DEPP-6138              | added method getRecordsWithFieldsByIdSetTest  |
 */
@isTest
private class DynamicQueryServiceTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        TestDataFactoryUser.generateUserIndustryOperationsManager();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        List<Account> accountListToInsert = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance()
            .insertRecords(accountListToInsert, false, AccessLevel.USER_MODE);

        List<Contact> contactListToInsert = TestDataFactory.createTestContactRecords(1);
        contactListToInsert[0].AccountId = accountListToInsert[0].Id;

        ContactsDAO.newInstance()
            .insertRecords(contactListToInsert, false, AccessLevel.USER_MODE);

        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
            .insertRecords(
                new List<Opportunity_Outcome_Code_Auto_Number__c>{ oppOutcomeCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
            System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
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
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
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
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
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
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
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

    @isTest
    private static void getRecordsWithFieldsByIdSetTest() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {

            Test.startTest();
            List<Account> accountList = new List<Account>();
            accountList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String>{ 'TestAccount0' }, 1);

            List<Account> accountListWithFilter =
                (List<Account>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                    new DynamicQueryService.FilterWrapper(new Set<Id>{accountList[0].Id}, Account.getSObjectType(), new List<String>()),
                    AccessLevel.USER_MODE
                );

            System.assert(
                !accountListWithFilter.isEmpty(),
                'List should not be empty.'
            );

            Test.stopTest();
        }
    }

    @isTest
    private static void formatStringSetForWhereClauseTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            String expected = '\'Active\', \'Enrolled\'';
            String actual = DynamicQueryService.formatStringSetForWhereClause(new Set<String>{'Active', 'Enrolled'});

            System.assertEquals(expected, actual, 'Incorrect String format.');

            Test.stopTest();
        }
    }

    @isTest
    private static void formatIdStringSetForWhereClauseTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();                      
            MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType);
            Id contactId1 = contactMock.getMockId();
            Id contactId2 = contactMock.getMockId();
            String expected = '\'' + contactId1 + '\', \'' + contactId2 + '\'';
            String actual = DynamicQueryService.formatStringSetForWhereClause(new Set<Id>{contactId1, contactId2});

            System.assertEquals(expected, actual, 'Incorrect String format.');

            Test.stopTest();
        }
    }

}