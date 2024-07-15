/**
 * @description Test class for ELECandidateGeneratorTest
 * @ELECandidateGenerator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 07, 2024          | DEPP-8483              | Created file                 |
 */
@isTest
public with sharing class ELECandidateGeneratorTest {
    private static Id engagementListCriteriaId;

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
        MockIdGenerator mockIdGen = new MockIdGenerator(Engagement_List_Criteria__c.SObjectType);
        engagementListCriteriaId = mockIdGen.getMockId();
    }
    
    @isTest
    static void generateEngagementListWithContactValuesOnlyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {        
            // Contact contact = new Contact();
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
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
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            
            Test.stopTest();
            
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 3, 'engagementListEvents is not equal');   
        }
    }
    
    @isTest
    static void generateEngagementListWithContactAndCompletedCadenceValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String completedCadenceName = 'Domestic Accepted and Admitted';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<Nurture_Track_Configuration__c> nurtureListCon = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureTrackConfig = new Nurture_Track_Configuration__c();
            nurtureTrackConfig.Cadence_Name__c = completedCadenceName;
            nurtureListCon.add(nurtureTrackConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListCon, false, AccessLevel.SYSTEM_MODE);
                        
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            
            for(Contact con: contactList){                
                completedCadenceList.add(TestDataFactory.createCompletedCadence(CompletedCadencesDAO.SUCCESSFUL_STATUS,nurtureListCon[0].Id,new Set<Id>{con.Id})[0]);
            }
            
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
			            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = null;
            engagementListCriteria.Category_Type__c = null;
            engagementListCriteria.Completed_Cadence__c = completedCadenceName;
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = 'Completed Cadence Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            Test.stopTest();
            
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 3, 'engagementListEvents generated is not match');
            
            for(Engagement_List_Event__c rec: engagementListEvents){
                System.assertEquals(String.isNotBlank(rec.Completed_Cadence__c) , true, 'Completed cadence  is not populated');
                System.assertEquals(rec.Key_Date__c !=null, true, 'Engagement List Event key date is empty');
            }       
        }
    }
    
    @isTest
    static void generateEngagementListWithContactProgramEnrollmentValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String academicStatus = 'Showcause';
            String categoryType = 'Graduate Certificate';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Previous_Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            programEnrollmentListCreated[0].Academic_Status_Date__c = Date.today();
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Previous_Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = categoryType;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = 'Academic Status Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            Test.stopTest();
            
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 1, 'engagementListEvents generated is not match');
            
            for(Engagement_List_Event__c rec: engagementListEvents){
                System.assertEquals(String.isNotBlank(rec.program_enrollment__c) , true, 'Program Enrollment  is not populated');
                System.assertEquals(rec.Academic_Status__c, academicStatus, 'Academic status is not match');
                System.assertEquals(rec.Previous_Academic_Status__c, academicStatus, 'Previous academic status is not match');
                System.assertEquals(rec.Program_Enrollment_Status__c, ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED, 'Program Enrollment  is not enrollment status is not match');
                System.assertEquals(rec.Key_Date__c !=null, true, 'Program Enrollment key date is empty');
            }       
        }
    }
    
    @isTest
    static void generateEngagementListWithCourseEnrollmentValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String academicStatus = 'Showcause';
            String categoryType = 'Graduate Certificate';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
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
            
            Test.startTest();
            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = categoryType;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = null;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = null;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = null;
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            Test.stopTest();
            
            System.assertEquals(!contacts.isEmpty(), true, 'Contact is empty');
            System.assertEquals(!evaluatorMap.isEmpty(), true, 'evaluatorMap is empty');
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 1, 'engagementListEvents is not match');
            
            for(Engagement_List_Event__c rec: engagementListEvents){
                System.assertEquals(String.isNotBlank(rec.program_enrollment__c) , true, 'Program Enrollment  is not populated');
                System.assertEquals(rec.Academic_Status__c, academicStatus, 'Academic status is not match');
                System.assertEquals(rec.Program_Enrollment_Status__c, ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED, 'Program Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection__c) , true, 'Course Enrollment  is not populated');
                System.assertEquals(rec.Course_Enrollment_Status__c, CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED, 'Course Enrollment status is not match');
                System.assertEquals(rec.Key_Date__c == null, true, 'Engagement List Event key date is not empty');
            }       
        }
    }
    
    @isTest
    static void generateEngagementListWithCourseAssessmentValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String academicStatus = 'Showcause';
            String categoryType = 'Graduate Certificate';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
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
            
            List<Assessment__c> assessmentRecord = TestDataFactory.createTestAssessmentRecords(1);
            assessmentRecord[0].Due_Date__c = Date.Today().addDays(-10);
            AssessmentsDAO.newInstance().insertRecords(assessmentRecord,true,AccessLevel.SYSTEM_MODE);
            
            List<Course_Connection_Assessment__c> courseConnectionAssessmentListCreated = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionListCreated[0].Id);
            courseConnectionAssessmentListCreated[0].Assessment_Name__c = assessmentRecord[0].Id;
            courseConnectionAssessmentListCreated[0].Contact__c = contactList[0].Id;
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentListCreated,true,AccessLevel.SYSTEM_MODE);
            Test.startTest();
            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = categoryType;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = 'Assessment Due Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            Test.stopTest();
            
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 1, 'engagementListEvents generated is not match');
            
            for(Engagement_List_Event__c rec: engagementListEvents){
                System.assertEquals(String.isNotBlank(rec.program_enrollment__c) , true, 'Program Enrollment  is not populated');
                System.assertEquals(rec.Academic_Status__c, academicStatus, 'Academic status is not match');
                System.assertEquals(rec.Program_Enrollment_Status__c, ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED, 'Program Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection__c) , true, 'Course Enrollment  is not populated');
                System.assertEquals(rec.Course_Enrollment_Status__c, CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED, 'Course Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection_Assessment__c) , true, 'Course Connection Assessment  is not populated');
                System.assertEquals(rec.Key_Date__c !=null, true, 'Engagement List Event key date is empty');
            }       
        }
    }
    
    @isTest
    static void generateEngagementListWithLeaveOfAbsenceValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String academicStatus = 'Showcause';
            String categoryType = 'Graduate Certificate';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
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
            
            List<Assessment__c> assessmentRecord = TestDataFactory.createTestAssessmentRecords(1);
            AssessmentsDAO.newInstance().insertRecords(assessmentRecord,true,AccessLevel.SYSTEM_MODE);
            
            List<Course_Connection_Assessment__c> courseConnectionAssessmentListCreated = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionListCreated[0].Id);
            courseConnectionAssessmentListCreated[0].Assessment_Name__c = assessmentRecord[0].Id;
            courseConnectionAssessmentListCreated[0].Contact__c = contactList[0].Id;
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentListCreated,true,AccessLevel.SYSTEM_MODE);
            
            List<Leave_of_Absence__c> leaveOfAbsenceListCreated = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceListCreated[0].Start_Date__c = System.today().addDays(-1);
            leaveOfAbsenceListCreated[0].End_Date__c = System.today().addDays(1);
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 1;
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = categoryType;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = 'Leave of Absence End Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            Test.stopTest();
            
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 1, 'engagementListEvents generated is not match');
            
            for(Engagement_List_Event__c rec: engagementListEvents){
                System.assertEquals(String.isNotBlank(rec.program_enrollment__c) , true, 'Program Enrollment  is not populated');
                System.assertEquals(rec.Academic_Status__c, academicStatus, 'Academic status is not match');
                System.assertEquals(rec.Program_Enrollment_Status__c, ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED, 'Program Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection__c) , true, 'Course Enrollment  is not populated');
                System.assertEquals(rec.Course_Enrollment_Status__c, CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED, 'Course Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection_Assessment__c) , true, 'Course Connection Assessment  is not populated');
                System.assertEquals(String.isNotBlank(rec.Leave_of_Absence__c) , true, 'Leave of Absence  is not populated');
                System.assertEquals(rec.Key_Date__c !=null, true, 'Engagement List Event key date is empty');
            }       
        }
    }
    
    @isTest
    static void generateEngagementListWithProgramEnrollmentBreachTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String academicStatus = 'Showcause';
            String categoryType = 'Graduate Certificate';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
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
            
            List<Assessment__c> assessmentRecord = TestDataFactory.createTestAssessmentRecords(1);
            AssessmentsDAO.newInstance().insertRecords(assessmentRecord,true,AccessLevel.SYSTEM_MODE);
            
            List<Course_Connection_Assessment__c> courseConnectionAssessmentListCreated = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionListCreated[0].Id);
            courseConnectionAssessmentListCreated[0].Assessment_Name__c = assessmentRecord[0].Id;
            courseConnectionAssessmentListCreated[0].Contact__c = contactList[0].Id;
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentListCreated,true,AccessLevel.SYSTEM_MODE);
            
            List<Leave_of_Absence__c> leaveOfAbsenceListCreated = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceListCreated[0].Start_Date__c = System.today().addDays(-1);
            leaveOfAbsenceListCreated[0].End_Date__c = System.today().addDays(1);
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 1;
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);
            
            List<Breach__c> breachList = TestDataFactory.createTestBreachRecords(1);
            breachList[0].Name = 'Breach Test 01';
            BreachesDAO.newInstance().insertRecords(breachList,true,AccessLevel.USER_MODE);
            
            List<Program_Enrollment_Breach__c> programEnrollmentBreachListCreated = TestDataFactory.createTestProgramEnrollmentBreachRecords(1);
            programEnrollmentBreachListCreated[0].Contact__c = contactList[0].Id;
            programEnrollmentBreachListCreated[0].Breach_Name__c = breachList[0].Id;
            programEnrollmentBreachListCreated[0].Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            programEnrollmentBreachListCreated[0].Breach_Status__c = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS;
            programEnrollmentBreachListCreated[0].Breach_Date__c = Date.today();
            ProgramEnrollmentBreachesDAO.newInstance().insertRecords(programEnrollmentBreachListCreated,true,AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;
            engagementListCriteria.Category_Type__c = categoryType;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = breachList[0].Id;
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = 'Breach Start Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
            engagementListCriteria.Id = engagementListCriteriaId;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            
            //generator
            List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
            for (ELECandidateIngredient eLECandidateIngredient : evaluatorMap.values()) { 
                ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
                engagementListEvents.addAll(eLECandidateGenerator.generate(eLECandidateIngredient));
            }
            Test.stopTest();
            
            System.assertEquals(!engagementListEvents.isEmpty(), true, 'engagementListEvents is empty');
            System.assertEquals(engagementListEvents.size(), 1, 'engagementListEvents generated is not match');
            
            for(Engagement_List_Event__c rec: engagementListEvents){
                System.assertEquals(String.isNotBlank(rec.program_enrollment__c) , true, 'Program Enrollment  is not populated');
                System.assertEquals(rec.Academic_Status__c, academicStatus, 'Academic status is not match');
                System.assertEquals(rec.Program_Enrollment_Status__c, ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED, 'Program Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection__c) , true, 'Course Enrollment  is not populated');
                System.assertEquals(rec.Course_Enrollment_Status__c, CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED, 'Course Enrollment status is not match');
                System.assertEquals(String.isNotBlank(rec.Course_Connection_Assessment__c) , true, 'Course Connection Assessment  is not populated');
                System.assertEquals(String.isNotBlank(rec.Leave_of_Absence__c) , true, 'Leave of Absence  is not populated');
                System.assertEquals(String.isNotBlank(rec.Program_Enrollment_Breach__c) , true, 'Program Enrollment Breach is not populated');
                System.assertEquals(rec.Key_Date__c !=null, true, 'Engagement List Event key date is empty');
            }       
        }
    }
}