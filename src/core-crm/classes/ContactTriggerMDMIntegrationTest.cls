/**
 * @description Test class for ContactTriggerMDMIntegration
 * @see classes/ContactTriggerMDMIntegration
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | February 07, 2023     | DEPP-5040    | Created file                                | 
      | eccarius.munoz            | August 13, 2024       | DEPP-10490   | Updated methods for the platform event      | 
      |                           |                       |              |                                             | 
 */
@isTest
public with sharing class ContactTriggerMDMIntegrationTest {

    @testSetup
    static void setupData(){
        Test.startTest();

        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserSystemAdministrator();

        Integration_Settings__c integrationSettings = new Integration_Settings__c(Allow_ESB_Integration__c = true);
        insert integrationSettings;

        Test.stopTest();
    }

    @isTest
    private static void logMDMStudentsAsNonESBUserTest(){        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;
            Test.stopTest();

            List<EventBusSubscriber> eventBusSubscriberList = [SELECT Position, Status FROM EventBusSubscriber WHERE Topic = 'MDM_Callout_Event__e' AND Type = 'ApexTrigger'];
            for(EventBusSubscriber eventBusSubscriber : eventBusSubscriberList){
                System.Assert.isTrue(eventBusSubscriber.Position > 0 && eventBusSubscriber.Status == 'Running', 'Students should be processed and handled by the event.');
            }
        }
    }

    @isTest
    private static void logMDMStudentsAsESBUserTest(){       
        User esbIntegrationUser;
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            esbIntegrationUser = new User(
                Username = 'testesbuser@test.com', 
                Email = 'testesbuser@test.com', 
                Alias = 'esbus', 
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US',
                FirstName = 'ESB',
                LastName = 'Integration User'
            );
            insert esbIntegrationUser;
        }

        System.runAs(esbIntegrationUser){
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;
            Test.stopTest();

            List<EventBusSubscriber> eventBusSubscriberList = [SELECT Position, Status FROM EventBusSubscriber WHERE Topic = 'MDM_Callout_Event__e' AND Type = 'ApexTrigger'];
            for(EventBusSubscriber eventBusSubscriber : eventBusSubscriberList){
                System.Assert.isTrue(eventBusSubscriber.Position == 0 && eventBusSubscriber.Status == 'Running', 'Students should not be processed and handled by the event.');
            }
        }
    }

}