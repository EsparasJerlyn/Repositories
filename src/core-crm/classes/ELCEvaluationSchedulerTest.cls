/**
 * @description Test class for ELCEvaluationScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | May 13, 2024          | DEPP-8658              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class ELCEvaluationSchedulerTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });

        System.runAs(TestDataFactory.getESBIntegrationUser()) {   
            Test.startTest();

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].hed__Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            List<Program_Offering__c> programOfferingListCreated = TestDataFactory.createTestProgramOfferingRecords(1, programPlanListCreated);
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingListCreated,true,AccessLevel.SYSTEM_MODE);

            List<hed__Course_Enrollment__c> courseConnectionListCreated = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingListCreated);
            courseConnectionListCreated[0].hed__Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            courseConnectionListCreated[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionListCreated[0].hed__Display_Grade__c = '100';
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);
            
            List<Assessment__c> assessmentList = TestDataFactory.createTestAssessmentRecords(1);
            assessmentList[0].Assessment_Priority__c = 'High';
            assessmentList[0].Due_Date__c = Date.today();
            AssessmentsDAO.newInstance().insertRecords(assessmentList, true, AccessLevel.SYSTEM_MODE);
            
            List<Course_Connection_Assessment__c> courseConnectionAssessmentListCreated = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionListCreated[0].Id);
            courseConnectionAssessmentListCreated[0].Assessment_Name__c = assessmentList[0].Id;
            //courseConnectionAssessmentListCreated[0].Submission_Date__c = Date.today();
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentListCreated,true,AccessLevel.SYSTEM_MODE);
            
            Engagement_List_Configuration__c engagementListConfig = new Engagement_List_Configuration__c();
            engagementListConfig.Engagement_List_Configuration_Status__c = 'Active';
            engagementListConfig.Start_Date__c = Date.today().addDays(-3);
            engagementListConfig.End_Date__c = Date.today().addDays(3);
            insert engagementListConfig;

            Breach__c breach = new Breach__c(
                Name = 'Breach Test 01'
            );
            insert breach; 

            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Engagement_List_Configuration__c = engagementListConfig.Id;
            engagementListCriteria.Status__c = 'Active';
            engagementListCriteria.Start_Date__c = Date.today().addDays(-3);
            engagementListCriteria.End_Date__c = Date.today().addDays(3);
            engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            engagementListCriteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Key_Date__c = EngagementListCriteriasDAO.KEY_DATE_ASSESSMENT_DUE_DATE;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            insert engagementListCriteria;

            Test.stopTest();
        }
    }
    

    @isTest
    static void schedulerTest(){
		System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.StartTest();
            ELCEvaluationScheduler testScheduler = new ELCEvaluationScheduler();
            String sch = '0 0 7 * * ?'; 
            String jobID = system.schedule('Test status Check', sch, testScheduler );
            Test.stopTest();
                    
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'ELCEvaluationScheduler'].isEmpty() , 'ELCEvaluationScheduler Job was not executed');
		}
	}
}