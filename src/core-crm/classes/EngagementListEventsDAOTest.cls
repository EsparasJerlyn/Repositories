/**
 * @description Test Class for EngagementListEventsDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public with sharing class EngagementListEventsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_ESB', 'QUT_Student_Success_Outreach_Manager'});
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(EngagementListEventsDAO.newInstance() != null, 'EngagementListEventsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new EngagementListEventsDAO().getSObjectType() == Engagement_List_Event__c.SObjectType,
                'SObject is not Engagement_List_Event__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getEngagementListEventsByRelatedRecordIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

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
            leaveOfAbsenceListCreated[0].Start_Date__c = Date.today().addDays(-1); 
            leaveOfAbsenceListCreated[0].End_Date__c = Date.today().addDays(1); 
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 001;
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criterias = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = config.Id;
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criterias.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criterias, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
            Engagement_List_Event__c event = new Engagement_List_Event__c();
            event.Engagement_List_Criteria__c = criterias[0].Id;
            event.Leave_of_Absence__c = leaveOfAbsenceListCreated[0].Id;
            events.add(event);
            EngagementListEventsDAO.newInstance().insertRecords(events, true, AccessLevel.SYSTEM_MODE);

            Map<String, Set<Id>> relatedRecordIdMap = new Map<String, Set<Id>>{
                'engagementListCriteriaId' => new Set<Id>{criterias[0].Id},
                'programEnrollmentIds' => new Set<Id>(),
                'completedCadenceIds' => new Set<Id>(),
                'courseConnectionIds' => new Set<Id>(),
                'courseConnectionAssessmentIds' => new Set<Id>(),
                'programEnrollmentBreachIds' => new Set<Id>(),
                'leaveOfAbsenceIds' => new Set<Id>{leaveOfAbsenceListCreated[0].Id}
            };

            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance()
                .getEngagementListEventsByRelatedRecordIds(
                    relatedRecordIdMap, 
                    AccessLevel.SYSTEM_MODE
                );
                
            System.assertEquals(1, eventList.size(), 'eventList should not be empty.');

        }

        Test.stopTest();
    }

    @isTest
    static void getEngagmentListEventByCaseIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            
            List<Case> caseList = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test', 1);
            caseList[0].Case_Type__c = 'Domestic Future Student Enquiry';
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criterias = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = config.Id;
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criterias.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criterias, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
            Engagement_List_Event__c event = new Engagement_List_Event__c();
            event.Case__c = caseList[0].Id;
            event.Engagement_List_Criteria__c = criterias[0].Id;
            events.add(event);
            EngagementListEventsDAO.newInstance().insertRecords(events, true, AccessLevel.SYSTEM_MODE);
            
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance()
                .getEngagmentListEventByCaseId(
                    new Set<Id>{caseList[0].Id}, 
                    AccessLevel.SYSTEM_MODE
                );
                
            System.assert(eventList.size() > 0, 'eventList should not be empty.');
            System.assertEquals(caseList[0].Id, eventList[0].Case__c, 'eventList Case Ids does not match.');

        }

        Test.stopTest();
    }
    
}