/**
 * @description Test class for EngagementListCriteriaTriggerHandler
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 24, 2024          | DEPP-8745              | Created file                 |
 */
@isTest
private class EngagementListCriteriaTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void beforeUpdatetest() {
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

            EngagementListCriteriasDAO.newInstance()
                .insertRecords(
                    new List<Engagement_List_Criteria__c>{ elc },
                    true,
                    AccessLevel.SYSTEM_MODE
                );

            elc.Citizenship_Status__c = 'Domestic';
            Test.startTest();
            EngagementListCriteriasDAO.newInstance()
                .updateRecords(
                    new List<Engagement_List_Criteria__c>{ elc },
                    true,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();

            // assert that the criteria is updated
            System.assertEquals(
                'Domestic',
                EngagementListCriteriasDAO.newInstance()
                    .getEntryCriteriaById(elc.Id, AccessLevel.SYSTEM_MODE).Citizenship_Status__c,
                'Criteria should be updated'
            );
        }
    }
}
