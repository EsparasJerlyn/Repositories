/**
 * @description Test class for DomesticNoAnswerSMSBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | March 07 2024         | DEPP-8035              | Created file                 |
 */
@isTest
public with sharing class DomesticNoAnswerSMSBatchTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            List<Communication_Queue__c> commQueues = new List<Communication_Queue__c>();
            commQueues.add(new Communication_Queue__c(
                Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED,
                Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_DOMESTIC_NO_ANSWER_SMS
            ));
            CommunicationQueuesDAO.newInstance().insertRecords(commQueues, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void executeBatchTest() {
        Id batchableId;
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Test.startTest();
            DomesticNoAnswerSMSBatch batchable = new DomesticNoAnswerSMSBatch();
            batchableId = Database.executeBatch(batchable);            
            Test.stopTest();
        }

        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
    }
}