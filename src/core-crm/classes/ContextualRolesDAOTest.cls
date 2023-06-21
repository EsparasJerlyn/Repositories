/**
 * @description test class for ContextualRolesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | June 19, 2023         | DEPP-5748              | Created file
 */
@isTest
private class ContextualRolesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                ContextualRolesDAO.newInstance() != null,
                'ContextualRolesDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new ContextualRolesDAO().getSObjectType() == Contextual_Role__c.SObjectType,
                'SObject is not Contextual_Role__c'
            );
        }
        Test.stopTest();
    }
}
