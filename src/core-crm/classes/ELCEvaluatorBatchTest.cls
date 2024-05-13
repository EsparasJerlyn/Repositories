/**
 * @description Test class for ELCEvaluatorTest
 * @ELCEvaluator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | May 14, 2024          | DEPP-8490              | Created file                 |
 */
@isTest
public with sharing class ELCEvaluatorBatchTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });

        System.runAs(TestDataFactory.getESBIntegrationUser()) {   

            //Create Contact records
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);

            //Create Completed Cadence records
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted and Admitted',
                        Lead_Score_Threshold__c = 3
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);    

            List<Completed_Cadence__c> completedCadenceList = TestDataFactory.createCompletedCadence('Successful',nurtureList[0].Id,new Set<Id>{contactList[0].Id});
        
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanList[0].Category_Type__c = 'Graduate Certificate';
        
            ProgramPlansDAO.newInstance().insertRecords(programPlanList,true,AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Enrollment__c>  programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentList[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentList[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            programEnrollmentList[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentList[0].hed__Program_Plan__c = programPlanList[0].Id;
            programEnrollmentList[0].Academic_Status_Date__c = Date.today();
        
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList,true,AccessLevel.SYSTEM_MODE);
            
            List<Program_Offering__c> programOfferingList = TestDataFactory.createTestProgramOfferingRecords(1, programPlanList);
        
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingList,true,AccessLevel.SYSTEM_MODE);

            //Create Leave of Absence records
            List<Leave_of_Absence__c> leaveOfAbsenceList = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceList[0].Start_Date__c = Date.today().addDays(-1); 
            leaveOfAbsenceList[0].End_Date__c = Date.today().addDays(1); 
            leaveOfAbsenceList[0].hed_Program_Enrollment__c = programEnrollmentList[0].Id;
            leaveOfAbsenceList[0].Leave_No__c = 001;
            leaveOfAbsenceList[0].Student__c = contactList[0].Id;
        
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceList,true,AccessLevel.SYSTEM_MODE);

            //Create Course Connection records
            List<hed__Course_Enrollment__c> courseConnectionList = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingList);
            courseConnectionList[0].hed__Program_Enrollment__c = programEnrollmentList[0].Id;
            courseConnectionList[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionList[0].hed__Display_Grade__c = '100';
        
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionList,true,AccessLevel.SYSTEM_MODE);

            //Create Program Enrollement Breach records
            List<Breach__c> breachList = TestDataFactory.createTestBreachRecords(1);
            breachList[0].Name = 'Breach Test 01';
			BreachesDAO.newInstance().insertRecords(breachList,true,AccessLevel.USER_MODE);

            List<Program_Enrollment_Breach__c> programEnrollmentBreachList = TestDataFactory.createTestProgramEnrollmentBreachRecords(1);
            programEnrollmentBreachList[0].Contact__c = contactList[0].Id;
            programEnrollmentBreachList[0].Breach_Name__c = breachList[0].Id;
            programEnrollmentBreachList[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            programEnrollmentBreachList[0].Breach_Status__c = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS;
            ProgramEnrollmentBreachesDAO.newInstance().insertRecords(programEnrollmentBreachList,true,AccessLevel.SYSTEM_MODE);

            //Create Course Connection Assessment records
            List<Assessment__c> assessmentList = TestDataFactory.createTestAssessmentRecords(1);
            assessmentList[0].Assessment_Priority__c = 'Low';
            assessmentList[0].Due_Date__c = Date.today();
            AssessmentsDAO.newInstance().insertRecords(assessmentList, true, AccessLevel.SYSTEM_MODE);
            
            List<Course_Connection_Assessment__c> courseConnectionAssessmentList = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionList[0].Id);
            courseConnectionAssessmentList[0].Submission_Date__c = Date.today();
            courseConnectionAssessmentList[0].Assessment_Name__c = assessmentList[0].Id;
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentList,true,AccessLevel.SYSTEM_MODE);

            Test.startTest();			            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = null;
            engagementListCriteria.Academic_Status__c = null;
            engagementListCriteria.Category_Type__c = null;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = null;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = null;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = null;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());

            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            Test.stopTest();
            
        }
    }
    
    @isTest
    static void testBatchExecution() {
        //batch execution test here
    }

}
