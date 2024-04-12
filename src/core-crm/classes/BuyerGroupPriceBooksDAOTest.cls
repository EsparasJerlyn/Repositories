/**
 * @description test class for buyerGroupPriceBooksdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
@isTest
public with sharing class BuyerGroupPriceBooksDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(BuyerGroupPriceBooksDAO.newInstance() != null, 'buyerGroupPriceBooksdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new BuyerGroupPriceBooksDAO().getSObjectType() == BuyerGroupPriceBook.SObjectType,
                'SObject is not BuyerGroupPriceBook'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getBuyerGroupPriceBooksByPricebookIdTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            MockIdGenerator mockPriceBook = new MockIdGenerator(BuyerGroupPriceBook.SObjectType);
            List<BuyerGroupPriceBook> bgPriceBooks = BuyerGroupPriceBooksDAO.newInstance().getBuyerGroupPriceBooksByPricebookId(
                mockPriceBook.getmockId(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(bgPriceBooks.isEmpty(), 'buyerGroupPriceBooks is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getBuyerGroupPriceBooksByPricebookIdEmptyTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<BuyerGroupPriceBook> bgPriceBooks = BuyerGroupPriceBooksDAO.newInstance().getBuyerGroupPriceBooksByPricebookId(
                null,
                AccessLevel.SYSTEM_MODE
            );
            System.assert(bgPriceBooks.isEmpty(), 'buyerGroupPriceBooks is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getBuyerGroupPriceBooksByPricebookIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            MockIdGenerator mockPriceBook = new MockIdGenerator(BuyerGroupPriceBook.SObjectType);
            List<BuyerGroupPriceBook> bgPriceBooks = BuyerGroupPriceBooksDAO.newInstance().getBuyerGroupPriceBooksByPricebookIds(
                new Set<Id>{mockPriceBook.getmockId()},
                AccessLevel.SYSTEM_MODE
            );
            System.assert(bgPriceBooks.isEmpty(), 'buyerGroupPriceBooks is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getBuyerGroupPriceBooksByPricebookIdsEmptyTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<BuyerGroupPriceBook> bgPriceBooks = BuyerGroupPriceBooksDAO.newInstance().getBuyerGroupPriceBooksByPricebookIds(
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(bgPriceBooks.isEmpty(), 'buyerGroupPriceBooks is not empty');
            Test.stopTest();
        }
    }
}
