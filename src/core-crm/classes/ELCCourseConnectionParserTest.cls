/**
 * @description Test class for ELCCourseConnectionParser
 * @ELCCourseConnectionParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCCourseConnectionParserTest {
    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseCourseConnCourseGradeTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {            
            
            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Course_Grade__c = '100';
            
            ELCCourseConnectionParser parser = new ELCCourseConnectionParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionCriteria().courseGrade, '100', 'Incorrect Course Grade');
        }
    }

    @isTest
    static void parseCourseConnHiddenCriteriaTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();

            ELCCourseConnectionParser parser = new ELCCourseConnectionParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionCriteria().status, ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Status should be set to Outreach');

        }
    }
}