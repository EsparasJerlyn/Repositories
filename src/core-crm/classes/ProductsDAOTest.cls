/**
 * @description test class for productsdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
      | kenneth.f.alsay                | March 27, 2024        | DEPP-8209              | Added getProductByDonationCauseIdTest
      | kenneth.f.alsay                | April 4, 2024         | DEPP-8399              | Added getProductByDesignationIdTest & getProductByDesignationIdNotEmptyTest
      | marygrace.li                   | May 2, 2024           | DEPP-8399              | Deleted getProductByDonationCauseIdTest, getProductByDonationCauseIdNotEmptyTest
      | kenneth.f.alsay                | May 7, 2024           | DEPP-8203              | Removed Donation Cause references
      | sebastianne.k.trias            | May 22, 2024          | DEPP-8410              | Added getProductsOnPageTest  |
 */

@isTest
public with sharing class ProductsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserAdvancementManager();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(ProductsDAO.newInstance() != null, 'productsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
    static void getProductByDesignationIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(
                ProductsDAO.newInstance()
                    .getProductByDesignationId(
                        new Set<Id>(),
                        AccessLevel.USER_MODE)
                    .isEmpty(),
                'product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProductByDesignationIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            MockIdGenerator builderForDesigntation = new MockIdGenerator(Designation__c.sObjectType);
            System.assert(
                ProductsDAO.newInstance()
                    .getProductByDesignationId(
                        new Set<Id>{builderForDesigntation.getMockId()},
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
