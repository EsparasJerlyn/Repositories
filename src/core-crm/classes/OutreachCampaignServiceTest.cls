/**
 * @description Test class for OutreachCampaignService
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 22, 2024          | DEPP-8744              | Created file                 |
 */
@isTest
private class OutreachCampaignServiceTest {
    @TestSetup
    static void setupMethod() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void updatePreviewStatusTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c(
            Preview_Status__c = EngagementListCriteriasDAO.NOT_GENERATED_PREVIEW_STATUS,
            Preview_Result_Attachment_Id__c = '1234'
        );

        EngagementListCriteriasDAO.newInstance()
            .insertRecords(
                new List<Engagement_List_Criteria__c>{ elc },
                true,
                AccessLevel.USER_MODE
            );
        OutreachCampaignService.updatePreviewStatus(
            elc,
            EngagementListCriteriasDAO.IN_PROGRESS_PREVIEW_STATUS
        );

        System.assertEquals(
            elc.Preview_Status__c,
            EngagementListCriteriasDAO.IN_PROGRESS_PREVIEW_STATUS,
            'Preview Status should be In Progress'
        );
        System.assertEquals(
            elc.Preview_Result_Attachment_Id__c,
            null,
            'Preview_Result_Attachment_Id__c should be null '
        );

        elc.Preview_Job_Id__c = '1234';
        OutreachCampaignService.updatePreviewStatus(
            elc,
            EngagementListCriteriasDAO.NOT_GENERATED_PREVIEW_STATUS
        );

        System.assertEquals(
            elc.Preview_Status__c,
            EngagementListCriteriasDAO.NOT_GENERATED_PREVIEW_STATUS,
            'Preview Status should be Not Generated'
        );
        System.assertEquals(elc.Preview_Job_Id__c, null, 'Preview_Job_Id__c should be null ');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void deleteFinalAttachmentTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new AttachmentsDAOMock());

        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();
        EngagementListCriteriasDAO.newInstance()
            .insertRecords(
                new List<Engagement_List_Criteria__c>{ elc },
                true,
                AccessLevel.USER_MODE
            );

        Attachment csvAttachment = new Attachment();
        csvAttachment.ParentId = elc.Id;
        csvAttachment.Name = 'test.csv';
        csvAttachment.Body = Blob.valueOf('test');
        csvAttachment.ContentType = 'text/csv';

        AttachmentsDAO.newInstance()
            .insertRecords(new List<Attachment>{ csvAttachment }, true, AccessLevel.USER_MODE);
        elc.Preview_Result_Attachment_Id__c = csvAttachment.Id;

        System.assert(
            !AttachmentsDAO.newInstance()
                .findAttachmentsByNames(new Set<String>{'test.csv'}, AccessLevel.USER_MODE)
                .isEmpty(),
            'there should be an attachment'
        );

        OutreachCampaignService.deleteFinalAttachment(elc);

        System.assert(
            AttachmentsDAO.newInstance()
                .findAttachmentsByNames(new Set<String>{'test.csv'}, AccessLevel.USER_MODE)
                .isEmpty(),
            'attachment should be deleted'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void deleteTempAttachmentsTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new AttachmentsDAOMock());

        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();

        EngagementListCriteriasDAO.newInstance()
            .insertRecords(
                new List<Engagement_List_Criteria__c>{ elc },
                true,
                AccessLevel.USER_MODE
            );

        TestDataFactory.SObjectJSONStringParam param = new TestDataFactory.SObjectJSONStringParam();
        param.objectApiName = 'Engagement_List_Criteria__c';
        param.recordId = elc.Id;
        param.name = 'Test';
        param.createdDate = System.Today();
        param.lastModifiedDate = System.Today();

        elc = (Engagement_List_Criteria__c) JSON.deserialize(
            TestDataFactory.getSObjectJSONString(param),
            Engagement_List_Criteria__c.class
        );

        elc.Engagement_List_Criteria_Title__c = 'Test';

        Attachment csvAttachment = new Attachment();
        csvAttachment.ParentId = elc.Id;
        csvAttachment.Name = elc.Name + '_Temp_Preview_Result.csv';
        csvAttachment.Body = Blob.valueOf('test');
        csvAttachment.ContentType = 'text/csv';

        AttachmentsDAO.newInstance()
            .insertRecords(new List<Attachment>{ csvAttachment }, true, AccessLevel.USER_MODE);
        elc.Preview_Result_Attachment_Id__c = csvAttachment.Id;

        System.assert(
            !AttachmentsDAO.newInstance()
                .findAttachmentsByNames(new Set<String>{elc.Name + '_Temp_Preview_Result.csv'}, AccessLevel.USER_MODE)
                .isEmpty(),
            'there should be an attachment'
        );

        OutreachCampaignService.deleteTempAttachments(elc);

        System.assert(
            AttachmentsDAO.newInstance()
                .findAttachmentsByNames(new Set<String>{elc.Name + '_Temp_Preview_Result.csv'}, AccessLevel.USER_MODE)
                .isEmpty(),
            'attachment should be deleted'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void executePreviewBatchTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();

        EngagementListCriteriasDAO.newInstance()
            .insertRecords(
                new List<Engagement_List_Criteria__c>{ elc },
                true,
                AccessLevel.USER_MODE
            );

        Test.startTest();
        OutreachCampaignService.executePreviewBatch(
            EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE),
            System.today()
        );
        Test.stopTest();

        System.assert(
            EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE)
                .Preview_Job_Id__c != null,
            'Preview Job Id should not be null'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void abortJobTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();

        EngagementListCriteriasDAO.newInstance()
            .insertRecords(
                new List<Engagement_List_Criteria__c>{ elc },
                true,
                AccessLevel.USER_MODE
            );

        Test.startTest();
        OutreachCampaignService.executePreviewBatch(
            EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE),
            System.today()
        );
        Test.stopTest();

        Engagement_List_Criteria__c updatedELC = EngagementListCriteriasDAO.newInstance()
            .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE);

        OutreachCampaignService.abortJob(updatedELC);

        System.assertEquals(
            'Aborted',
            AsyncApexJobsDAO.newInstance()
                .findAsyncApexJobById(updatedELC.Preview_Job_Id__c, AccessLevel.USER_MODE)
                .Status,
            'Status should be aborted'
        );
    }

    @isTest
    static void testBatchExecutionContactWithCompletedCadenceTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

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
            EngagementListCriteriasDAO.newInstance()
                .insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                    Date.today(),
                    AccessLevel.SYSTEM_MODE
                );

            //Create contact
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            //Create Completed Cadence records
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(
                1
            );
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for (Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList) {
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted and Admitted',
                        Lead_Score_Threshold__c = 3
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance()
                .insertRecords(nurtureList, true, AccessLevel.SYSTEM_MODE);
            List<Completed_Cadence__c> completedCadenceList = TestDataFactory.createCompletedCadence(
                'Successful',
                nurtureList[0].Id,
                new Set<Id>{ contactList[0].Id }
            );
            CompletedCadencesDAO.newInstance()
                .insertRecords(completedCadenceList, true, AccessLevel.SYSTEM_MODE);
            String queryString = OutreachCampaignService.getQueryLocatorBySubQueryString(
                new ELCParser(criterias[0], Date.today())
            );
            System.assert(
                queryString.startsWith('SELECT Contact__c FROM Completed_Cadence__c'),
                'string must start with SELECT Contact__c FROM Completed_Cadence__c'
            );
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
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

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
            EngagementListCriteriasDAO.newInstance()
                .insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                    Date.today(),
                    AccessLevel.SYSTEM_MODE
                );

            //Create contact
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance()
                .insertRecords(programPlanList, true, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today().addDays(-1);
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance()
                .insertRecords(programEnrollmentList, true, AccessLevel.SYSTEM_MODE);

            String queryString = OutreachCampaignService.getQueryLocatorBySubQueryString(
                new ELCParser(criterias[0], Date.today())
            );
            System.assert(
                queryString.startsWith('SELECT hed__Contact__c FROM hed__Program_Enrollment__c'),
                'String must start with SELECT hed__Contact__c FROM hed__Program_Enrollment__c'
            );
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
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

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
            EngagementListCriteriasDAO.newInstance()
                .insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                    Date.today(),
                    AccessLevel.SYSTEM_MODE
                );

            //Create contact
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance()
                .insertRecords(programPlanList, true, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today();
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance()
                .insertRecords(programEnrollmentList, true, AccessLevel.SYSTEM_MODE);

            //Create Leave of Absence records
            List<Leave_of_Absence__c> leaveOfAbsenceList = TestDataFactory.createLeaveOfAbsenceRecord(
                1
            );
            leaveOfAbsenceList[0].Start_Date__c = Date.today();
            leaveOfAbsenceList[0].End_Date__c = Date.today();
            leaveOfAbsenceList[0].hed_Program_Enrollment__c = programEnrollmentList[0].Id;
            leaveOfAbsenceList[0].Leave_No__c = 1;
            leaveOfAbsenceList[0].Student__c = contactList[0].Id;

            LeaveOfAbsencesDAO.newInstance()
                .insertRecords(leaveOfAbsenceList, true, AccessLevel.SYSTEM_MODE);

            String queryString = OutreachCampaignService.getQueryLocatorBySubQueryString(
                new ELCParser(criterias[0], Date.today())
            );
            System.assert(
                queryString.startsWith('SELECT Student__c FROM Leave_Of_Absence__c'),
                'String must start with SELECT hed__Contact__c FROM hed__Program_Enrollment__c'
            );
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
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            //Create Leave of Absence records
            List<Breach__c> breachList = TestDataFactory.createTestBreachRecords(1);
            breachList[0].Name = 'Breach Test 01';
            BreachesDAO.newInstance().insertRecords(breachList, true, AccessLevel.USER_MODE);

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
            EngagementListCriteriasDAO.newInstance()
                .insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                    Date.today(),
                    AccessLevel.SYSTEM_MODE
                );

            //Create contact
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance()
                .insertRecords(programPlanList, true, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today();
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance()
                .insertRecords(programEnrollmentList, true, AccessLevel.SYSTEM_MODE);

            List<Program_Enrollment_Breach__c> programEnrollmentBreachList = TestDataFactory.createTestProgramEnrollmentBreachRecords(
                1
            );
            programEnrollmentBreachList[0].Contact__c = contactList[0].Id;
            programEnrollmentBreachList[0].Breach_Name__c = breachList[0].Id;
            programEnrollmentBreachList[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            programEnrollmentBreachList[0]
                .Breach_Status__c = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS;
            programEnrollmentBreachList[0].Breach_Date__c = Date.today().addDays(-1);
            ProgramEnrollmentBreachesDAO.newInstance()
                .insertRecords(programEnrollmentBreachList, true, AccessLevel.SYSTEM_MODE);

            String queryString = OutreachCampaignService.getQueryLocatorBySubQueryString(
                new ELCParser(criterias[0], Date.today())
            );
            System.assert(
                queryString.startsWith('SELECT Contact__c FROM Program_Enrollment_Breach__c'),
                'String must start with SELECT Contact__c FROM Program_Enrollment_Breach__c'
            );
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
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

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
            EngagementListCriteriasDAO.newInstance()
                .insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance()
                .findActiveEngagementListCriteriasByRecordtype(
                    EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                    Date.today(),
                    AccessLevel.SYSTEM_MODE
                );

            //Create contact
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            //Create Program Enrollment records
            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c();
            programPlan.Name = 'Test Program Plan';
            programPlan.Category_Type__c = 'Graduate Certificate';
            programPlanList.add(programPlan);
            ProgramPlansDAO.newInstance()
                .insertRecords(programPlanList, true, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c progEn = new hed__Program_Enrollment__c();
            progEn.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            progEn.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            progEn.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            progEn.hed__Contact__c = contactList[0].Id;
            progEn.hed__Program_Plan__c = programPlanList[0].Id;
            progEn.Academic_Status_Date__c = Date.today().addDays(-1);
            programEnrollmentList.add(progEn);
            ProgramEnrollmentsDAO.newInstance()
                .insertRecords(programEnrollmentList, true, AccessLevel.SYSTEM_MODE);

            List<Program_Offering__c> programOfferingList = TestDataFactory.createTestProgramOfferingRecords(
                1,
                programPlanList
            );
            ProgramOfferingsDAO.newInstance()
                .insertRecords(programOfferingList, true, AccessLevel.SYSTEM_MODE);

            //Create a Course Enrollment records
            List<hed__Course_Enrollment__c> courseConnectionList = TestDataFactory.createTestCourseConnectionRecordProgram(
                1,
                contactList[0].Id,
                programOfferingList
            );
            courseConnectionList[0].hed__Program_Enrollment__c = programEnrollmentList[0].Id;
            courseConnectionList[0]
                .Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionList[0].hed__Display_Grade__c = '100';
            CourseConnectionsDAO.newInstance()
                .insertRecords(courseConnectionList, true, AccessLevel.SYSTEM_MODE);

            String queryString = OutreachCampaignService.getQueryLocatorBySubQueryString(
                new ELCParser(criterias[0], Date.today())
            );
            System.assert(
                queryString.startsWith('SELECT hed__Contact__c FROM hed__Course_Enrollment__c'),
                'String must start with SELECT hed__Contact__c FROM hed__Course_Enrollment__c'
            );
        }
    }
}
