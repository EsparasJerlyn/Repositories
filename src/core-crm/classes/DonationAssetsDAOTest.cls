/**
 * @description test class for DonationAssetsDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | nicole.genon                   | April 22, 2024      | DEPP-8498              | Created file                              |
 */
@isTest
private class DonationAssetsDAOTest {
    @testSetup
    static void testSetup () {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Sys_Admin' }
        );
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(DonationAssetsDAO.newInstance() != null, 'DonationAssetsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new DonationAssetsDAO().getSObjectType() == Donation_Asset__c.SObjectType,
                'SObject is not Donation_Asset__c'
            );
        }
        Test.stopTest();
    }
}