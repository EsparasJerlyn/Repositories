/**
 * @description test class for Stewardships
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                                  |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------------------------|
 *    | nicole.genon                   | March 7, 2024         | DEPP-7922              | Created file                                                                                    |
 */
@isTest
private class StewardshipsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserDonorEngagementManager();
        List<Stewardship__c> newStewardshipList = new List<Stewardship__c>();
        List<Stewardship__c> individualStewardshipList = TestDataFactory.createStewardshipRecords(StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID,20);
        List<Stewardship__c> organisationStewardshipList = TestDataFactory.createStewardshipRecords(StewardshipsDAO.ORGANISATION_STEWARDSHIP_RECTYPE_ID,20);

        newStewardshipList.addAll(individualStewardshipList);
        newStewardshipList.addAll(organisationStewardshipList);

        StewardshipsDAO.newInstance().insertRecords(newStewardshipList, false, AccessLevel.USER_MODE);
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            System.assert(StewardshipsDAO.newInstance() != null, 'StewardshipsDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            System.assert(
                new StewardshipsDAO().getSObjectType() == Stewardship__c.SObjectType,
                'SObject is not Stewardship__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getStewardshipBySetIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Stewardship__c> stewardshipsList = StewardshipsDAO.newInstance()
                .getStewardshipBySetIds(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(stewardshipsList.isEmpty(), 'stewardshipsList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getStewardshipBySetIdsNotEmpty() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            MockIdGenerator stewardshipMock = new MockIdGenerator(Stewardship__c.SObjectType);
            List<Stewardship__c> stewardshipsList = StewardshipsDAO.newInstance()
                .getStewardshipBySetIds(
                    new Set<Id>{stewardshipMock.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(stewardshipsList.isEmpty(), 'stewardshipsList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getStewardshipByRecordTypeIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Stewardship__c> stewardshipsList = StewardshipsDAO.newInstance()
                .getStewardshipByRecordTypeIds(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(stewardshipsList.isEmpty(), 'stewardshipsList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getStewardshipByRecordTypeIdsNotEmpty() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            MockIdGenerator recordTypeMock = new MockIdGenerator(Recordtype.getSObjectType());
            List<Stewardship__c> stewardshipsList = StewardshipsDAO.newInstance()
                .getStewardshipByRecordTypeIds(
                    new Set<Id>{recordTypeMock.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(stewardshipsList.isEmpty(), 'stewardshipsList should not be empty');
        }
        Test.stopTest();
    }
}