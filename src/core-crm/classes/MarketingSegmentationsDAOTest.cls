/* @description DAO Test Class for Marketing Segmentation 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                 |
 */
@isTest
public with sharing class MarketingSegmentationsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator'});
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(MarketingSegmentationsDAO.newInstance() != null, 'MarketingSegmentationsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new MarketingSegmentationsDAO().getSObjectType() == Marketing_Segmentation__c.SObjectType,
                'SObject is not Marketing_Segmentation__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByContactOrLeadTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactOrLead(
                    new Set<Id>(),
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetMarketingSegmentationsByContactOrLeadIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                MarketingSegmentationsDAO.newInstance().queryLocatorGetMarketingSegmentationsByContactOrLeadIds(
                    new Set<Id>()
                ) != null,
                'marketingSegmentationList should not be empty.'
            );
            Test.stopTest();
        }
    }
}