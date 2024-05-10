/**
 * @description Test Class for ELCCourseConnectionAssessmentEvaluator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eugene.andrew.abuan            | May 07, 2024          | DEPP-8487              | Created file                                                |
*/
@isTest
private with sharing class ELCContactEvaluatorTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Student_Success_Outreach_Manager', 'QUT_ESB' });
    }

    @isTest
    static void eLCContactEvaluatorTest (){
        System.runAs(TestDataFactory.getStudentSuccessOutreachManager()) {

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCCourseConnectionAssessmentEvaluator evaluator = new ELCCourseConnectionAssessmentEvaluator(parser);

            Test.stopTest();

            System.assertNotEquals(null, evaluator, 'The evaluator instance should be initialized.');
        }
    }

    @isTest
    static void evaluateWithReturnTest(){
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
    
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            contactList[0].hed__Citizenship_Status__c = citizenshipStatus;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
    
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCContactEvaluator evaluator = new ELCContactEvaluator(parser);
            Map<Id, Contact> evaluateMap =  evaluator.evaluate(new Map<Id, Contact>(contactList));

            Test.stopTest();

            System.assert(evaluateMap.containsKey(contactList[0].Id), 'The Map should have a contact Id as a Key');
            System.assertNotEquals(null, evaluateMap.size() , ' The Evaluator should have a return');
        }
    }

    @isTest
    static void evaluateNullTest(){
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = 'Leave of Absence End Date';
    
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            contactList[0].hed__Citizenship_Status__c = citizenshipStatus;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
    
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCContactEvaluator evaluator = new ELCContactEvaluator(parser);
            Map<Id, Contact> evaluateMap =  evaluator.evaluate(new Map<Id, Contact>(contactList));

            Test.stopTest();

            System.assertEquals(null, evaluateMap, 'The Evaluator should return a value of null');
        }
    }
}