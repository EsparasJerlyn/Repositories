
/**
 * @description Test class for CommunicationQueuesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                          |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------|
      | eccarius.munoz                 | August 30, 2023       | DEPP-6138              | Created file                                            |
      | alexander.cadalin              | March 07, 2024        | DEPP-8035              | Added queryLocatorNoAnswerSMSQueue                      |
      | gabriel.p.ventayen             | May 23, 2024          | DEPP-8833              | Added getComminicationQueueRecordsByIdSets              |
 */
@isTest
public with sharing class CommunicationQueuesDAOTest {
    private static final String TEST_TEMPLATE = 'Test Email Template';

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void queryLocatorScheduledCommunicationQueueTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                CommunicationQueuesDAO.newInstance().queryLocatorScheduledCommunicationQueue() != null,
                'Communication queues retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void queryLocatorSentCommunicationQueueTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                CommunicationQueuesDAO.newInstance().queryLocatorSentCommunicationQueue() != null,
                'Communication queues retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void queryLocatorNoAnswerSMSQueueTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                CommunicationQueuesDAO.newInstance().queryLocatorNoAnswerSMSQueue() != null,
                'Communication queues retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new CommunicationQueuesDAO().getSObjectType() == Communication_Queue__c.SObjectType,
                'SObject is not Communication_Queue__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getComminicationQueueRecordsByStatusTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Communication_Queue__c> commsQueueList = CommunicationQueuesDAO.newInstance()
                .getComminicationQueueRecordsByStatus(
                    new Set<String>(),
                    AccessLevel.USER_MODE
                );
            System.assert(commsQueueList.isEmpty(), 'commsQueueList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCommsQueueRecordsByStatusAndLastModifiedTodayTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Communication_Queue__c> commsQueueList = CommunicationQueuesDAO.newInstance()
                .getCommsQueueRecordsByStatusAndLastModifiedToday(
                    new Set<String>(),
                    AccessLevel.USER_MODE
                );
            System.assert(commsQueueList.isEmpty(), 'commsQueueList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getComminicationQueueRecordsByIdSetsTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {

            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;

            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 2);
            newContacts[0].AccountId = acc.Id;
            newContacts[0].QUT_Learner_Email__c = 'TestEmail@unique.com';
            newContacts[1].AccountId = acc.Id;
            newContacts[1].QUT_Learner_Email__c = 'TestEmail@unique2.com';
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.USER_MODE);
            
            List<EmailTemplate> emailTemplateList = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                TEST_TEMPLATE => 'Test Email Subject1'
            });
            insert emailTemplateList;

            Set<Id> contactIds = (new Map<Id,Contact>(newContacts)).keySet();
            List<Communication_Queue__c> expectedCommunicationQueueList = TestDataFactory.createCommunicationQueuePerContactOrLead(
                contactIds, 
                CommunicationQueuesDAO.STATUS_SCHEDULED, 
                emailTemplateList[0].Id
            );
            insert expectedCommunicationQueueList;

            Set<Id> expectedCommunicationQueueIds = (new Map<Id,Communication_Queue__c>(expectedCommunicationQueueList)).keySet();
            Set<Id> actualCommunicationQueueIds = new Set<Id>();

            Test.startTest();
                List<Communication_Queue__c> actualCommunicationQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByIdSets(
                    expectedCommunicationQueueIds,
                    AccessLevel.USER_MODE
                );
                actualCommunicationQueueIds = (new Map<Id,Communication_Queue__c>(actualCommunicationQueueList)).keySet();
            Test.stopTest();

            System.assert( 
                actualCommunicationQueueList.size() > 0,
                'commsQueueList should not be empty.'
            );
            System.assertEquals(
                expectedCommunicationQueueIds, 
                actualCommunicationQueueIds,
                'Expected and Actual Communication Queues not matched.'
            );
        }
    }
}