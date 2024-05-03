/**
 * @description Test class for ELCCourseConnectionAssessmentParser
 * @ELCCourseConnectionAssessmentParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCCourseConnectionAssessmentParserTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseCourseConnAssessmentFailedToSubmitTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {            
            
            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            
            ELCCourseConnectionAssessmentParser parser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().assessmentGrade, null, 'Assessment grade should be null');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().submissionDate, null, 'Submission Date should be null');
        }
    }

    @isTest
    static void parseCourseConnAssessmentPriorityTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Assessment_Priority__c = 'High';

            ELCCourseConnectionAssessmentParser parser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().assessmentPriority, 'High', 'Incorrect Assessment Priority');
        }
    }
}