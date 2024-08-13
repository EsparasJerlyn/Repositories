/**
 * @description Test class for MDMStudentCalloutBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 13, 2024       | DEPP-10490             | Created file                 |
 */
@isTest
public with sharing class MDMStudentCalloutBatchTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserSystemAdministrator();

        Integration_Settings__c integrationSettings = new Integration_Settings__c(Allow_ESB_Integration__c = true);
        insert integrationSettings;
        Test.stopTest();
    }

    @isTest
    private static void processStudentCalloutTest(){        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert bypass;

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            Test.startTest();
            MDMStudentCalloutBatch batch = new MDMStudentCalloutBatch(new Set<Id>{contacts[0].Id});
            Database.executeBatch(batch);
            Test.stopTest();

            List<LogEntry__c> logEntriesMessage = [SELECT Id FROM LogEntry__c WHERE LoggingLevel__c = 'ERROR' AND ApexClassName__c = 'MDMStudentCalloutBatch'];
            System.assert(logEntriesMessage.isEmpty(), 'MDM Student Callout Batch failed.');
            
        }
    }

    @isTest
    private static void processStudentCalloutErrorTest(){        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert bypass;

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(500, 'Internal Server Error ', ''));

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            Test.startTest();
            MDMStudentCalloutBatch batch = new MDMStudentCalloutBatch(new Set<Id>{contacts[0].Id});
            Database.executeBatch(batch);
            Test.stopTest();

            List<LogEntry__c> logEntriesMessage = [SELECT Id FROM LogEntry__c WHERE LoggingLevel__c = 'ERROR' AND ApexClassName__c = 'MDMStudentCalloutBatch'];
            System.assert(!logEntriesMessage.isEmpty(), 'MDM Student Callout Batch is expected to fail.');
            
        }
    }

}