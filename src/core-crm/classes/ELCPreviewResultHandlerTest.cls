/**
 * @description Test class for ELCPreviewResultHandler
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 22, 2024          | DEPP-8744              | Created file                 |
 */
@isTest
private class ELCPreviewResultHandlerTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void handleExecuteTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new AttachmentsDAOMock());

        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();

        Contact con = new Contact(
            QUT_Student_ID__c = '1234',
            Email = 'test@email.com',
            MobilePhone = '123456'
        );

        ContactsDAO.newInstance()
            .insertRecords(new List<Contact>{ con }, true, AccessLevel.USER_MODE);

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

        ELECandidateIngredient ingredient = new ELECandidateIngredient();
        ingredient.setContact(con);

        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(elc, System.Today());
        resultHandler.handle(new List<ELECandidateIngredient>{ ingredient });

        System.assert(
            !AttachmentsDAO.newInstance()
                .findAttachmentsByNames(new Set<String>{'Test_Temp_Preview_Result.csv'}, AccessLevel.USER_MODE)
                .isEmpty(),
            'An attachment should be created '
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void handleEmptyTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
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

        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(elc, System.Today());
        List<ELECandidateIngredient> ingredientList = new List<ELECandidateIngredient>();
        resultHandler.handle(ingredientList);

        System.assert(ingredientList.isEmpty(), 'ingredientList is empty');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void handleSuccessTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new AttachmentsDAOMock());
        ImplementationSelector.DAO.setMock(new AsyncApexJobsDAOMock());
        ImplementationSelector.DAO.setMock(new EmailTemplatesDAOMock());

        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Name = 'Preview Generated Success Email';
        emailTemplate.Subject = 'Test Subject';
        emailTemplate.HtmlValue = '<html></html>';
        emailTemplate.TemplateType = 'custom';
        emailTemplate.UiType = 'SFX';
        emailTemplates.add(emailTemplate);
        EmailTemplatesDAO.newInstance()
            .insertRecords(emailTemplates, true, AccessLevel.SYSTEM_MODE);

        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();

        Contact con = new Contact(
            QUT_Student_ID__c = '1234',
            Email = 'test@email.com',
            MobilePhone = '123456'
        );

        ContactsDAO.newInstance()
            .insertRecords(new List<Contact>{ con }, true, AccessLevel.USER_MODE);

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

        ELECandidateIngredient ingredient = new ELECandidateIngredient();
        ingredient.setContact(con);

        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(elc, System.Today());
        resultHandler.handle(new List<ELECandidateIngredient>{ ingredient });

        AsyncApexJob job = new AsyncApexJob();

        AsyncApexJobsDAO.newInstance()
            .insertRecords(new List<AsyncApexJob>{ job }, true, AccessLevel.USER_MODE);

        //Stringify and serialize to add a non-writable ExtendedStatus and NumberOfErrors
        String jobString =
            '{"attributes":{"type":"AsyncApexJob","url":"/services/data/v56.0/sobjects/AsyncApexJob/' +
            job.Id +
            '"},' +
            '"Id":"' +
            job.Id +
            '","NumberOfErrors":"0","ExtendedStatus":""}';

        job = (AsyncApexJob) JSON.deserialize(jobString, AsyncApexJob.class);

        AsyncApexJobsDAO.newInstance()
            .updateRecords(new List<AsyncApexJob>{ job }, true, AccessLevel.USER_MODE);

        resultHandler.handle(job.Id, new Set<String>());

        system.assertEquals(
            'Completed',
            EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE)
                .Preview_Status__c,
            'Status should be completed'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void handleFailTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new AttachmentsDAOMock());
        ImplementationSelector.DAO.setMock(new AsyncApexJobsDAOMock());
        ImplementationSelector.DAO.setMock(new EmailTemplatesDAOMock());

        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Name = 'Preview Generated Error Email';
        emailTemplate.Subject = 'Test Subject';
        emailTemplate.HtmlValue = '<html></html>';
        emailTemplate.TemplateType = 'custom';
        emailTemplate.UiType = 'SFX';
        emailTemplates.add(emailTemplate);
        EmailTemplatesDAO.newInstance()
            .insertRecords(emailTemplates, true, AccessLevel.SYSTEM_MODE);

        Contact con = new Contact(
            QUT_Student_ID__c = '1234',
            Email = 'test@email.com',
            MobilePhone = '123456'
        );

        ContactsDAO.newInstance()
            .insertRecords(new List<Contact>{ con }, true, AccessLevel.USER_MODE);

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

        ELECandidateIngredient ingredient = new ELECandidateIngredient();
        ingredient.setContact(con);

        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(elc, System.Today());
        resultHandler.handle(new List<ELECandidateIngredient>{ ingredient });

        AsyncApexJob job = new AsyncApexJob();

        AsyncApexJobsDAO.newInstance()
            .insertRecords(new List<AsyncApexJob>{ job }, true, AccessLevel.USER_MODE);

        //Stringify and serialize to add a non-writable ExtendedStatus and NumberOfErrors
        String jobString =
            '{"attributes":{"type":"AsyncApexJob","url":"/services/data/v56.0/sobjects/AsyncApexJob/' +
            job.Id +
            '"},' +
            '"Id":"' +
            job.Id +
            '","NumberOfErrors":"1","ExtendedStatus":"SOQL LIMIT"}';

        job = (AsyncApexJob) JSON.deserialize(jobString, AsyncApexJob.class);

        AsyncApexJobsDAO.newInstance()
            .updateRecords(new List<AsyncApexJob>{ job }, true, AccessLevel.USER_MODE);

        resultHandler.handle(job.Id, new Set<String>{ 'Test Error' });

        system.assertEquals(
            'Failed',
            EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE)
                .Preview_Status__c,
            'Status should be failed'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    static void logErrorsTest() {
        ImplementationSelector.DAO.setMock(new EngagementListCriteriasDAOMock());
        Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c();
        EngagementListCriteriasDAO.newInstance()
            .insertRecords(
                new List<Engagement_List_Criteria__c>{ elc },
                true,
                AccessLevel.USER_MODE
            );
        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(elc, System.Today());
        try{
            throw new DMLException('Test DML Exception'); 
        }catch(Exception e){
            resultHandler.logErrors(null, e);
        }

        System.assert(Logger.getBufferSize() > 0,'there should be a log');
    }
}
