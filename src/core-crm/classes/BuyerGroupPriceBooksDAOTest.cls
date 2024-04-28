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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(BuyerGroupPriceBooksDAO.newInstance() != null, 'buyerGroupPriceBooksdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new BuyerGroupPriceBooksDAO().getSObjectType() == BuyerGroupPriceBook.SObjectType,
                'SObject is not BuyerGroupPriceBook'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getBuyerGroupPriceBooksByPricebookIdTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
