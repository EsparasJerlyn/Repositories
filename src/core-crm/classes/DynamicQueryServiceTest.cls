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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<Account> accountListToInsert = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance()
                .insertRecords(accountListToInsert, false, AccessLevel.USER_MODE);

            List<Contact> contactListToInsert = TestDataFactory.createTestContactRecords(1);
            contactListToInsert[0].AccountId = accountListToInsert[0].Id;

            ContactsDAO.newInstance()
                .insertRecords(contactListToInsert, false, AccessLevel.USER_MODE);
            Test.stopTest();
        }
    }

    @isTest
    private static void getRelatedRecordsWithOffSetInOrderTest() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<Account> accountList = new List<Account>();
            accountList = AccountsDAO.newInstance()
                .getAccountBySetNamesWithLimit(new Set<String>{ 'TestAccount0' }, 1);

            String filterValue = 'Test0';
            String filter = 'AND FirstName ' + ' = \'' + filterValue + '\'';

            Map<String, String> parametersMap = new Map<String, String>{
                'recordId' => accountList[0].Id,
                'relatedRecord' => 'Contact',
                'relatedField' => 'AccountId',
                'relatedFieldApiNames' => 'Name,Account.Name',
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
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<Account> accountList = new List<Account>();
            accountList = AccountsDAO.newInstance()
                .getAccountBySetNamesWithLimit(new Set<String>{ 'TestAccount0' }, 1);

            String filterValue = 'TestAccount0';
            String filter = 'Name ' + ' = \'' + filterValue + '\'';

            Map<String, String> parametersMap = new Map<String, String>{
                'recordId' => accountList[0].Id,
                'sObjectApiName' => 'Account',
                'filter' => filter
            };

            System.assert(
                !DynamicQueryService.getRecordWithFilter(parametersMap, AccessLevel.USER_MODE)
                    .isEmpty(),
                'no acocunt records queried'
            );

            Test.stopTest();
        }
    }

    @isTest
    private static void getRelatedRecordsCountWithFilterTest() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<Account> accountList = new List<Account>();
            accountList = AccountsDAO.newInstance()
                .getAccountBySetNamesWithLimit(new Set<String>{ 'TestAccount0' }, 1);

            String filterValue = 'Test0';
            String filter = 'AND FirstName ' + ' = \'' + filterValue + '\'';

            Map<String, String> parametersMap = new Map<String, String>{
                'recordId' => accountList[0].Id,
                'relatedRecord' => 'Contact',
                'relatedField' => 'AccountId',
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
