/**
 * @description test class for buyergroupsdao
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
public with sharing class BuyerGroupsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getBuyerGroupsByProductRequestIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                BuyerGroupsDAO.newInstance()
                    .getBuyerGroupsByProductRequestId(
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'buyer Group retrieved is not empty'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void getBuyerGroupsByProductRequestIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builder = new MockIdGenerator(BuyerGroup.sObjectType);
            System.assert(
                BuyerGroupsDAO.newInstance()
                    .getBuyerGroupsByProductRequestId(
                        new Set<Id>{builder.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'buyer Group retrieved is not empty'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new BuyerGroupsDAO().getSObjectType() == BuyerGroup.SObjectType,
                'SObject is not Buyer Groups'
            );
        }
        Test.stopTest();
    }
}
