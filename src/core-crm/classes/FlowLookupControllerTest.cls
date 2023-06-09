/**
 * @description Tests Controller Class for FlowLookupController
 * @see ../classes/FlowLookupController
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | ryan.j.a.dela.cruz             | June 6, 2023          | DEPP-5385              | Created file                   |
 */
@isTest
public without sharing class FlowLookupControllerTest {
    @isTest
    public static void searchTest() {
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

        System.assertEquals(0, records.size(), 'No records should be returned in this test case');
    }

    @isTest
    public static void getRecordsFromIdsTest() {
        // Create test data
        Account a = new Account(Name = 'Test');
        insert a;
        List<String> ids = new List<String>{ a.Id };

        List<SObject> records = FlowLookupController.getRecordsFromIds('Account', 'Name', ids);

        System.assertEquals(1, records.size(), 'One record should be returned in this test case');
        System.assertEquals('Test', records[0].get('Name'), 'Record Name should match');
    }

    @isTest
    public static void getRecentlyViewedTest() {
        List<SObject> records = FlowLookupController.getRecentlyViewed(
            'Account',
            'Name',
            5,
            'Name = \'Test\''
        );

        System.assertEquals(0, records.size(), 'No records should be returned in this test case');
    }

    @isTest
    public static void getObjectIconTest() {
        String objectIcon = FlowLookupController.getObjectIcon('Account');

        System.assertNotEquals(null, objectIcon, 'Object icon should not be null');
    }

    @isTest
    public static void getRecordsWhereClauseTest() {
        List<SObject> records = FlowLookupController.getRecords(
            'Account',
            'Name',
            5,
            'Name LIKE \'%Test%\''
        );

        System.assertEquals(0, records.size(), 'No records should be returned in this test case');
    }

    @isTest
    public static void getRecordDetailTest() {
        // Create test data
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test1'),
            new Account(Name = 'Test2')
        };
        insert accounts;

        List<String> accountIds = new List<String>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<SObject> records = FlowLookupController.getRecordDetail(
            'Account',
            String.join(accountIds, ',')
        );

        System.assertEquals(2, records.size(), 'Two records should be returned in this test case');
    }

    @isTest
    public static void searchTest2() {
        // Create test data
        String whereClause = 'Name = \'Test\'';
        List<SObject> records = FlowLookupController.search(
            'test',
            'Account',
            'Name,Phone,Type,Account.Owner.FirstName',
            'Id,Name,Type',
            5,
            whereClause,
            'Name DESC'
        );

        System.assertEquals(0, records.size(), 'No records should be returned in this test case');
    }
}
