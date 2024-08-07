/**
 * @description Test class for ELCPreviewBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 22, 2024          | DEPP-8744              | Created file                 |
 */
@isTest
private class ELCPreviewBatchTest {
    @TestSetup
    static void setupMethod() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void handleSuccessTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c(
                Engagement_List_Criteria_Title__c = 'Test',
                Citizenship_Status__c = 'International',
                Engagement_List_Configuration__c = configs[0].Id
            );

            Contact con = new Contact(
                QUT_Student_ID__c = '1234',
                Email = 'test@email.com',
                MobilePhone = '123456',
                LastName = 'Test',
                QUT_Student__c = true,
                hed__Citizenship_Status__c = 'International'
            );

            ContactsDAO.newInstance()
                .insertRecords(new List<Contact>{ con }, true, AccessLevel.SYSTEM_MODE);

            EngagementListCriteriasDAO.newInstance()
                .insertRecords(
                    new List<Engagement_List_Criteria__c>{ elc },
                    true,
                    AccessLevel.SYSTEM_MODE
                );

            Test.startTest();
            ELCPreviewBatch previewBatch = new ELCPreviewBatch(elc, System.today());
            Database.executeBatch(previewBatch);
            Test.stopTest();

            System.assert(
                EngagementListCriteriasDAO.newInstance()
                    .getEntryCriteriaById(elc.Id, AccessLevel.USER_MODE)
                    .Preview_Result_Attachment_Id__c != null,
                'An attachment should be created '
            );
        }
    }

    @isTest
    static void handleFailTest() {
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

            Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c(
                Engagement_List_Criteria_Title__c = 'Test',
                Citizenship_Status__c = 'International',
                Engagement_List_Configuration__c = configs[0].Id
            );

            Contact con = new Contact(
                QUT_Student_ID__c = '1234',
                Email = 'test@email.com',
                MobilePhone = '123456',
                LastName = 'Test',
                QUT_Student__c = true,
                hed__Citizenship_Status__c = 'International'
            );

            ContactsDAO.newInstance()
                .insertRecords(new List<Contact>{ con }, true, AccessLevel.SYSTEM_MODE);

            EngagementListCriteriasDAO.newInstance()
                .insertRecords(
                    new List<Engagement_List_Criteria__c>{ elc },
                    true,
                    AccessLevel.SYSTEM_MODE
                );

            Test.startTest();
            ELCPreviewBatch previewBatch = new ELCPreviewBatch(elc, System.today());
            Database.executeBatch(previewBatch);
            Test.stopTest();

            System.assert(
                !LogEntriesDAO.newInstance()
                    .getLogEntriesByRelatedRecordId(new Set<Id>{ elc.Id }, AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'There should be a log created'
            );
        }
    }

    @isTest
    static void eLCPreviewBatchWithErrorTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            EmailTemplate emailTemplate = new EmailTemplate();
            emailTemplate.Name = 'Preview Generated Fail Email';
            emailTemplate.Subject = 'Test Subject';
            emailTemplate.HtmlValue = '<html></html>';
            emailTemplate.TemplateType = 'custom';
            emailTemplate.UiType = 'SFX';
            emailTemplates.add(emailTemplate);
            EmailTemplatesDAO.newInstance()
                .insertRecords(emailTemplates, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c(
                Engagement_List_Criteria_Title__c = 'Test',
                Citizenship_Status__c = 'International',
                Engagement_List_Configuration__c = configs[0].Id
            );

            Contact con = new Contact(
                QUT_Student_ID__c = '1234',
                Email = 'test@email.com',
                MobilePhone = '123456',
                LastName = 'Test',
                QUT_Student__c = true,
                hed__Citizenship_Status__c = 'International'
            );

            ContactsDAO.newInstance()
                .insertRecords(new List<Contact>{ con }, true, AccessLevel.SYSTEM_MODE);

            EngagementListCriteriasDAO.newInstance()
                .insertRecords(
                    new List<Engagement_List_Criteria__c>{ elc },
                    true,
                    AccessLevel.SYSTEM_MODE
                );

            Test.startTest();
            ELCPreviewBatch previewBatch = new ELCPreviewBatch(elc, System.today(), new Set<String>{'Test Error 1','Test Error 2'});
            Database.executeBatch(previewBatch);
            Test.stopTest();

            System.assert(
                !LogEntriesDAO.newInstance()
                    .getLogEntriesByRelatedRecordId(new Set<Id>{ elc.Id }, AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'There should be a log created'
            );
        }
    }
}
