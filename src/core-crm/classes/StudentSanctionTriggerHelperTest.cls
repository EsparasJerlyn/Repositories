/**
 * @description Test class for StudentSanctionTriggerHelper
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 20, 2024        | DEPP-7984              | Created file                 |
 */
@isTest
private class StudentSanctionTriggerHelperTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        List<Contact_Alternate_Id__c> conAltIdList = new List<Contact_Alternate_Id__c>();
        List<Contact> contactList = TestDataFactory.createTestContactRecords(100);
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);
        for(Contact con: contactList){
            conAltIdList.add(TestDataFactory.createTestConAltIdRecordByContactAndType(
                con.Id,
                'QUT Student ID',
                String.valueOf(con.Id).subString(0,10))
            );
        }

        ContactAlternateIdsDAO.newInstance().insertRecords(conAltIdList,true,AccessLevel.SYSTEM_MODE);
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
            List<Student_Sanction__c> studentSanctionList = TestDataFactory.createStudentSanctionRecords(100);
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
        }
    }

    @isTest
    static void studentSanctionTriggerHelperError() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            StudentSanctionTriggerHelper.processDuplicateSanctionIntegration(null);
            Test.stopTest();

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByMessage(
                new Set<String>{'Exception caught in method processDuplicateSanctionIntegration in class StudentSanctionTriggerHelper.'},
                AccessLevel.USER_MODE);

            System.assert(!logEntries.isEmpty(),'there should be log entries');
            
            for(LogEntry__c logEntry: logEntries){
                System.assertEquals(
                    'Exception caught in method processDuplicateSanctionIntegration in class StudentSanctionTriggerHelper.',
                    logEntry.Message__c,
                    'Error message should be Exception caught in method processDuplicateSanctionIntegration in class StudentSanctionTriggerHelper.'
                );                             
            }
        }
    }

    @isTest
    static void studentSanctionTriggerHelperNoBatch(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Student_Sanction__c> studentSanctionList = TestDataFactory.createStudentSanctionRecords(100);
            for(Student_Sanction__c ss: studentSanctionList){
                ss.QUT_Student_ID__c = null;
            }

            StudentSanctionsDAO.newInstance().insertRecords(studentSanctionList,true,AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(
                StudentSanctionsDAO.newInstance()
                    .getStudentSanctionsByBatchProcess(
                        new Set<String>{'Insert,Processed'},
                        AccessLevel.USER_MODE)
                    .isEmpty(),
                'there should be no insert or processed batch process value');
        }
    }
    
}