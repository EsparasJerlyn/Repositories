/**
 * @description Test class for ELCParser
 * @ELCParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | May 1, 2024           | DEPP-8489              | Created file                 |
 */
@isTest
public with sharing class ELCParserTest {

    @testSetup
    static void setupMethod() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void setBodyValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            //create breach record
            Breach__c breach = new Breach__c(
                Name = 'Breach Test 01'
            );
            insert breach; 
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String keyDateLeaveOfAbsence = 'Leave Of Absence End Date';
            String academicStatus = 'Showcause';
            String completedCadenceName = 'Domestic Accepted and Admitted';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Completed_Cadence__c = completedCadenceName;
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = breach.Id;
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = keyDateLeaveOfAbsence;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            Test.stopTest();

            //Checking on the executionDate and elc
            System.assertEquals(parser.getEngagementListCriteria(), engagementListCriteria, 'Incorrect engagementListCriteria');
            System.assertEquals(parser.getExecutionDate(), executionDate, 'Incorrect executionDate');

            //Checking on the criterions 
            System.assertEquals(parser.getELCContactParser().getContactCriteria().getCitizenshipStatus(), citizenshipStatus, 'Incorrect Citizenship Status.');
            System.assertEquals(parser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().getAcademicStatus(), academicStatus, 'Incorrect Academic Status');
            //System.assertEquals(parser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().getCategoryType(), 'Graduate Certificate', 'Incorrect Category Type');
            System.assertEquals(parser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().getCompletedCadence(), completedCadenceName, 'Incorrect Completed Cadence');
            System.assertEquals(parser.getELCCourseConnectionParser().getCourseConnectionCriteria().getCourseGrade(), '100', 'Incorrect Course Grade');
            System.assertEquals(parser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().getBreach(), breach.Id, 'Incorrect Breach Id assigned');
            System.assertEquals(parser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().getAssessmentGrade(), null, 'Assessment grade should be null');
            System.assertEquals(parser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().getIsSubmissionDateNull(), true, 'Submission Date should be null');
            System.assertEquals(parser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().getAssessmentPriority(), 'High', 'Incorrect Assessment Priority');
            System.assertEquals(parser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().getIsOnLeave(), true, 'Is On Leave should not be false');
            
            //Checking on the key date criterions
            Date execDateLower = executionDate.addDays(-1);
            Date execDateUpper = executionDate.addDays(-10);
            System.assertEquals(DynamicQueryService.convertDatetoDateString(parser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().getEndDateFrom()), DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd'), 'Incorrect Key Date Offset Lower');
            System.assertEquals(DynamicQueryService.convertDatetoDateString(parser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().getEndDateTo()), DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd'), 'Incorrect Key Date Offset Upper');

            //Checking on the hidden criterias
            System.assertEquals(parser.getELCContactParser().getContactCriteria().getRecordType(), ContactsDAO.PERSON_RECORDTYPE , 'Incorrect Contact record type'); 
            System.assertEquals(parser.getELCContactParser().getContactCriteria().getIsQUTStudent(), true, 'Contact is not set as QUT student');
            System.assertEquals(parser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().getEnrollmentStage(), ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED, 'Enrollment Stage should be set to Admitted');
            System.assertEquals(parser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().getEnrollmentStatus(), ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Enrollment Status should be set to Outreach');
            System.assertEquals(parser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().getStatus(), CompletedCadencesDAO.SUCCESSFUL_STATUS, 'Status should be set to Succesful');
            System.assertEquals(parser.getELCCourseConnectionParser().getCourseConnectionCriteria().getStatus(), ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Status should be set to Outreach');
            System.assertEquals(parser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().getBreachStatus(), ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH, 'Status shoul be set to Breach Statuses');

        }
    }


}
