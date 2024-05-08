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

    @isTest
    static void parseprocessKeyDateOffsetsTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Date executionDate = Date.today();
            Date execDateLower = executionDate.addDays(-10);
            Date execDateUpper = executionDate.addDays(10);
            String expectedDateFrom = DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd HH:mm:ss');
            expectedDateFrom = expectedDateFrom.replaceFirst(' ', 'T') + 'Z';
            String expectedDateTo = DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd HH:mm:ss');
            expectedDateTo = expectedDateTo.replaceFirst(' ', 'T') + 'Z';

            Test.startTest();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Key_Date__c = 'Completed Cadence Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCCompletedCadenceParser parser = new ELCCompletedCadenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(DynamicQueryService.convertDatetoDateTimeGMTString(parser.getCompletedCadenceCriteria().getCompletedCadanceDateFrom()), expectedDateFrom, 'Incorrect Key Date Offset Lower');
            System.assertEquals(DynamicQueryService.convertDatetoDateTimeGMTString(parser.getCompletedCadenceCriteria().getCompletedCadanceDateTo()), expectedDateTo, 'Incorrect Key Date Offset Upper');
        }
    }
}