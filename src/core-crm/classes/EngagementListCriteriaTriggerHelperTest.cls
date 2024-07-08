/**
 * @description Test class for EngagementListCriteriaTriggerHelper
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 24, 2024          | DEPP-8745              | Created file                 |
 */
@isTest
private class EngagementListCriteriaTriggerHelperTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void fastFieldUpdateAndValidationTest() {
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

            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c(
                Engagement_List_Criteria_Title__c = 'Test',
                Citizenship_Status__c = 'International',
                Preview_Status__c = 'Completed',
                Engagement_List_Configuration__c = configs[0].Id
            );

            EngagementListCriteriasDAO.newInstance()
                .insertRecords(
                    new List<Engagement_List_Criteria__c>{ criteria },
                    true,
                    AccessLevel.SYSTEM_MODE
                );
            
            Engagement_List_Criteria__c insertedCriteria = EngagementListCriteriasDAO.newInstance()
            .getEntryCriteriaById(criteria.Id, AccessLevel.SYSTEM_MODE);

            Attachment csvAttachment = new Attachment(
                ParentId = criteria.Id,
                Name = insertedCriteria.Name + '_Preview_Result.csv',
                Body = Blob.valueOf('test'),
                ContentType = 'text/csv'
            );

            //Create attachment records related to the criteria
            AttachmentsDAO.newInstance()
                .insertRecords(new List<Attachment>{ csvAttachment }, true, AccessLevel.USER_MODE);

            criteria.Preview_Result_Attachment_Id__c = csvAttachment.Id;
            criteria.Citizenship_Status__c = 'Domestic';

            Test.startTest();
            EngagementListCriteriasDAO.newInstance()
                .updateRecords(
                    new List<Engagement_List_Criteria__c>{ criteria },
                    true,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();

            // Assert that when criteria field is updated
            // Preview_Result_Attachment_Id__c is nullfied
            // Preview_Status__c is Not Generated
            Engagement_List_Criteria__c updateCriteria = EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(criteria.Id, AccessLevel.SYSTEM_MODE);

            System.assertEquals(
                'Domestic',
                updateCriteria.Citizenship_Status__c,
                'Citizenship status should be updated'
            );
            System.assertEquals(
                null,
                updateCriteria.Preview_Result_Attachment_Id__c,
                'Preview_Result_Attachment_Id__c status should be updated'
            );
            System.assertEquals(
                'Not Generated',
                updateCriteria.Preview_Status__c,
                'Preview_Status__c status should be updated'
            );
            // assert that attachments are deleted
            System.assert(
                AttachmentsDAO.newInstance()
                    .findAttachmentsByNames(
                        new Set<String>{ csvAttachment.Name },
                        AccessLevel.SYSTEM_MODE
                    )
                    .isEmpty(),
                'Attachments should be deleted'
            );
        }
    }
}
