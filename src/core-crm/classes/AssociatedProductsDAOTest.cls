/**
 * @description test class for associatedproductsdao
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                |   
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Added method for getAssociatedProductsById  |
 */
@isTest
public with sharing class AssociatedProductsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getActiveAssociatedProductsByProductRequestTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                AssociatedProductsDAO.newInstance()
                    .getActiveAssociatedProductsByProductRequest(new Set<Id>())
                    .isEmpty(),
                'associated product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAssociatedProductsByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                AssociatedProductsDAO.newInstance()
                    .getAssociatedProductsById(
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'associated product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAssociatedProductsByIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builder = new MockIdGenerator(Associated_Products__c.sObjectType);
            System.assert(
                AssociatedProductsDAO.newInstance()
                    .getAssociatedProductsById(
                        new Set<Id>{builder.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'associated product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AssociatedProductsDAO().getSObjectType() == Associated_Products__c.SObjectType,
                'SObject is not Associated Products'
            );
        }
        Test.stopTest();
    }
}
