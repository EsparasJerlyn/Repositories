/**
 * @description test class for DonationsDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                                       |
 *    |--------------------------------|---------------------|------------------------|------------------------------------------------------|
 *    | nicole.genon                   | March 29, 2023      | DEPP-8167              | Created file                                         |
 *    | kim.howard.capanas             | April 22, 2024      | DEPP-8499              | Added test method for getDonationAssetsByDonationId  |
 *    | kenneth.f.alsay                | April 23, 2024      | DEPP-8528              | Added test methods for getDonationsBySetRecordIds    |
 *    | kenneth.f.alsay                | April 24, 2024      | DEPP-8528              | Added queryLocatorGetDonationsForStageUpdateTest     |
 *    | neil.s.h.lesidan               | April 30, 2024      | DEPP-8610              | Add method getDonationsByParentIdRecordTypeTest      |
 *    |                                |                     | DEPP-8570              |                                                      |
 *    |                                |                     | DEPP-8682              |                                                      |
 *    | nicole.genon                   | May 2, 2024         | DEPP-8673              | Added getDonationsBySetDonationParentIdsTest,        |
 *    |                                |                     |                        | getDonationsBySetRecordTypeIdsTest                   |
 */
@isTest
private class DonationsDAOTest {
    @testSetup
    static void testSetup () {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Sys_Admin'}
        );
        TestDataFactoryUser.generateUserAdvancementManager();
    }

    @isTest
    private static void queryLocatorGetDonationsForStageUpdateTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            System.assert(DonationsDAO.newInstance().queryLocatorGetDonationsForStageUpdate() != null, 'SOQL should not be null');
        }
    }

    @isTest
    private static void getDonationsByOpportunityIdsTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
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
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
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
    private static void getDonationAssetsByDonationIdTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Donation__c.SObjectType);
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationAssetsByDonationId(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationAssetsByDonationIdEmptyTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationAssetsByDonationId(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsBySetRecordIdsTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
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
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
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
    private static void getDonationsBySetDonationParentIdsTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Donation__c.SObjectType);
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsBySetDonationParentIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsBySetDonationParentIdsEmptyTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsBySetDonationParentIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsBySetRecordTypeIdsTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Recordtype.getSObjectType());
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsBySetRecordTypeIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }

    @isTest
    private static void getDonationsBySetRecordTypeIdsEmptyTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsBySetRecordTypeIds(
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

    @isTest
    static void getDonationsByParentIdRecordTypeTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            List<Donation__c> donationList = DonationsDAO.newInstance()
                .getDonationsByParentIdRecordType(
                    new Set<Id>(),
                    DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(donationList.isEmpty(), 'DonationList should be empty.');
        }
    }
}
