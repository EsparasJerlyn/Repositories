/**
 * @description Test Class for ELCCourseEnrollmentEvaluator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eugene.andrew.abuan            | May 07, 2024          | DEPP-8487              | Created file                                                |
*/
@isTest
public with sharing class ELCCourseEnrollmentEvaluatorTest {
    
    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    static void eLCCourseEnrollmentEvaluatorConstructorTest (){
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCCourseEnrollmentEvaluator evaluator = new ELCCourseEnrollmentEvaluator(parser);

            Test.stopTest();

            System.assertNotEquals(null, evaluator, 'The evaluator instance should be initialized.');
        }
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
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = 'Leave of Absence End Date';
    
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
    
            List<Program_Offering__c> programOfferingListCreated = TestDataFactory.createTestProgramOfferingRecords(1, programPlanListCreated);
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingListCreated,true,AccessLevel.SYSTEM_MODE);
    
            List<hed__Course_Enrollment__c> courseConnectionListCreated = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingListCreated);
            courseConnectionListCreated[0].hed__Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            courseConnectionListCreated[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionListCreated[0].hed__Display_Grade__c = '100';
            courseConnectionListCreated[0].hed__Contact__c = contactList[0].Id;
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);
            
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCCourseEnrollmentEvaluator evaluator = new ELCCourseEnrollmentEvaluator(parser);
            Map<Id, List<hed__Course_Enrollment__c>> evaluateMap =  evaluator.evaluate(new Map<Id, Contact>(contactList));

            Test.stopTest();

            System.assert(evaluateMap.containsKey(contactList[0].Id), 'The Map should have a contact Id as a Key');
            System.assert(!evaluateMap.get(contactList[0].Id).isEmpty(), 'The Map should have a Course Connection Assesement');
            System.assertNotEquals(null, evaluateMap.size() , ' The Evaluator should have a return');

        }
    }
}
