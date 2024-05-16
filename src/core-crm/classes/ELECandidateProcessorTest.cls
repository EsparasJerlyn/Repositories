/**
 * @description Test Class for ELECandidateProcessor
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 15, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public with sharing class ELECandidateProcessorTest {

    @isTest
    static void processCreateEventTest() {        
        ImplementationSelector.DAO.setMock(new EngagementListConfigurationsDAO());
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAO());
        ImplementationSelector.DAO.setMock(new ContactsDAO());
        ImplementationSelector.DAO.setMock(new ProgramPlansDAO());
        ImplementationSelector.DAO.setMock(new ProgramEnrollmentsDAO());
        ImplementationSelector.DAO.setMock(new ProgramOfferingsDAO());
        ImplementationSelector.DAO.setMock(new CourseConnectionsDAO());
        ImplementationSelector.DAO.setMock(new EngagementListEventsDAO());

        List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
        Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
        config.Name = 'ELConfig Test';
        configs.add(config);
        EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

        List<Engagement_List_Criteria__c> criterias = new List<Engagement_List_Criteria__c>();
        Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
        criteria.Engagement_List_Configuration__c = config.Id;
        criteria.Citizenship_Status__c = 'Domestic';
        criteria.Academic_Status__c = 'Showcause';
        criterias.add(criteria);
        EngagementListCriteriasDAO.newInstance().insertRecords(criterias, true, AccessLevel.SYSTEM_MODE);

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].QUT_Student__c = true;
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

        String groupName = 'Student Success - Student Retention';
        Id studentRetentionId = GroupsDAO.newInstance().getQueueByName(groupName);
        List<Case> caseList = new List<Case>();
        Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(config, studentRetentionId, contactList[0].Id);
        outreachCase.Status = CasesDAO.CASE_STATUS_OPEN;
        caseList.add(outreachCase);
        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

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
        CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);

        Date keyDate = Date.today();                      
        
        List<Engagement_List_Event__c> existingEvents = new List<Engagement_List_Event__c>();
        Engagement_List_Event__c existingEvent = new Engagement_List_Event__c();
        existingEvent.Engagement_List_Criteria__c = criteria.Id;
        existingEvent.Program_Enrollment__c = programEnrollmentListCreated[0].Id;
        existingEvent.Course_Connection__c = courseConnectionListCreated[0].Id;
        existingEvent.Academic_Status__c = 'Showcause';
        existingEvent.Course_Enrollment_Status__c = 'Test';
        existingEvent.Key_Date__c = keyDate;
        existingEvent.Program_Enrollment_Status__c = 'Test';
        existingEvent.Case__c = caseList[0].Id;
        existingEvents.add(existingEvent);
        EngagementListEventsDAO.newInstance().insertRecords(existingEvents, true, AccessLevel.SYSTEM_MODE);

        Test.startTest();
        Engagement_List_Event__c eventCandidate = new Engagement_List_Event__c();
        eventCandidate.Engagement_List_Criteria__c = criteria.Id;
        eventCandidate.Program_Enrollment__c = programEnrollmentListCreated[0].Id;
        eventCandidate.Course_Connection__c = courseConnectionListCreated[0].Id;
        eventCandidate.Academic_Status__c = 'Showcause';
        eventCandidate.Course_Enrollment_Status__c = 'Enrolled';
        eventCandidate.Key_Date__c = keyDate;
        eventCandidate.Program_Enrollment_Status__c = 'Admitted';

        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        events.add(eventCandidate);
        Map<Id, List<Engagement_List_Event__c>> eventCandidateMap = new Map<Id, List<Engagement_List_Event__c>>();
        eventCandidateMap.put(contactList[0].Id, events);

        ELECandidateProcessor processor = new ELECandidateProcessor();
        List<ELECandidateProcessResult> process = processor.process(eventCandidateMap, criteria);
        Test.stopTest();

        System.assertEquals(ELECandidateProcessResult.Outcome.EVENT_CREATED, process[0].getResult(), 'Event should not be created.');  
    }

    @isTest
    static void processNoCreationTest() {        
        ImplementationSelector.DAO.setMock(new EngagementListConfigurationsDAO());
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAO());
        ImplementationSelector.DAO.setMock(new ContactsDAO());
        ImplementationSelector.DAO.setMock(new ProgramPlansDAO());
        ImplementationSelector.DAO.setMock(new ProgramEnrollmentsDAO());
        ImplementationSelector.DAO.setMock(new ProgramOfferingsDAO());
        ImplementationSelector.DAO.setMock(new CourseConnectionsDAO());
        ImplementationSelector.DAO.setMock(new EngagementListEventsDAO());

        List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
        Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
        config.Name = 'ELConfig Test';
        configs.add(config);
        EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

        List<Engagement_List_Criteria__c> criterias = new List<Engagement_List_Criteria__c>();
        Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
        criteria.Engagement_List_Configuration__c = config.Id;
        criteria.Citizenship_Status__c = 'Domestic';
        criteria.Academic_Status__c = 'Showcause';
        criterias.add(criteria);
        EngagementListCriteriasDAO.newInstance().insertRecords(criterias, true, AccessLevel.SYSTEM_MODE);

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].QUT_Student__c = true;
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

        String groupName = 'Student Success - Student Retention';
        Id studentRetentionId = GroupsDAO.newInstance().getQueueByName(groupName);
        List<Case> caseList = new List<Case>();
        Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(config, studentRetentionId, contactList[0].Id);
        outreachCase.Status = CasesDAO.CASE_STATUS_OPEN;
        caseList.add(outreachCase);
        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

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
        CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);

        Date keyDate = Date.today();                      
        
        List<Engagement_List_Event__c> existingEvents = new List<Engagement_List_Event__c>();
        Engagement_List_Event__c existingEvent = new Engagement_List_Event__c();
        existingEvent.Engagement_List_Criteria__c = criteria.Id;
        existingEvent.Program_Enrollment__c = programEnrollmentListCreated[0].Id;
        existingEvent.Course_Connection__c = courseConnectionListCreated[0].Id;
        existingEvent.Academic_Status__c = 'Showcause';
        existingEvent.Course_Enrollment_Status__c = 'Enrolled';
        existingEvent.Key_Date__c = keyDate;
        existingEvent.Program_Enrollment_Status__c = 'Admitted';
        existingEvent.Case__c = caseList[0].Id;
        existingEvents.add(existingEvent);
        EngagementListEventsDAO.newInstance().insertRecords(existingEvents, true, AccessLevel.SYSTEM_MODE);

        Test.startTest();
        Engagement_List_Event__c eventCandidate = new Engagement_List_Event__c();
        eventCandidate.Engagement_List_Criteria__c = criteria.Id;
        eventCandidate.Program_Enrollment__c = programEnrollmentListCreated[0].Id;
        eventCandidate.Course_Connection__c = courseConnectionListCreated[0].Id;
        eventCandidate.Academic_Status__c = 'Showcause';
        eventCandidate.Course_Enrollment_Status__c = 'Enrolled';
        eventCandidate.Key_Date__c = keyDate;
        eventCandidate.Program_Enrollment_Status__c = 'Admitted';

        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        events.add(eventCandidate);
        Map<Id, List<Engagement_List_Event__c>> eventCandidateMap = new Map<Id, List<Engagement_List_Event__c>>();
        eventCandidateMap.put(contactList[0].Id, events);

        ELECandidateProcessor processor = new ELECandidateProcessor();
        List<ELECandidateProcessResult> process = processor.process(eventCandidateMap, criteria);
        Test.stopTest();
        System.assertEquals(ELECandidateProcessResult.Outcome.EVENT_NOT_CREATED, process[0].getResult(), 'Event should not be created.');  
    }

    @isTest
    static void processCaseCreationTest() {        
        ImplementationSelector.DAO.setMock(new EngagementListConfigurationsDAO());
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAO());
        ImplementationSelector.DAO.setMock(new ContactsDAO());
        ImplementationSelector.DAO.setMock(new ProgramPlansDAO());
        ImplementationSelector.DAO.setMock(new ProgramEnrollmentsDAO());
        ImplementationSelector.DAO.setMock(new ProgramOfferingsDAO());
        ImplementationSelector.DAO.setMock(new CourseConnectionsDAO());
        ImplementationSelector.DAO.setMock(new EngagementListEventsDAO());
        
        List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
        Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
        config.Name = 'ELConfig Test';
        configs.add(config);
        EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

        List<Engagement_List_Criteria__c> criterias = new List<Engagement_List_Criteria__c>();
        Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
        criteria.Engagement_List_Configuration__c = config.Id;
        criteria.Citizenship_Status__c = 'Domestic';
        criteria.Academic_Status__c = 'Showcause';
        criterias.add(criteria);
        EngagementListCriteriasDAO.newInstance().insertRecords(criterias, true, AccessLevel.SYSTEM_MODE);

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].QUT_Student__c = true;
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

        String groupName = 'Student Success - Student Retention';
        Id studentRetentionId = GroupsDAO.newInstance().getQueueByName(groupName);
        List<Case> caseList = new List<Case>();
        Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(config, studentRetentionId, contactList[0].Id);
        caseList.add(outreachCase);
        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

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
        CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);

        Date keyDate = Date.today();                      
        
        List<Engagement_List_Event__c> existingEvents = new List<Engagement_List_Event__c>();
        Engagement_List_Event__c existingEvent = new Engagement_List_Event__c();
        existingEvent.Engagement_List_Criteria__c = criteria.Id;
        existingEvent.Program_Enrollment__c = programEnrollmentListCreated[0].Id;
        existingEvent.Course_Connection__c = courseConnectionListCreated[0].Id;
        existingEvent.Academic_Status__c = 'Showcause';
        existingEvent.Course_Enrollment_Status__c = 'Test';
        existingEvent.Key_Date__c = keyDate;
        existingEvent.Program_Enrollment_Status__c = 'Test';
        existingEvent.Case__c = caseList[0].Id;
        existingEvents.add(existingEvent);
        EngagementListEventsDAO.newInstance().insertRecords(existingEvents, true, AccessLevel.SYSTEM_MODE);

        Test.startTest();
        Engagement_List_Event__c eventCandidate = new Engagement_List_Event__c();
        eventCandidate.Engagement_List_Criteria__c = criteria.Id;
        eventCandidate.Program_Enrollment__c = programEnrollmentListCreated[0].Id;
        eventCandidate.Course_Connection__c = courseConnectionListCreated[0].Id;
        eventCandidate.Academic_Status__c = 'Showcause';
        eventCandidate.Course_Enrollment_Status__c = 'Enrolled';
        eventCandidate.Key_Date__c = keyDate;
        eventCandidate.Program_Enrollment_Status__c = 'Admitted';

        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        events.add(eventCandidate);
        Map<Id, List<Engagement_List_Event__c>> eventCandidateMap = new Map<Id, List<Engagement_List_Event__c>>();
        eventCandidateMap.put(contactList[0].Id, events);

        ELECandidateProcessor processor = new ELECandidateProcessor();
        List<ELECandidateProcessResult> process = processor.process(eventCandidateMap, criteria);
        Test.stopTest();

        System.assertEquals(ELECandidateProcessResult.Outcome.CASE_CREATED, process[0].getResult(), 'Event should not be created.');   
    }

}