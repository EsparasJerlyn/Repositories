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
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }
    
    @isTest
    static void testBatchExecutionContactWithCompletedCadenceTest() {                 
        //Contact with Completed Cadence
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {  
            
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.Completed_Cadence__c = 'Domestic Accepted and Admitted';
            criteria.Key_Date__c = 'Completed Cadence Date';
            criteria.Key_Date_Offset_Upper_Boundary__c = 1;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);

            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);
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
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, true, AccessLevel.SYSTEM_MODE);    
            List<Completed_Cadence__c> completedCadenceList = TestDataFactory.createCompletedCadence('Successful',nurtureList[0].Id,new Set<Id>{contactList[0].Id});
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);
            Test.startTest();

            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            evalJobList.add(new eLCEvaluationJob(criterias[0], Date.today()));
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    

            Test.stopTest();

            List<Case> outreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(new Set<Id>{outreachCases[0].Id}, AccessLevel.SYSTEM_MODE);

            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
            System.assertEquals(outreachCases[0].Id, eventList[0].Case__c, 'No events created under outreach case record.');
            System.assertEquals(completedCadenceList[0].Id, eventList[0].Completed_Cadence__c, 'No events created for Completed Cadence under outreach case record.');
        }
    }

    @isTest
    static void testBatchExecutionContactWithProgramEnrollmentTest() {                 
        //Contact with Completed Cadence
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {  
            
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.Key_Date__c = 'Academic Status Date';
            criteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            criteria.Category_Type__c = 'Graduate Certificate';
            criteria.Key_Date_Offset_Lower_Boundary__c = 1;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);

            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance().insertRecords(programPlanList,true,AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c>  programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today().addDays(-1);
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList,true,AccessLevel.SYSTEM_MODE);

            Test.startTest();

            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            evalJobList.add(
                new eLCEvaluationJob(
                    criterias[0], 
                    Date.today()
                )
            );
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    

            Test.stopTest();

            List<Case> outreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(new Set<Id>{outreachCases[0].Id}, AccessLevel.SYSTEM_MODE);

            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
            System.assertEquals(outreachCases[0].Id, eventList[0].Case__c, 'No events created under outreach case record.');
            System.assertEquals(programEnrollmentList[0].Id, eventList[0].Program_Enrollment__c, 'No events created for Program Enrollment under outreach case record.');
           
        }
    }

    @isTest
    static void testBatchExecutionContactWithLeaveOfAbsenceTest() {                 
        //Contact with Completed Cadence
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {  
            
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.Key_Date__c = 'Leave Of Absence End Date';
            criteria.Is_On_Leave_of_Absence__c = 'Yes';
            criteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            criteria.Key_Date_Offset_Upper_Boundary__c = 10;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);
            
            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);
            
            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance().insertRecords(programPlanList,true,AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c>  programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today();
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList,true,AccessLevel.SYSTEM_MODE);

            //Create Leave of Absence records
            List<Leave_of_Absence__c> leaveOfAbsenceList = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceList[0].Start_Date__c = Date.today(); 
            leaveOfAbsenceList[0].End_Date__c = Date.today(); 
            leaveOfAbsenceList[0].hed_Program_Enrollment__c = programEnrollmentList[0].Id;
            leaveOfAbsenceList[0].Leave_No__c = 001;
            leaveOfAbsenceList[0].Student__c = contactList[0].Id;

            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceList,true,AccessLevel.SYSTEM_MODE);

            Test.startTest();

            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            evalJobList.add(
                new eLCEvaluationJob(
                    criterias[0], 
                    Date.today()
                )
            );
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    

            Test.stopTest();
            
            List<Case> outreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(new Set<Id>{outreachCases[0].Id}, AccessLevel.SYSTEM_MODE);

            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
            System.assertEquals(outreachCases[0].Id, eventList[0].Case__c, 'No events created under outreach case record.');
            System.assertEquals(leaveOfAbsenceList[0].Id, eventList[0].Leave_of_Absence__c, 'No events created for Leave of Absence under outreach case record.');
           
        }
    }

    @isTest
    static void testBatchExecutionContactWithProgEnrollBreachTest() {                 
        //Contact with Completed Cadence
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {  
            
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            //Create Leave of Absence records
            List<Breach__c> breachList = TestDataFactory.createTestBreachRecords(1);
            breachList[0].Name = 'Breach Test 01';
            BreachesDAO.newInstance().insertRecords(breachList,true,AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.Key_Date__c = 'Breach Start Date';
            criteria.Breach__c = breachList[0].Id;
            criteria.Key_Date_Offset_Lower_Boundary__c = 1;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);

            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance().insertRecords(programPlanList,true,AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c>  programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today();
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList,true,AccessLevel.SYSTEM_MODE);
            
            List<Program_Enrollment_Breach__c> programEnrollmentBreachList = TestDataFactory.createTestProgramEnrollmentBreachRecords(1);
            programEnrollmentBreachList[0].Contact__c = contactList[0].Id;
            programEnrollmentBreachList[0].Breach_Name__c = breachList[0].Id;
            programEnrollmentBreachList[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            programEnrollmentBreachList[0].Breach_Status__c = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS;
            programEnrollmentBreachList[0].Breach_Date__c = Date.today().addDays(-1);
            ProgramEnrollmentBreachesDAO.newInstance().insertRecords(programEnrollmentBreachList,true,AccessLevel.SYSTEM_MODE);
            
            Test.startTest();

            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            evalJobList.add(
                new eLCEvaluationJob(
                    criterias[0], 
                    Date.today()
                )
            );
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    

            Test.stopTest();

            List<Case> outreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(new Set<Id>{outreachCases[0].Id}, AccessLevel.SYSTEM_MODE);

            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
            System.assertEquals(outreachCases[0].Id, eventList[0].Case__c, 'No events created under outreach case record.');
            System.assertEquals(programEnrollmentBreachList[0].Id, eventList[0].Program_Enrollment_Breach__c, 'No events created for Program Enrollment Breach under outreach case record.');
           
        }
    }

    @isTest
    static void testBatchExecutionContactWithCourseConnectionTest() {                 
        //Contact with Completed Cadence
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {  
            
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.Key_Date__c = 'Academic Status Date';
            criteria.Course_Grade__c = '100';
            criteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            criteria.Key_Date_Offset_Lower_Boundary__c = 1;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);

            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance().insertRecords(programPlanList,true,AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c>  programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today().addDays(-1);
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList,true,AccessLevel.SYSTEM_MODE);
            
            List<Program_Offering__c> programOfferingList = TestDataFactory.createTestProgramOfferingRecords(1, programPlanList);
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingList,true,AccessLevel.SYSTEM_MODE);
            
            //Create a Course Enrollment records
            List<hed__Course_Enrollment__c> courseConnectionList = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingList);
            courseConnectionList[0].hed__Program_Enrollment__c = programEnrollmentList[0].Id;
            courseConnectionList[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionList[0].hed__Display_Grade__c = '100';
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionList,true,AccessLevel.SYSTEM_MODE);
            
            Test.startTest();

            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            evalJobList.add(
                new eLCEvaluationJob(
                    criterias[0], 
                    Date.today()
                )
            );
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    

            Test.stopTest();

            List<Case> outreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(new Set<Id>{outreachCases[0].Id}, AccessLevel.SYSTEM_MODE);

            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
            System.assertEquals(outreachCases[0].Id, eventList[0].Case__c, 'No events created under outreach case record.');
            System.assertEquals(courseConnectionList[0].Id, eventList[0].Course_Connection__c, 'No events created for Program Enrollment Breach under outreach case record.');
           
        }
    }
}