/**
 * @description Tests Controller Class for FlowLookupController
 * @see ../classes/FlowLookupController
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------|
 *    | ryan.j.a.dela.cruz             | June 6, 2023          | DEPP-5385              | Created file                                 |
 *    | ryan.j.a.dela.cruz             | June 23, 2023         | DEPP-5935              | 100% Code Coverage of FlowLookupController   | 
 */
@isTest
public class FlowLookupControllerTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        TestDataFactoryUser.generateUserIndustryOperationsManager();
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    private static void getEmptySearchResultForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            String whereClause = 'Name = \'Test\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Account',
                'Name,Phone',
                'Id',
                5,
                whereClause,
                'Name DESC'
            );
            System.assertEquals(
                0,
                records.size(),
                'No records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getEmptySearchResultForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            String whereClause = 'Name = \'Test\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Account',
                'Name,Phone',
                'Id',
                5,
                whereClause,
                'Name DESC'
            );
            System.assertEquals(
                0,
                records.size(),
                'No records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getSearchResultForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            String whereClause = 'Name = \'TestAccount0\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Account',
                'Name,Phone',
                'Id',
                1,
                whereClause,
                'Name DESC'
            );
            System.assertEquals(1, records.size(), '1 record should be returned in this test case');
        }
        Test.stopTest();
    }

    @isTest
    private static void getSearchResultForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            String whereClause = 'Name = \'TestAccount0\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Account',
                'Name,Phone',
                'Id',
                1,
                whereClause,
                'Name DESC'
            );
            System.assertEquals(1, records.size(), '1 record should be returned in this test case');
        }
        Test.stopTest();
    }

    @isTest
    private static void getContactSearchResultForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1); 
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            String whereClause = 'Name = \'Test0 Contact0\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Contact',
                'Name',
                'Id',
                1,
                whereClause,
                'Name DESC'
            );
            System.assertEquals(1, records.size(), '1 record should be returned in this test case');
        }
        Test.stopTest();
    }

    @isTest
    private static void getSearchResultMultipleFieldsForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            String whereClause = 'Name = \'TestAccount0\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Account',
                'Name,Phone,Type,Account.Owner.FirstName',
                'Id,Name,Type',
                1,
                whereClause,
                'Name DESC'
            );

            System.assertEquals(
                1,
                records.size(),
                'One record should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getSearchResultMultipleFieldsForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            String whereClause = 'Name = \'TestAccount0\'';
            List<SObject> records = FlowLookupController.search(
                'test',
                'Account',
                'Name,Phone,Type,Account.Owner.FirstName',
                'Id,Name,Type',
                1,
                whereClause,
                'Name DESC'
            );

            System.assertEquals(
                1,
                records.size(),
                'One record should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordsFromIdsForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            String accountName = AccountCtrl.getAccountName(accountList.iterator().next()?.Id);
            List<String> ids = new List<String>{ accountList.iterator().next()?.Id };
            List<SObject> records = FlowLookupController.getRecordsFromIds('Account', 'Name', ids);

            System.assertEquals(
                1,
                records.size(),
                'One record should be returned in this test case'
            );
            System.assertEquals('TestAccount0', accountName, 'Record Name should match');
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordsFromIdsForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            String accountName = AccountCtrl.getAccountName(accountList.iterator().next()?.Id);
            List<String> ids = new List<String>{ accountList.iterator().next()?.Id };
            List<SObject> records = FlowLookupController.getRecordsFromIds('Account', 'Name', ids);
            System.assertEquals(
                1,
                records.size(),
                'One record should be returned in this test case'
            );
            System.assertEquals('TestAccount0', accountName, 'Record Name should match');
        }
        Test.stopTest();
    }

    @isTest
    private static void getEmptyRecentlyViewedResultForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<SObject> records = FlowLookupController.getRecentlyViewed(
                'Account',
                'Name',
                0,
                'Name = \'Test\''
            );

            System.assertEquals(
                0,
                records.size(),
                'No records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getEmptyRecentlyViewedResultForPartnerhipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<SObject> records = FlowLookupController.getRecentlyViewed(
                'Account',
                'Name',
                0,
                'Name = \'Test\''
            );

            System.assertEquals(
                0,
                records.size(),
                'No records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getStandardObjectIconForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            // Test for a standard object (Account)
            String accountIcon = FlowLookupController.getObjectIcon('Account');
            System.assertNotEquals(null, accountIcon, 'Account icon should not be null');

            // Test for another standard object (Contact)
            String contactIcon = FlowLookupController.getObjectIcon('Contact');
            System.assertNotEquals(null, contactIcon, 'Contact icon should not be null');
        }
        Test.stopTest();
    }

    @isTest
    private static void getStandardObjectIconForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            // Test for a standard object (Account)
            String accountIcon = FlowLookupController.getObjectIcon('Account');
            System.assertNotEquals(null, accountIcon, 'Account icon should not be null');

            // Test for another standard object (Contact)
            String contactIcon = FlowLookupController.getObjectIcon('Contact');
            System.assertNotEquals(null, contactIcon, 'Contact icon should not be null');
        }
        Test.stopTest();
    }

    @isTest
    private static void getCustomObjectIconForOperationsManagerTest() {
        Test.startTest();
        Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        engCodeAutoNum.Commercialisation__c = 1;
        engCodeAutoNum.Research_Partnership__c = 1;
        EngagementCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Engagement_Code_Auto_Number__c>{ engCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            // Test for a custom object (Engagement__c)
            List<Engagement__c> engagementList = TestDataFactory.createTestEngagementRecords(
                1,
                'RCE',
                EngagementsDAO.COMMERCIALISATION_RECTYPE_ID
            );
            EngagementsDAO.newInstance()
                .insertRecords(engagementList, false, AccessLevel.USER_MODE);
            String objectIcon = FlowLookupController.getObjectIcon('Engagement__c');
            System.assertNotEquals(null, objectIcon, 'Object icon should not be null');
        }
        Test.stopTest();
    }

    @isTest
    private static void getCustomObjectIconForPartnershipManagerTest() {
        Test.startTest();
        Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        engCodeAutoNum.Commercialisation__c = 1;
        engCodeAutoNum.Research_Partnership__c = 1;
        EngagementCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Engagement_Code_Auto_Number__c>{ engCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            // Test for a custom object (Engagement__c)
            List<Engagement__c> engagementList = TestDataFactory.createTestEngagementRecords(
                1,
                'RCE',
                EngagementsDAO.COMMERCIALISATION_RECTYPE_ID
            );
            EngagementsDAO.newInstance()
                .insertRecords(engagementList, false, AccessLevel.USER_MODE);
            String objectIcon = FlowLookupController.getObjectIcon('Engagement__c');
            System.assertNotEquals(null, objectIcon, 'Object icon should not be null');
        }
        Test.stopTest();
    }

    @isTest
    private static void getNonExistentObjectIconForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            // Test for a nonexistent object
            String nonExistentIcon = FlowLookupController.getObjectIcon('NonExistentObject__c');
            System.assertEquals(
                'custom:custom18',
                nonExistentIcon,
                'Nonexistent object should return the default custom icon'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getNonExistentObjectIconForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            // Test for a nonexistent object
            String nonExistentIcon = FlowLookupController.getObjectIcon('NonExistentObject__c');
            System.assertEquals(
                'custom:custom18',
                nonExistentIcon,
                'Nonexistent object should return the default custom icon'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordsWhereClauseForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(5);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            List<SObject> records = FlowLookupController.getRecords(
                'Account',
                'Name',
                5,
                'Name LIKE \'%TestAccount%\''
            );

            System.assertEquals(
                5,
                records.size(),
                '5 records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordsWhereClauseForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(5);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

            List<SObject> records = FlowLookupController.getRecords(
                'Account',
                'Name',
                5,
                'Name LIKE \'%TestAccount%\''
            );

            System.assertEquals(
                5,
                records.size(),
                '5 records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordsDefaultReturnForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<SObject> records = FlowLookupController.getRecords(
                'Account',
                'Name',
                0,
                'Name LIKE \'%Test%\''
            );
            System.assertEquals(
                0,
                records.size(),
                'No records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordsDefaultReturnForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<SObject> records = FlowLookupController.getRecords(
                'Account',
                'Name',
                0,
                'Name LIKE \'%Test%\''
            );
            System.assertEquals(
                0,
                records.size(),
                'No records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordDetailForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            String accountId = accountList.iterator().next()?.Id;

            List<SObject> records = FlowLookupController.getRecordDetail('Account', accountId);

            System.assertEquals(
                1,
                records.size(),
                'One record should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getRecordDetailForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            String accountId = accountList.iterator().next()?.Id;

            List<SObject> records = FlowLookupController.getRecordDetail('Account', accountId);

            System.assertEquals(
                1,
                records.size(),
                'One record should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getMultipleRecordDetailsForOperationsManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(5);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            List<Id> accountIds = new List<Id>();
            for (Account acc : accountList) {
                accountIds.add(acc.Id);
            }

            List<SObject> records = FlowLookupController.getRecordDetail(
                'Account',
                String.join(accountIds, ',')
            );

            System.assertEquals(
                5,
                records.size(),
                'Five records should be returned in this test case'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getMultipleRecordDetailsForPartnershipManagerTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Account> accountList = TestDataFactory.createTestAccountRecords(5);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            List<Id> accountIds = new List<Id>();
            for (Account acc : accountList) {
                accountIds.add(acc.Id);
            }

            List<SObject> records = FlowLookupController.getRecordDetail(
                'Account',
                String.join(accountIds, ',')
            );

            System.assertEquals(
                5,
                records.size(),
                'Five records should be returned in this test case'
            );
        }
        Test.stopTest();
    }
}
 