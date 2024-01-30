/**
 * @description Test Class for Lists DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                 |
 */
@isTest
public with sharing class ListsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
    }
 
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            System.assert(ListsDAO.newInstance() != null, 'ListsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getListRecords() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<List__c> listRecords = ListsDAO.newInstance()
                .getListRecords(1);
            System.assert(listRecords.isEmpty(), 'listRecords is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
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
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<List__c> listRecList = ListsDAO.newInstance()
                .getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(listRecList.isEmpty(), 'listRecList is not empty');
        }
        Test.stopTest();
    }
}