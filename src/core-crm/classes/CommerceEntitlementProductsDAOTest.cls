/**
 * @description test class for commerceentitlementproductsDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
@isTest
public with sharing class CommerceEntitlementProductsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getCommerceEntitlementProductByPolicyIdAndProductIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                CommerceEntitlementProductsDAO.newInstance()
                    .getCommerceEntitlementProductByPolicyIdAndProductId(
                        new List<Id>(),
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Commerce Entitlement Products retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCommerceEntitlementProductByPolicyIdAndProductIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builderForCommerceEntitlementBuyerGroup = new MockIdGenerator(CommerceEntitlementBuyerGroup.sObjectType);
            MockIdGenerator builderForAssociatedProducts = new MockIdGenerator(Associated_Products__c.sObjectType);
            System.assert(
                CommerceEntitlementProductsDAO.newInstance()
                    .getCommerceEntitlementProductByPolicyIdAndProductId(
                        new List<Id>{builderForCommerceEntitlementBuyerGroup.getMockId()},
                        new Set<Id>{builderForAssociatedProducts.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Commerce Entitlement Products retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new CommerceEntitlementProductsDAO().getSObjectType() == CommerceEntitlementProduct.SObjectType,
                'SObject is not Commerce Entitlement Products'
            );
        }
        Test.stopTest();
    }
}
