/**
 * @description Test Class for Lists DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
 *    | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                                    |
 *    | ryan.j.a.dela.cruz             | April 30, 2024        | N/A - ST FIX           | Added accessLevel param for getListRecords      |
 */
@isTest
public with sharing class ListsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserAlumniEngagementManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            System.assert(ListsDAO.newInstance() != null, 'ListsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getListRecords() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<List__c> listRecords = ListsDAO.newInstance()
                .getListRecords(1, AccessLevel.USER_MODE);
            System.assert(listRecords.isEmpty(), 'listRecords is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            System.assert(
                new ListsDAO().getSObjectType() == List__c.SObjectType,
                'SObject is not List__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getListRecordsByRelatedEngagementOpportunitySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<List__c> listRecList = ListsDAO.newInstance()
                .getListRecordsByRelatedEngagementOpportunitySetIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(listRecList.isEmpty(), 'listRecList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getListByRecordIdNameTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.SYSTEM_MODE);

            List<List__c> listRecListEmptyFilter = ListsDAO.newInstance()
                .getListByRecordIdName(newListRecords[0].Id, '', AccessLevel.SYSTEM_MODE);

            List<List__c> listRecListHasFilter = ListsDAO.newInstance()
                .getListByRecordIdName(newListRecords[0].Id, 'test', AccessLevel.SYSTEM_MODE);

            System.assert(listRecListEmptyFilter.isEmpty(), 'listRecList is not empty');
            System.assert(listRecListHasFilter.isEmpty(), 'listRecList is not empty');
        }
        Test.stopTest();
    }
}
