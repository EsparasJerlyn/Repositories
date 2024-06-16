/**
 * @description Test class for StudentSanctionTriggerHandler
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 20, 2024        | DEPP-7984              | Created file                 |
 */
@isTest
private class StudentSanctionTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
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
            
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            List<Student_Sanction__c> studentSanctionList = TestDataFactory.createStudentSanctionRecords(100);
            StudentSanctionsDAO.newInstance().insertRecords(
                studentSanctionList,
                true,
                AccessLevel.USER_MODE
            );
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
        }
    }
}