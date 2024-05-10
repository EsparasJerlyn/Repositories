/**
 * @description Test class for ContactMatchingStagingBatchManager
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 08, 2024          | DEPP-8676              | Created file                 |
 */
@isTest
private class ContactMatchingStagingBatchManagerTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_ESB', 'QUT_Program_Administrator' }
        );
        Test.stopTest();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 50);
        Integer count = 0;
        for (Contact con : contactRecords) {
            con.QUT_Student_ID__c = '01' + count++;
            con.QUT_Employee_ID__c = '02' + count++;
        }
        ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);
    }

    @isTest
    static void systemKeyMatchingTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(50)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName,
                        FirstName__c = con.FirstName,
                        Email__c = con.Email,
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c,
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c,
                        QUT_Student_ID__c = con.QUT_Student_ID__c,
                        QUT_Employee_ID__c = con.QUT_Employee_ID__c,
                        Deceased__c = true
                    )
                );
            }
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(50)) {
                system.assertEquals(true, con.hed__Deceased__c, 'Contact should be deceased');
                system.assertEquals(null, con.Work_Email__c, 'work email should be null');
            }
        }
    }

    @isTest
    static void nonSystemKeyMatchingTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(50)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName,
                        FirstName__c = con.FirstName,
                        Email__c = con.Email,
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c,
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c,
                        Birthdate__c = con.BirthDate,
                        Deceased__c = true
                    )
                );
            }
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(50)) {
                system.assertEquals(true, con.hed__Deceased__c, 'Contact should be deceased');
                system.assert(
                    String.isNotBlank(con.Work_Email__c),
                    'work email should not be null'
                );
            }
        }
    }

    @isTest
    static void noMatchTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(50)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName + 'new',
                        FirstName__c = con.FirstName + 'new',
                        Email__c = con.Email + 'new',
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c + 'new',
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c + 'new',
                        Birthdate__c = con.BirthDate
                    )
                );
            }
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assertEquals(
                100,
                ContactsDAO.newInstance().getPersonContactsWithLimit(200).size(),
                'There should be 100 contact in total'
            );
        }
    }

    @isTest
    static void createContactMatchingStagingTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
