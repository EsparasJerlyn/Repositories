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

    @testSetup static void setupMethod() {
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void setBodyValuesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            //create breach record
            Breach__c breach = new Breach__c(
                Name = 'Breach Test 01'
            );
            insert breach; 
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
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
            engagementListCriteria.Key_Date__c = 'Leave of Absence End Date';
            engagementListCriteria.Key_Date_Offset__c = 10;

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            Test.stopTest();

            //Checking on the criterions 
            System.assertEquals(parser.getContactCriteria().citizenshipStatus, citizenshipStatus, 'Incorrect Citizenship Status.');
            System.assertEquals(parser.getProgramEnrollmentCriteria().academicStatus, academicStatus, 'Incorrect Academic Status');
            System.assertEquals(parser.getProgramEnrollmentCriteria().categoryType, 'Graduate Certificate', 'Incorrect Category Type');
            System.assertEquals(parser.getCompletedCadenceCriteria().completedCadence, completedCadenceName, 'Incorrect Completed Cadence');
            System.assertEquals(parser.getCourseConnectionCriteria().courseGrade, '100', 'Incorrect Course Grade');
            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().breach, breach.Id, 'Incorrect Breach Id assigned');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().assessmentGrade, null, 'Assessment grade should be null');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().submissionDate, null, 'Submission Date should be null');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().assessmentPriority, 'High', 'Incorrect Assessment Priority');
            System.assertEquals(parser.getLeaveOfAbsencesCriteria().isOnLeave, true, 'Is On Leave should not be false');
            System.assertEquals(parser.getLeaveOfAbsencesCriteria().keyDateOffset, 10, 'Incorrect Key Date Offset');
            System.assertEquals(parser.getLeaveOfAbsencesCriteria().executionDate, executionDate, 'Incorrect Excecution Date');

            //Checking on the hidden criterias
            System.assertEquals(parser.getContactCriteria().recordType, ContactsDAO.PERSON_RECORDTYPE , 'Incorrect Contact record type'); 
            System.assertEquals(parser.getContactCriteria().isQUTStudent, true, 'Contact is not set as QUT student');
            System.assertEquals(parser.getProgramEnrollmentCriteria().enrollmentStage, ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED, 'Enrollment Stage should be set to Admitted');
            System.assertEquals(parser.getProgramEnrollmentCriteria().enrollmentStatus, ProgramEnrollmentsDAO.ENROLLMENT_STATUS_FOR_OUTREACH, 'Enrollment Status should be set to Outreach');
            System.assertEquals(parser.getCompletedCadenceCriteria().status, CompletedCadencesDAO.SUCCESSFUL_STATUS, 'Status should be set to Succesful');
            System.assertEquals(parser.getCourseConnectionCriteria().status, CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH, 'Status should be set to Outreach');
            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().breachStatus, ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH, 'Status shoul be set to Breach Statuses');

        }
    }

    @isTest
    static void setEmptyBodyValuesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            Test.stopTest();

            //Checking all related object criterias 
            System.assert(parser.getContactCriteria() == null, 'Contact criteria is not set');
            System.assert(parser.getCompletedCadenceCriteria() == null, 'Completed Cadence criteria is not set');
            System.assert(parser.getCourseConnectionAssessmentCriteria() == null, 'Course Connection Assessment criteria is not set');
            System.assert(parser.getCourseConnectionCriteria() == null, 'Course Connection criteria is not set');
            System.assert(parser.getLeaveOfAbsencesCriteria() == null, 'Leave of Absence criteria is not set');
            System.assert(parser.getProgramEnrollmentBreachCriteria() == null, 'Program Enrollment Breach criteris is not set');
            System.assert(parser.getProgramEnrollmentCriteria() == null, 'Program Enrollment criteria is not set');

        }
    }

}