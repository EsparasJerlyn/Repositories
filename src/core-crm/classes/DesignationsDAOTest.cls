/**
 * @description test class for DesignationsDAO.
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
private class DesignationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Donor_Engagement_Manager', 'QUT_Advancement_Manager' }
        );
    }
    @isTest
    private static void queryLocatorDesignationsForStageUpdateTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            System.assert(DesignationsDAO.newInstance().queryLocatorGetDesignationsForStageUpdate() != null, 'SOQL should not be null');
        }
    }

    @isTest
    private static void getDesignationsBySetRecordIdsTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Designation__c.SObjectType);
            List<Designation__c> dcList = DesignationsDAO.newInstance()
                .getDesignationsBySetRecordIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(dcList.isEmpty(), 'ContactList should be empty.');
        }
    }

    @isTest
    private static void getDesignationsBySetRecordIdsEmptyTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            List<Designation__c> dcList = DesignationsDAO.newInstance()
                .getDesignationsBySetRecordIds(
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
            System.assert(DesignationsDAO.newInstance() != null, 'DesignationsDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            System.assert(
                new DesignationsDAO().getSObjectType() == Designation__c.SObjectType,
                'SObject is not Designation__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getDesignationByNameStartTest(){
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Test.startTest();
            List<Donation_Cause__c> dcList = DonationCausesDAO.newInstance()
                .getDesignationByNameStart(
                    'Test',
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(dcList.isEmpty(), 'DonationList should be empty.');
        }
    }

}