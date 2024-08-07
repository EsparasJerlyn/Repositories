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
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseProgramEnrollmentAcademicStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            
            Test.startTest();
            String academicStatus = 'Showcause';
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Academic_Status__c = academicStatus;
            
            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentCriteria().getAcademicStatus(), academicStatus, 'Incorrect Academic Status');
            System.assertEquals(parser.getProgramEnrollmentCriteria().getEnrollmentStage(), ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED, 'Enrollment Stage should be set to Admitted');
            System.assertEquals(parser.getProgramEnrollmentCriteria().getEnrollmentStatus(), ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Enrollment Status should be set to Outreach');
        }
    }

    @isTest
    static void parseProgramEnrollmentPreviousAcademicStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            
            Test.startTest();
            String academicStatus = 'Showcause';
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Previous_Academic_Status__c = academicStatus;
            
            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentCriteria().getPreviousAcademicStatus(), academicStatus, 'Incorrect Previous Academic Status');
            System.assertEquals(parser.getProgramEnrollmentCriteria().getEnrollmentStage(), ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED, 'Enrollment Stage should be set to Admitted');
            System.assertEquals(parser.getProgramEnrollmentCriteria().getEnrollmentStatus(), ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Enrollment Status should be set to Outreach');
        }
    }

    @isTest
    static void parseProgramEnrollmentCategoryTypeTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';

            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentCriteria().getCategoryType(), new List<String>{'Graduate Certificate'}, 'Incorrect Category Type');       
            System.assertEquals(parser.getProgramEnrollmentCriteria().getEnrollmentStage(), ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED, 'Enrollment Stage should be set to Admitted');
            System.assertEquals(parser.getProgramEnrollmentCriteria().getEnrollmentStatus(), ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Enrollment Status should be set to Outreach');
 
        }
    }

    @isTest
    static void parseNoProgramEnrollmentCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(new Engagement_List_Criteria__c(), Date.today());
            Test.stopTest();

            System.assert(parser.getProgramEnrollmentCriteria().isEmpty(), 'No Criteria should be parsed.'); 

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
            engagementListCriteria.Key_Date__c = 'Academic Status Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(
                DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getProgramEnrollmentCriteria().getAcademicStatusDateFrom()), 
                'Incorrect Key Date Offset Lower'
            );

            System.assertEquals(
                DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getProgramEnrollmentCriteria().getAcademicStatusDateTo()), 
                'Incorrect Key Date Offset Lower'
            );
        }
    }
}