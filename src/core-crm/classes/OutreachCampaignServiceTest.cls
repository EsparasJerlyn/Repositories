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
}