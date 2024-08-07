/**
 * @description Test class for ContactMatchingStagingBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 08, 2024          | DEPP-8676              | Created file                 |
 */
@isTest
private class ContactMatchingStagingBatchTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void createContactMatchingStagingTest() {

        ImplementationSelector.DAO.setMock(new ConMatchingServiceConfigurationsDAOMock());
        String developerName = ConMatchingServiceConfigurationsDAO.CONTACT_MATCHING_STAGING_BATCH;
        Contact_Matching_Service_Configuration__mdt customMetaData = (Contact_Matching_Service_Configuration__mdt) JSON.deserialize(
            '{"IsActive__c":"true","Size__c":"200","DeveloperName":"' + developerName + '"}',
            Contact_Matching_Service_Configuration__mdt.class
        );

        ConMatchingServiceConfigurationsDAO.newInstance()
            .insertRecords(
                new List<Contact_Matching_Service_Configuration__mdt>{ customMetaData },
                true,
                AccessLevel.SYSTEM_MODE
            );
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = TestDataFactory.createContactMatchingStagings(
                200
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

            List<LogEntry__c> logEntriesMessage = LogEntriesDAO.newInstance()
                .getLogEntriesByMessage(
                    new Set<String>{ 'Total number of Contact Matching Staging processed: 200' },
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntriesMessage.isEmpty(), 'there should be log entries');
        }
    }
}
