/**
 * @description Test class for ELCProgramEnrollmentParser
 * @ELCProgramEnrollmentParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCProgramEnrollmentParserTest {
    
    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseProgramEnrollmentAcademicStatusTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {            
            
            Test.startTest();
            String academicStatus = 'Showcause';
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Academic_Status__c = academicStatus;
            
            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentCriteria().academicStatus, academicStatus, 'Incorrect Academic Status');
        }
    }

    @isTest
    static void parseProgramEnrollmentCategoryTypeTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';

            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentCriteria().categoryType, 'Graduate Certificate', 'Incorrect Category Type');            
        }
    }

    @isTest
    static void parseProgramEnrollmentHiddenCriteriaTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();

            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentCriteria().enrollmentStage, ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED, 'Enrollment Stage should be set to Admitted');
            System.assertEquals(parser.getProgramEnrollmentCriteria().enrollmentStatus, ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Enrollment Status should be set to Outreach');

        }
    }
}