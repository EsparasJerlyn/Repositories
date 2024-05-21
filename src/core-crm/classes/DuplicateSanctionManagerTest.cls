/**
 * @description Test class for DuplicateSanctionManager
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2024        | DEPP-7984              | Created file                 |
 */
@isTest
private class DuplicateSanctionManagerTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
    static void processSanctionStudentNotFoundTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            List<Student_Sanction__c> studentSanctionList = TestDataFactory.createStudentSanctionRecords(100);
            Integer count = 0;
            for(Contact con: ContactsDAO.newInstance().getPersonContactsWithLimit(100)){
                studentSanctionList[count].QUT_Student_ID__c = String.valueOf(con.Id).subString(0,10);
                count ++;
            }
            StudentSanctionsDAO.newInstance().insertRecords(studentSanctionList,true,AccessLevel.USER_MODE);
            Test.stopTest();

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance().getLogEntriesByRelatedRecordId(
                new Map<Id,Student_Sanction__c>(studentSanctionList).keySet(),
                AccessLevel.USER_MODE
            );

            System.assert(!logEntries.isEmpty(),'there should be log entries');

            for(LogEntry__c logEntry: logEntries ){
                System.assertEquals(
                    'Sanction Student Not Found',
                    logEntry.Message__c,
                    'Error message should be sanction student not found'
                );                             
            }
        }
    }

    @isTest
    static void processDuplicateSanctionSuccessTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            List<Student_Sanction__c> studentSanctionList = TestDataFactory.createStudentSanctionRecords(100);
            Set<String> systemKeyIds = new Set<String>();
            Integer count = 0;
            Map<Id,Contact_Alternate_ID__c> newConAltIds = new Map<Id,Contact_Alternate_ID__c>();
            List<Contact_Alternate_ID__c> conAlIdToUpdate = new List<Contact_Alternate_ID__c>();

            for(Contact con: ContactsDAO.newInstance().getPersonContactsWithLimit(100)){
                studentSanctionList[count].QUT_Student_ID__c = String.valueOf(con.Id).subString(0,9);
                systemKeyIds.add(String.valueOf(con.Id).subString(0,10)); 
                newConAltIds.put(con.Id,new Contact_Alternate_ID__c(
                    Contact__c = con.Id,
                    Alternate_Id_Type__c = 'QUT Student ID',
                    Alternate_Id_Status__c = 'Active',
                    Start_Date__c = System.Today(),
                    Contact_Alternate_Id__c = String.valueOf(con.Id).subString(0,9)
                ));
                count ++;
            }
            
            ContactAlternateIdsDAO.newInstance().insertRecords(newConAltIds.values(),true,AccessLevel.USER_MODE);

            for(Contact_Alternate_ID__c conAlId: ContactAlternateIdsDAO.newInstance()
                                                .getContactAlternateIdsBySystemKeyIdSet(
                                                    systemKeyIds,
                                                    AccessLevel.USER_MODE
                                                )){
                conAlIdToUpdate.add(new Contact_Alternate_ID__c(
                    Id = conAlId.Id,
                    Alternate_Id_Status__c = 'Superseded',
                    Succeeding_Id__c = newConAltIds.get(conAlId.Contact__c).Id
                ));
            }

            ContactAlternateIdsDAO.newInstance().updateRecords(conAlIdToUpdate,true,AccessLevel.USER_MODE);
            StudentSanctionsDAO.newInstance().insertRecords(studentSanctionList,true,AccessLevel.USER_MODE);
            Test.stopTest(); 

            System.assert(!ContactAlternateIdsDAO.newInstance()
                            .getContactAlternateIdsBySystemKeyIdSet(
                                systemKeyIds,
                                AccessLevel.USER_MODE
                            ).isEmpty(),
                            'The superseded contact alternate ids should be active and be retrieved'
                        );
        }
    }
}