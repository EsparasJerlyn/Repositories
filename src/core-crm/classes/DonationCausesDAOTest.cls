/**
 * @description test class for DonationCausesDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | March 15, 2023      | DEPP-8210              | Created file                              |
 */
@isTest
private class DonationCausesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Donor_Engagement_Manager' }
        );
    }
    @isTest
    private static void queryLocatorGetDonatioCausesForStageUpdateTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            System.assert(DonationCausesDAO.newInstance().queryLocatorGetDonatioCausesForStageUpdate() != null, 'SOQL should not be null');
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

}