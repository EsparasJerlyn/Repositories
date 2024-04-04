/**
 * @description test class for DonationsDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | nicole.genon                   | March 29, 2023      | DEPP-8167              | Created file                              |
 */
@isTest
private class DonationsDAOTest {
    @testSetup
    static void testSetup () {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Sys_Admin' }
        );
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