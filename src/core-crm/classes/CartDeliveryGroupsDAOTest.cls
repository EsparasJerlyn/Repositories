/**
 * @description test class for CartDeliveryGroupsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
@isTest
public with sharing class CartDeliveryGroupsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(CartDeliveryGroupsDAO.newInstance() != null, 'CartDeliveryGroupsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new CartDeliveryGroupsDAO().getSObjectType() == CartDeliveryGroup.SObjectType,
                'SObject is not CartDeliveryGroup'
            );
        }
        Test.stopTest();
    }
}
