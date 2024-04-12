/**
 * @description test class for Engagementsdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
      | alexnder.cadalin               |  May 17, 2023         | DEPP-5594              | added methods
 */
@isTest
public with sharing class EngagementsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(EngagementsDAO.newInstance() != null, 'Engagementsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new EngagementsDAO().getSObjectType() == Engagement__c.SObjectType,
                'SObject is not Engagement__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsSortByEngagementCodeAscTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Engagement__c> engagementsList = EngagementsDAO.newInstance().getRecordsSortByEngagementCodeAsc();
            System.assert(engagementsList.isEmpty(), 'engagementsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsWithLikeEngagementCodeSortAscTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Engagement__c> engagementsList = EngagementsDAO.newInstance().getRecordsWithLikeEngagementCodeSortAsc('');
            System.assert(engagementsList.isEmpty(), 'engagementsList is not empty');
        }
        Test.stopTest();
    }
}
