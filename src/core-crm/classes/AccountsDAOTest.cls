/**
 * @description Test Class for AccountDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | roy.nino.s.regala              | April 24, 2023        |DEPP-5567               | Created File                        |
 *    | mark.j.mahilum                 | June 1, 2023          |DEPP-5687               | Added new test method               |
 *    | ryan.j.a.dela.cruz             | June 5, 2023          |DEPP-5687               | Added getAccountIdByABNTest method  |
 */
@isTest
public with sharing class AccountsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getAccountsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetIds(new Set<Id>());
            System.assert(accountList.isEmpty(), 'accountList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPartnerAccountsByIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            MockIdGenerator mockAccount = new MockIdGenerator(Account.SObjectType);
            List<Account> accounts = AccountsDAO.newInstance().getPartnerAccountsByIds(
                new Set<Id>{mockAccount.getMockId()},
                AccessLevel.SYSTEM_MODE
            );
            System.assert(accounts.isEmpty(), 'accounts is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getPartnerAccountsByIdsEmptyTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Account> accounts = AccountsDAO.newInstance().getPartnerAccountsByIds(
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(accounts.isEmpty(), 'accounts is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getAccountsByFieldsSetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetIds(new Set<Id>(), new List<String>(), AccessLevel.SYSTEM_MODE);
            System.assert(accountList.isEmpty(), 'accountList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getAccountsBySetNamesTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>());
            System.assert(accountList.isEmpty(), 'accountList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getAccountIdByBlankABNTest() {
        Test.startTest();      
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Account account = AccountsDAO.newInstance().getAccountIdByABN('');
            System.assert(account == null, 'No Account should be found');
        }
        Test.stopTest();
    }

    @isTest
    static void getAccountIdByABNTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
       		List<Account> accountList = TestDataFactory.createTestAccountWithABNRecords(1);
            AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
            Account account = AccountsDAO.newInstance().getAccountIdByABN('ABN0');
            System.assert(account != null, 'Account should be found');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AccountsDAO().getSObjectType() == Account.SObjectType,
                'SObject is not Account'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAccountBySetNamesWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountBySetNamesWithLimit(new Set<String>(), 1);
            System.assert(accountList.isEmpty(), 'accountList is not empty');
        }
        Test.stopTest();
    }
}