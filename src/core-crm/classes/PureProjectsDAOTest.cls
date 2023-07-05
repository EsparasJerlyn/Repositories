/**
 * @description test class for PureProjectsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------|
 *    | ryan.j.a.dela.cruz             | July 03, 2023         | DEPP-5390              | Created file                           |
 */
@isTest
private class PureProjectsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                PureProjectsDAO.newInstance() != null,
                'PureProjectsDAO instance should not be null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new PureProjectsDAO().getSObjectType() == Pure_Project__c.SObjectType,
                'SObject should be Pure_Project__c'
            );
        }
        Test.stopTest();
    }
}
