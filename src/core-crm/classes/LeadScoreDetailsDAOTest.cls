/**
 * @description DAO Class for Lead_Score_Detail__c Object. Contains soql and constants related to the Lead_Score_Detail__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 */
@isTest
public with sharing class LeadScoreDetailsDAOTest{
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(LeadScoreDetailsDAO.newInstance() != null, 'LeadScoreDetailsDAO instance is null');
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
}