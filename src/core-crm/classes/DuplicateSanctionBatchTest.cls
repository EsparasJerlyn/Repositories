/**
 * @description Test class for DuplicateSanctionBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2024        | DEPP-7984              | Created file                 |
 */
@isTest
private class DuplicateSanctionBatchTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void processMissingQUTStudentIdTest() {
        ImplementationSelector.DAO.setMock(new ConMatchingServiceConfigurationsDAOMock());
        String developerName = ConMatchingServiceConfigurationsDAO.STUDENT_SANCTION_BATCH;
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
            List<Student_Sanction__c> studentSanctionList = TestDataFactory.createStudentSanctionRecords(200);
            StudentSanctionsDAO.newInstance().insertRecords(studentSanctionList,true,AccessLevel.USER_MODE);
            Test.stopTest();

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByRelatedRecordId(
                new Map<Id,Student_Sanction__c>(studentSanctionList).keySet(),
                AccessLevel.USER_MODE
            );

            System.assert(!logEntries.isEmpty(),'there should be log entries');

            for(LogEntry__c logEntry: logEntries){
                System.assertEquals(
                    'Missing QUT student Id',
                    logEntry.Message__c,
                    'Error message should be missing qut student id'
                );                             
            }

            List<LogEntry__c> logEntriesMessage = LogEntriesDAO.newInstance().getLogEntriesByMessage(
                new Set<String>{'Total number of Student Sanctions processed: 200'},
                AccessLevel.USER_MODE);

            System.assert(!logEntriesMessage.isEmpty(),'there should be log entries');
        }
    }
}