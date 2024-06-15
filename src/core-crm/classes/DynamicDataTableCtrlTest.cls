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
        Test.startTest();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountListToInsert = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance()
                .insertRecords(accountListToInsert, false, AccessLevel.USER_MODE);

            List<Contact> contactListToInsert = TestDataFactory.createTestContactRecords(1);
            contactListToInsert[0].AccountId = accountListToInsert[0].Id;

            ContactsDAO.newInstance()
                .insertRecords(contactListToInsert, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void getTableDataWrapperTest() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
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
                'relatedListFields' => '[{"label":"Name","fieldName":"Name","type":"url"},{"label":"Account","fieldName":"Account.Name","type":"url"},{"label":"Created Date","fieldName":"CreatedDate","type":"date"}]',
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

    @isTest
    private static void percentChangeTest() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            Test.startTest();
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            List<Opportunity> ipuOpportunityList = TestDataFactory.createOpportunityRecords(
                1,
                'test',
                'Qualify'
            );
            OpportunitiesDAO.newInstance()
                .insertRecords(ipuOpportunityList, false, AccessLevel.USER_MODE);

            List<Financial_Split__c> financialSplitList = new List<Financial_Split__c>();
            for (Opportunity opp : ipuOpportunityList) {
                List<Financial_Split__c> tempList = TestDataFactory.createTestFinancialSplitRecordsForOpportunity(
                    1,
                    opp.Id,
                    accountList[0].Id
                );
                financialSplitList.addAll(tempList);
            }

            FinancialSplitsDAO.newInstance()
                .insertRecords(financialSplitList, false, AccessLevel.USER_MODE);

            String filter = '';

            String parentfilterValue = 'TestAcount0';
            String parentfilter = 'Name ' + ' = \'' + parentfilterValue + '\'';

            String userfilterValue = 'Partnership_Manager';
            String userfilter = 'UserRole.DeveloperName ' + ' = \'' + userfilterValue + '\'';

            Map<String, String> parameters = new Map<String, String>{
                'recordId' => accountList[0].Id,
                'relatedRecord' => 'Financial_Split__c',
                'relatedField' => 'Funding_Body__c',
                'parentRecord' => 'Account',
                'relatedListFields' => '[{"label":"Name","fieldName":"Name","type":"url"},{"label":"Account","fieldName":"Funding_Body__r.Name","type":"url"},{"label":"Percentage Split","fieldName":"Percentage_split__c","type":"percent"}]',
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
