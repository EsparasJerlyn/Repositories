/**
 * @description test class for Designation Code Auto Numbers DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
 */
@isTest
private class DesignationCodeAutoNumbersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                DesignationCodeAutoNumbersDAO.newInstance() != null,
                'DesignationCodeAutoNumbersDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new DesignationCodeAutoNumbersDAO().getSObjectType() == Designation_Code_Auto_Number__c.SObjectType,
                'SObject is not Designation_Code_Auto_Number__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOrganizationalDefaults() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults() == new Designation_Code_Auto_Number__c(),
                'Org defaults is not a new instance of the setting'
            );
        }
    }
}