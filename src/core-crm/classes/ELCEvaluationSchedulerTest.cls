/**
 * @description Test class for ELCEvaluationScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | May 13, 2024          | DEPP-8490              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class ELCEvaluationSchedulerTest {

    @TestSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {   
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

            List<Leave_of_Absence__c> leaveOfAbsenceListCreated = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceListCreated[0].Start_Date__c = Date.today().addDays(-1); 
            leaveOfAbsenceListCreated[0].End_Date__c = Date.today().addDays(1); 
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 001;
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);

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
            engagementListCriteria.Engagement_List_Criteria_Title__c = 'Test Title';
            engagementListCriteria.Engagement_List_Configuration__c = engagementListConfig.Id;
            engagementListCriteria.Status__c = 'Active';
            engagementListCriteria.Start_Date__c = Date.today().addDays(-3);
            engagementListCriteria.End_Date__c = Date.today().addDays(3);
            engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            engagementListCriteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = EngagementListCriteriasDAO.KEY_DATE_LEAVE_OF_ABSENCE_END_DATE;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            insert engagementListCriteria;
        }
    }
    

    @isTest
    static void schedulerTest(){
		System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            String cronExpression = Label.ELC_Evaluation_Cron_Expression;
            
            Test.startTest();
                ELCEvaluationScheduler scheduler = new ELCEvaluationScheduler();
                System.schedule('Test ELC Evaluation Scheduler', cronExpression, scheduler);
            Test.stopTest();
            
            List<AsyncApexJob> jobsScheduled = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
            System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
            System.assertEquals('ELCEvaluationScheduler', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
            
            List<AsyncApexJob> jobsApexBatch = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
            System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
            System.assertEquals('ELCEvaluatorBatch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
        }
	}
}