/**
 * @description Test Class for ELCProgramEnrollmentBreachEvaluator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | arsenio.jr.dayrit              | May 09, 2024          | DEPP-8487              | Created file                                                |
*/
@isTest
public with sharing class ELCProgramEnrollmentBreachEvaluatorTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void evaluateWithReturnTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';

            List<Breach__c> breachList = TestDataFactory.createTestBreachRecords(1);
            breachList[0].Name = 'Breach Test 01';
			BreachesDAO.newInstance().insertRecords(breachList,true,AccessLevel.USER_MODE);

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Breach__c = breachList[0].Id;

    
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

            List<Program_Enrollment_Breach__c> programEnrollmentBreachListCreated = TestDataFactory.createTestProgramEnrollmentBreachRecords(1);
            programEnrollmentBreachListCreated[0].Contact__c = contactList[0].Id;
            programEnrollmentBreachListCreated[0].Breach_Name__c = breachList[0].Id;
            programEnrollmentBreachListCreated[0].Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            programEnrollmentBreachListCreated[0].Breach_Status__c = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS;
            ProgramEnrollmentBreachesDAO.newInstance().insertRecords(programEnrollmentBreachListCreated,true,AccessLevel.SYSTEM_MODE);

            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCProgramEnrollmentBreachEvaluator evaluator = new ELCProgramEnrollmentBreachEvaluator(parser);
            Map<Id, List<Program_Enrollment_Breach__c>> evaluateMap =  evaluator.evaluate(new Map<Id, Contact>(contactList));

            Test.stopTest();
            System.assert(evaluateMap.containsKey(contactList[0].Id), 'The Map should have a contact Id as a Key');
            System.assert(!evaluateMap.get(contactList[0].Id).isEmpty(), 'The Map should have Program Enrollment Breach');
            System.assertNotEquals(null, evaluateMap.size() , ' The Evaluator should have a return');

        }
    }

}