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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getCommerceEntitlementProductByPolicyIdAndProductIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CommerceEntitlementProductsDAO().getSObjectType() == CommerceEntitlementProduct.SObjectType,
                'SObject is not Commerce Entitlement Products'
            );
        }
        Test.stopTest();
    }
}
