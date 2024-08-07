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
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseCourseConnAssessmentFailedToSubmitTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            
            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            
            ELCCourseConnectionAssessmentParser parser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().getAssessmentGrade(), null, 'Assessment grade should be null');
            System.assert(parser.getCourseConnectionAssessmentCriteria().getIsSubmissionDateNull(), 'Submission Date should be null');
        }
    }

    @isTest
    static void parseCourseConnAssessmentPriorityTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Assessment_Priority__c = 'High';

            ELCCourseConnectionAssessmentParser parser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().getAssessmentPriority(), 'High', 'Incorrect Assessment Priority');
        }
    }

    @isTest
    static void parseprocessKeyDateOffsetsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Date executionDate = Date.today();
            Date execDateLower = executionDate.addDays(-1);
            Date execDateUpper = executionDate.addDays(-10);

            Test.startTest();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Key_Date__c = 'Assessment Due Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCCourseConnectionAssessmentParser parser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(
                DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getCourseConnectionAssessmentCriteria().getDueDateFrom()), 
                'Incorrect Key Date Offset Lower'
            );

            System.assertEquals(
                DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getCourseConnectionAssessmentCriteria().getDueDateTo()), 
                'Incorrect Key Date Offset Upper'
            );

        }
    }
}