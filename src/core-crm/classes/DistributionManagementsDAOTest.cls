/**
 * @description test class for DistributionManagementsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                 |
      | kenneth.f.alsay                | April 10, 2024        | DEPP-8452              | queryLocatorGetDistributionManagementsForStatusUpdateTest
                                                                                          getDistributionManagementsBySetRecordIdsTest |
*/
@isTest
public with sharing class DistributionManagementsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserAdvancementManager();
    }

    @isTest
    private static void queryLocatorGetDistributionMgtsForStatusUpdate(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            System.assert(DistributionManagementsDAO.newInstance().queryLocatorGetDistributionMgtsForStatusUpdate() != null, 'SOQL should not be null');
        }
    }
    
    @isTest
    static void getDistributionManagementByDesignationIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(
                DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>(),
                        AccessLevel.USER_MODE)
                    .isEmpty(),
                'Distribution Management retrieved is not empty'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getDistributionManagementByDesignationIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            MockIdGenerator builderForDistributionManagement = new MockIdGenerator(Distribution_Management__c.sObjectType);
            System.assert(
                DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>{builderForDistributionManagement.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Distribution Management retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void getDistributionManagementsBySetRecordIdsTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Distribution_Management__c.SObjectType);
            List<Distribution_Management__c> distributionManagementList = DistributionManagementsDAO.newInstance()
                .getDistributionManagementsBySetRecordIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(distributionManagementList.isEmpty(), 'distributionManagementList should be empty.');
        }
    }

    @isTest
    private static void getDistributionManagementsBySetRecordIdsEmptyTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            List<Distribution_Management__c> distributionManagementList = DistributionManagementsDAO.newInstance()
                .getDistributionManagementsBySetRecordIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(distributionManagementList.isEmpty(), 'distributionManagementList should be empty.');
        }
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(DistributionManagementsDAO.newInstance() != null, 'DistributionManagementsDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(
                new DistributionManagementsDAO().getSObjectType() == Distribution_Management__c.SObjectType,
                'SObject is not Distribution_Management__c'
                );
        }
        Test.stopTest();
    }
}