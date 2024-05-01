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
            engagementListCriteria.Completed_Cadence__c = completedCadenceName;
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = breach.Id;
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            Test.stopTest();
            
            System.assertEquals(parser.getContactCriteria().citizenshipStatus, citizenshipStatus, 'Incorrect Citizenship Status.');
            System.assertEquals(parser.getProgramEnrollmentCriteria().academicStatus, academicStatus, 'Incorrect Academic Status');
            System.assertEquals(parser.getCompletedCadenceCriteria().completedCadence, completedCadenceName, 'Incorrect Completed Cadence');
            System.assertEquals(parser.getCourseConnectionCriteria().courseGrade, '100', 'Incorrect Course Grade');
            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().breach, breach.Id, 'Incorrect Breach Id assigned');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().assessmentGrade, null, 'Assessment grade should be null');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().submissionDate, null, 'Submission Date should be null');
            System.assertEquals(parser.getCourseConnectionAssessmentCriteria().assessmentPriority, 'High', 'Incorrect Assessment Priority');
            System.assertEquals(parser.getLeaveOfAbsencesCriteria().isOnLeave, true, 'Is On Leave should not be false');
        }
    }

}