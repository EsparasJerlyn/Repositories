/**
 * @description test class for commerceentitlementbuyergroupsDAO
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
public with sharing class CommerceEntitlementBuyerGroupsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getCommerceEntitlementBuyerGroupsByBuyerGroupIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                CommerceEntitlementBuyerGroupsDAO.newInstance()
                    .getCommerceEntitlementBuyerGroupsByBuyerGroupId(
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Commerce Entitlement Buyer Group retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCommerceEntitlementBuyerGroupsByBuyerGroupIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builder = new MockIdGenerator(CommerceEntitlementBuyerGroup.sObjectType);
            System.assert(
                CommerceEntitlementBuyerGroupsDAO.newInstance()
                    .getCommerceEntitlementBuyerGroupsByBuyerGroupId(
                        new Set<Id>{builder.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Commerce Entitlement Buyer Group retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new CommerceEntitlementBuyerGroupsDAO().getSObjectType() == CommerceEntitlementBuyerGroup.SObjectType,
                'SObject is not Commerce Entitlement Buyer Group'
            );
        }
        Test.stopTest();
    }
}
