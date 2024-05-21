/**
 * @description Test class for ContactMatchingStagingTriggerHelperTest
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 08, 2024          | DEPP-8676              | Created file                 |
 */
@isTest
private class ContactMatchingStagingTriggerHelperTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
        Test.stopTest();
    }

    @isTest
    static void createContactMatchingStagingTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = TestDataFactory.createContactMatchingStagings(
                100
            );
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance()
                .getLogEntriesByRelatedRecordId(
                    new Map<Id, Contact_Matching_Staging__c>(conMatchingStagings).keySet(),
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntries.isEmpty(), 'there should be log entries');
            MatchingResult result = new MatchingResult('', 'Insufficient information to match');
            for (LogEntry__c logEntry : logEntries) {
                System.assertEquals(
                    JSON.serializePretty(result),
                    logEntry.Message__c,
                    'Error message should be' + JSON.serializePretty(result)
                );
            }
        }
    }

    @isTest
    static void contactMatchingStagingError() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            ContactMatchingStagingTriggerHelper.executeContactMatchingBatch(null);
            Test.stopTest();

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance()
                .getLogEntriesByMessage(
                    new Set<String>{
                        'Exception caught in method executeContactMatchingBatch in class ContactMatchingStagingTriggerHelper.'
                    },
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntries.isEmpty(), 'there should be log entries');

            for (LogEntry__c logEntry : logEntries) {
                System.assertEquals(
                    'Exception caught in method executeContactMatchingBatch in class ContactMatchingStagingTriggerHelper.',
                    logEntry.Message__c,
                    'Error message should be Exception caught in method executeContactMatchingBatch in class ContactMatchingStagingTriggerHelper.'
                );
            }
        }
    }
}
