/**
 * @description DynamicDataTableCtrl testclass
 * @see ../class/DynamicDataTableCtrl
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
private class DynamicDataTableCtrlTest {
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
    private static void getTableDataWrapperTest() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<Account> accountList = new List<Account>();
            accountList = AccountsDAO.newInstance()
                .getAccountBySetNamesWithLimit(new Set<String>{ 'TestAccount0' }, 1);

            String filterValue = 'Test0';
            String filter = 'AND FirstName ' + ' = \'' + filterValue + '\'';

            String parentfilterValue = 'TestAcount0';
            String parentfilter = 'Name ' + ' = \'' + parentfilterValue + '\'';

            String userfilterValue = 'Partnership_Manager';
            String userfilter = 'UserRole.DeveloperName ' + ' = \'' + userfilterValue + '\'';

            Map<String, String> parameters = new Map<String, String>{
                'recordId' => accountList[0].Id,
                'relatedRecord' => 'Contact',
                'relatedField' => 'AccountId',
                'parentRecord' => 'Account',
                'relatedListFields' => '[{"label":"Name","fieldName":"Name","type":"url"},{"label":"Account","fieldName":"Account.Name","type":"url"}]',
                'relatedListFilters' => filter,
                'rowOffSet' => '0',
                'rowLimit' => '10',
                'sortOrder' => 'DESC',
                'sortField' => 'CreatedDate',
                'visibilityByParent' => parentfilter,
                'visibilityByUser' => userfilter
            };

            System.assert(
                DynamicDataTableCtrl.getTableDataWrapper(parameters) != null,
                'the table was not created'
            );

            Test.stopTest();
        }
    }
}
