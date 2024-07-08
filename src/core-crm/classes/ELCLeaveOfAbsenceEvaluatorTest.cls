/**
 * @description Test Class for ELCLeaveOfAbsenceEvaluator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | arsenio.jr.dayrit              | May 09, 2024          | DEPP-8487              | Created file                                                |
*/
@isTest
public with sharing class ELCLeaveOfAbsenceEvaluatorTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    static void evaluateWithReturnTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';

    
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            contactList[0].hed__Citizenship_Status__c = citizenshipStatus;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
    
            List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            List<Leave_of_Absence__c> leaveOfAbsenceListCreated = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceListCreated[0].Start_Date__c = System.today().addDays(-1);
            leaveOfAbsenceListCreated[0].End_Date__c = System.today().addDays(1);
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 1;
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);

            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCLeaveOfAbsenceEvaluator evaluator = new ELCLeaveOfAbsenceEvaluator(parser);
            Map<Id, List<Leave_of_Absence__c>> evaluateMap =  evaluator.evaluate(new Map<Id, Contact>(contactList));

            Test.stopTest();
            System.assert(evaluateMap.containsKey(contactList[0].Id), 'The Map should have a contact Id as a Key');
            System.assert(!evaluateMap.get(contactList[0].Id).isEmpty(), 'The Map should have Leave of Absence');
            System.assertNotEquals(null, evaluateMap.size() , ' The Evaluator should have a return');

        }
    }

}