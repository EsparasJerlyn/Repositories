/**
 * @description Test class for ELCCompletedCadenceParser
 * @ELCCompletedCadenceParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCCompletedCadenceParserTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseCompletedCadenceTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {            
            
            Test.startTest();
            String completedCadenceName = 'Domestic Accepted and Admitted';
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Completed_Cadence__c = completedCadenceName;
            
            ELCCompletedCadenceParser parser = new ELCCompletedCadenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCompletedCadenceCriteria().getCompletedCadence(), completedCadenceName, 'Incorrect Completed Cadence');
        }
    }

    @isTest
    static void parseCompletedCadenceHiddenCriteriaTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            
            ELCCompletedCadenceParser parser = new ELCCompletedCadenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCompletedCadenceCriteria().getStatus(), CompletedCadencesDAO.SUCCESSFUL_STATUS, 'Status should be set to Succesful');      
        }
    }
}