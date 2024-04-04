/**
 * @description Test class for LeadScoreDetailsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 *    | eccarius.munoz                 | October 04, 2023      |DEPP-5866               | Added method to get by con/lead     |
 */
@isTest
public with sharing class LeadScoreDetailsDAOTest{
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }
    
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(LeadScoreDetailsDAO.newInstance() != null, 'LeadScoreDetailsDAO instance should not be null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new LeadScoreDetailsDAO().getSObjectType() == Lead_Score_Detail__c.SObjectType,
                'SObject is not Lead_Score_Detail__c'
            );
        }
        Test.stopTest();
    }
    @isTest
    static void getLeadsWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead_Score_Detail__c> leadScoreDetailList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailWithLimit(1);
            System.assert(leadScoreDetailList.isEmpty(), 'leadScoreDetailList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreDetailsByContactOrLeadIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead_Score_Detail__c> leadScoreDetailList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(leadScoreDetailList.isEmpty(), 'leadScoreDetailList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreDetailsByCitizenshipAndStudyLevelTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead_Score_Detail__c> leadScoreDetailList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByCitizenshipAndStudyLevel(
                new Set<String>(),
                new Set<String>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(leadScoreDetailList.isEmpty(), 'leadScoreDetailList should be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getLeadScoreDetailsWithContactOrLeadTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsWithContactOrLead() != null,
                'Communication queues retrieved should not be null'
            );
            Test.stopTest();
        }
    }
    
    @isTest
    static void queryLocatorLeadScoreDetailsByCitizenshipAndStudyLevelTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                LeadScoreDetailsDAO.newInstance().queryLocatorLeadScoreDetailsByCitizenshipAndStudyLevel(
                    new Set<String>(),
                    new Set<String>()
                ) != null,
                'leadScoreDetailList should not be empty.'
            );
            Test.stopTest();
        }
    }

}