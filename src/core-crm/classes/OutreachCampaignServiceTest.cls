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
                .findAttachmentsByName('test.csv', AccessLevel.USER_MODE)
                .isEmpty(),
            'there should be an attachment'
        );

        OutreachCampaignService.deleteFinalAttachment(elc);

        System.assert(
            AttachmentsDAO.newInstance()
                .findAttachmentsByName('test.csv', AccessLevel.USER_MODE)
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

        String elcString =
            '{"attributes":{"type":"Engagement_List_Criteria__c","url":"/services/data/v56.0/sobjects/Engagement_List_Criteria__c/' +
            elc.Id +
            '"},' +
            '"Id":"' +
            elc.Id +
            '","Name":"test"}';

        elc = (Engagement_List_Criteria__c) JSON.deserialize(
            elcString,
            Engagement_List_Criteria__c.class
        );

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
                .findAttachmentsByName(elc.Name + '_Temp_Preview_Result.csv', AccessLevel.USER_MODE)
                .isEmpty(),
            'there should be an attachment'
        );

        OutreachCampaignService.deleteTempAttachments(elc);

        System.assert(
            AttachmentsDAO.newInstance()
                .findAttachmentsByName(elc.Name + '_Temp_Preview_Result.csv', AccessLevel.USER_MODE)
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
                .getSingleEntryCriteriaById(elc.Id, AccessLevel.USER_MODE),
            System.today()
        );
        Test.stopTest();

        System.assert(
            EngagementListCriteriasDAO.newInstance()
                .getSingleEntryCriteriaById(elc.Id, AccessLevel.USER_MODE)
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
                .getSingleEntryCriteriaById(elc.Id, AccessLevel.USER_MODE),
            System.today()
        );
        Test.stopTest();

        Engagement_List_Criteria__c updatedELC = EngagementListCriteriasDAO.newInstance()
            .getSingleEntryCriteriaById(elc.Id, AccessLevel.USER_MODE);

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
            criteria.Key_Date_Offset_Lower_Boundary__c = 1;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEntryCriteria(EngagementListCriteriasDAO.RECORD_TYPE_DEVELOPER_NAME_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);

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
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(outreachCases[0].Id, AccessLevel.SYSTEM_MODE);

            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
            System.assertEquals(outreachCases[0].Id, eventList[0].Case__c, 'No events created under outreach case record.');
            System.assertEquals(completedCadenceList[0].Id, eventList[0].Completed_Cadence__c, 'No events created for Completed Cadence under outreach case record.');
    }

}