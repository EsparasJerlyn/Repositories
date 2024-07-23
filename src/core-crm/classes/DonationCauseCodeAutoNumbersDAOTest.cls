/**
 * @description test class for Donation Cause Code Auto Numbers DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
 */
@isTest
private class DonationCauseCodeAutoNumbersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                DonationCauseCodeAutoNumbersDAO.newInstance() != null,
                'DonationCauseCodeAutoNumbersDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new DonationCauseCodeAutoNumbersDAO().getSObjectType() == Donation_Cause_Code_Auto_Number__c.SObjectType,
                'SObject is not Donation_Cause_Code_Auto_Number__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOrganizationalDefaults() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults() == new Donation_Cause_Code_Auto_Number__c(),
                'Org defaults is not a new instance of the setting'
            );
        }
    }
}
