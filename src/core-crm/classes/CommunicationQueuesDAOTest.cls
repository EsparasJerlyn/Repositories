
/**
 * @description Test class for CommunicationQueuesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 30, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class CommunicationQueuesDAOTest {
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
}