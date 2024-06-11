/**
 * @description test class for productsdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
      | sebastianne.k.trias            | May 22, 2024          | DEPP-8410              | Added getProductsOnPageTest  |
 */
@isTest
public with sharing class ProductsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(ProductsDAO.newInstance() != null, 'productsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProductsDAO().getSObjectType() == Product2.SObjectType,
                'SObject is not Product2'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProductByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                ProductsDAO.newInstance()
                    .getProductById(
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProductByIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builderForProduct = new MockIdGenerator(Product2.sObjectType);
            System.assert(
                ProductsDAO.newInstance()
                    .getProductById(
                        new Set<Id>{builderForProduct.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProductsOnPageTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                ProductsDAO.newInstance()
                    .getProductsOnPage(
                        new Set<Id>(),
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

}