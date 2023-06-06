/**
 * @description Test Class for AccountDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        |DEPP-5567               | Created File                 | 
      | mark.j.mahilum                 | June 01, 2023         |DEPP-5687               | Added new test method        |
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
            List<Account> accountList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String>(),1);
            System.assert(accountList.isEmpty(), 'accountList is not empty');
        }
        Test.stopTest();
    }
}