/**
 * @description test class for DonationCausesDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | March 15, 2023      | DEPP-8210              | Created file                              |
 *    | kenneth.f.alsay                | March 27, 2023      | DEPP-8209              | Added getDonationCauseByNameStartTest     |
 */
@isTest
private class DonationCausesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Donor_Engagement_Manager', 'QUT_Advancement_Manager' }
        );
    }
    @isTest
    private static void queryLocatorGetDonatioCausesForStageUpdateTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            System.assert(DonationCausesDAO.newInstance().queryLocatorGetDonatioCausesForStageUpdate() != null, 'SOQL should not be null');
        }
    }

    @isTest
    private static void getDonationCausesBySetRecordIdsTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Donation_Cause__c.SObjectType);
            List<Donation_Cause__c> dcList = DonationCausesDAO.newInstance()
                .getDonationCausesBySetRecordIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(dcList.isEmpty(), 'ContactList should be empty.');
        }
    }

    @isTest
    private static void getDonationCausesBySetRecordIdsEmptyTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            List<Donation_Cause__c> dcList = DonationCausesDAO.newInstance()
                .getDonationCausesBySetRecordIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(dcList.isEmpty(), 'ContactList should be empty.');
        }
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            System.assert(DonationCausesDAO.newInstance() != null, 'DonationCausesDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            System.assert(
                new DonationCausesDAO().getSObjectType() == Donation_Cause__c.SObjectType,
                'SObject is not Donation_Cause__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getDonationCauseByNameStartTest(){
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Test.startTest();
            List<Donation_Cause__c> dcList = DonationCausesDAO.newInstance()
                .getDonationCauseByNameStart(
                    'Test',
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(dcList.isEmpty(), 'DonationList should be empty.');
        }
    }

}