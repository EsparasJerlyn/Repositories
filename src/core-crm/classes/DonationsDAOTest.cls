/**
 * @description test class for DonationsDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                                       |
 *    |--------------------------------|---------------------|------------------------|------------------------------------------------------|
 *    | nicole.genon                   | March 29, 2023      | DEPP-8167              | Created file                                         |
 *    | kenneth.f.alsay                | April 23, 2024      | DEPP-8528              | Added test methods for getDonationsBySetRecordIds    |
 *    | kenneth.f.alsay                | April 24, 2024      | DEPP-8528              | Added queryLocatorGetDonationsForStageUpdateTest     |
 */
@isTest
private class DonationsDAOTest {
    @testSetup
    static void testSetup () {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Sys_Admin', 'QUT_Advancement_Manager'}
        );
    }

    @isTest
    private static void queryLocatorGetDonationsForStageUpdateTest(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            System.assert(DonationsDAO.newInstance().queryLocatorGetDonationsForStageUpdate() != null, 'SOQL should not be null');
        }
    }

    @isTest
    private static void getDonationsByOpportunityIdsTest(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Donation__c.SObjectType);
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsByOpportunityIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsByOpportunityIdsEmptyTest(){
        System.runAs(TestDataFactory.getPortalSysAdminUser()){
            Test.startTest();
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsByOpportunityIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsBySetRecordIdsTest(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Donation__c.SObjectType);
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsBySetRecordIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsBySetRecordIdsEmptyTest(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            Test.startTest();
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsBySetRecordIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(DonationsDAO.newInstance() != null, 'DonationsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new DonationsDAO().getSObjectType() == Donation__c.SObjectType,
                'SObject is not Donation__c'
            );
        }
        Test.stopTest();
    }
}