/**
 * @description Test class for ContactMatchingStagingService
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 08, 2024          | DEPP-8676              | Created file                 |
 */
@isTest
private class ContactMatchingStagingServiceTest {

    static {
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
    }
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 1);
        Integer count = 0;
        for (Contact con : contactRecords) {
            con.QUT_Student_ID__c = '01' + count++;
            con.QUT_Employee_ID__c = '02' + count++;
        }
        ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);
    }

    @isTest
    static void systemKeyMatchingTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            Set<Id> contactIdSet = new Set<Id>();

            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName,
                        FirstName__c = null,
                        Email__c = con.Email,
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c,
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c,
                        QUT_Student_ID__c = con.QUT_Student_ID__c,
                        QUT_Employee_ID__c = con.QUT_Employee_ID__c,
                        Deceased__c = true,
                        Phone__c = '0909090909',
                        Mailing_State__c = 'Test',
                        Mailing_City__c = 'Test',
                        Mailing_Street__c = 'Test',
                        Mailing_Country__c = 'Test',
                        Residential_State__c = 'Test',
                        Residential_City__c = 'Test',
                        Residential_Street__c = 'Test',
                        Residential_Country__c = 'Test'
                    )
                );
            }
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                system.assertEquals(true, con.hed__Deceased__c, 'Contact should be deceased');
                system.assertEquals(null, con.FirstName, 'Contact fistname should be nullified');
                system.assert(con.Work_Email__c != null, 'work email should not be nullified');
                system.assertEquals('0909090909', con.Phone, 'phone should match');
                system.assertEquals('Test', con.MailingState, 'Mailing State should match');
                system.assertEquals('Test', con.MailingCity, 'Mailing City should match');
                system.assertEquals('Test', con.MailingStreet, 'Mailing Street should match');
                system.assertEquals('Test', con.MailingCountry, 'Mailing Country should match');
                system.assertEquals('Test', con.OtherState, 'Other State should match');
                system.assertEquals('Test', con.OtherCity, 'Other City should match');
                system.assertEquals('Test', con.OtherStreet, 'Other Street should match');
                system.assertEquals('Test', con.OtherCountry, 'Other Country should match');
                contactIdSet.add(con.Id);
            }

            System.assertEquals(
                2,
                AddressesDAO.newInstance()
                    .getAddressesByContactIdsSet(contactIdSet, AccessLevel.USER_MODE)
                    .size(),
                'There should be 2 address records'
            );
        }
    }

    @isTest
    static void nonSystemKeyMatchingTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            Set<Id> contactIdSet = new Set<Id>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName,
                        FirstName__c = con.FirstName,
                        Email__c = con.Email,
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c,
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c,
                        Birthdate__c = con.BirthDate,
                        Deceased__c = true,
                        Mailing_State__c = 'Test',
                        Mailing_City__c = 'Test',
                        Mailing_Street__c = 'Test',
                        Mailing_Country__c = 'Test',
                        Residential_State__c = 'Test',
                        Residential_City__c = 'Test',
                        Residential_Street__c = 'Test',
                        Residential_Country__c = 'Test'
                    )
                );
            }
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                system.assertEquals(true, con.hed__Deceased__c, 'Contact should be deceased');
                system.assert(
                    String.isNotBlank(con.Work_Email__c),
                    'work email should not be null'
                );
                system.assertEquals('Test', con.MailingState, 'Mailing State should match');
                system.assertEquals('Test', con.MailingCity, 'Mailing City should match');
                system.assertEquals('Test', con.MailingStreet, 'Mailing Street should match');
                system.assertEquals('Test', con.MailingCountry, 'Mailing Country should match');
                system.assertEquals('Test', con.OtherState, 'Other State should match');
                system.assertEquals('Test', con.OtherCity, 'Other City should match');
                system.assertEquals('Test', con.OtherStreet, 'Other Street should match');
                system.assertEquals('Test', con.OtherCountry, 'Other Country should match');
                contactIdSet.add(con.Id);
            }

            System.assertEquals(
                2,
                AddressesDAO.newInstance()
                    .getAddressesByContactIdsSet(contactIdSet, AccessLevel.USER_MODE)
                    .size(),
                'There should be 2 address records'
            );
        }
    }

    @isTest
    static void nonSystemKeyMatchingWithoutAdressTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            Set<Id> contactIdSet = new Set<Id>();
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
                contactIdSet.add(con.Id);
            }

            System.assertEquals(
                0,
                AddressesDAO.newInstance()
                    .getAddressesByContactIdsSet(contactIdSet, AccessLevel.USER_MODE)
                    .size(),
                'There should be 0 address records'
            );
        }
    }

    @isTest
    static void noMatchTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
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
                2,
                ContactsDAO.newInstance().getPersonContactsWithLimit(200).size(),
                'There should be 2 contact in total'
            );
        }
    }

    @isTest
    static void createContactMatchingStagingTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = TestDataFactory.createContactMatchingStagings(
                1
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
                    new Set<String>{ 'Total number of Contact Matching Staging processed: 1' },
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntriesMessage.isEmpty(), 'there should be log entries');
        }
    }

    @isTest
    static void noMatchTestWithError() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            Set<Id> contactIdSet = new Set<Id>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName + 'new',
                        FirstName__c = con.FirstName + 'new',
                        Email__c = con.Email + 'new',
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c + 'new',
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c + 'new',
                        Birthdate__c = System.Today() //should throw birthdate error
                    )
                );
                contactIdSet.add(con.Id);
            }

            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assertEquals(
                1,
                ContactsDAO.newInstance().getPersonContactsWithLimit(200).size(),
                'There should be 1 contact in total'
            );
            System.assertEquals(
                0,
                AddressesDAO.newInstance()
                    .getAddressesByContactIdsSet(contactIdSet, AccessLevel.USER_MODE)
                    .size(),
                'There should be 0 address records'
            );

            List<LogEntry__c> logEntriesMessage = LogEntriesDAO.newInstance()
                .getLogEntriesByMessage(
                    new Set<String>{ 'Error in inserting records' },
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntriesMessage.isEmpty(), 'there should be log entries');
        }
    }

    @isTest
    static void withExistingAddressTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();
            Set<Id> contactIdsSet = new Set<Id>();
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                conMatchingStagings.add(
                    new Contact_Matching_Staging__c(
                        LastName__c = con.LastName ,
                        FirstName__c = con.FirstName,
                        Email__c = con.Email,
                        QUT_Learner_Email__c = con.QUT_Learner_Email__c,
                        QUT_Staff_Email__c = con.QUT_Staff_Email__c,
                        Birthdate__c = con.BirthDate,
                        Mailing_State__c = 'Test',
                        Mailing_City__c = 'Test',
                        Mailing_Street__c = 'Test',
                        Mailing_Country__c = 'Test',
                        Residential_State__c = 'Test',
                        Residential_City__c = 'Test',
                        Residential_Street__c = 'Test',
                        Residential_Country__c = 'Test'
                    )
                );
                contactIdsSet.add(con.Id);
            }
            ContactMatchingStagingsDAO.newInstance()
                .insertRecords(conMatchingStagings, true, AccessLevel.USER_MODE);
            Test.stopTest();

            for(Contact_Matching_Staging__c conMatchingStaging: conMatchingStagings){
                conMatchingStaging.Mailing_State__c = 'Test New';
                conMatchingStaging.Mailing_City__c = 'Test New';
                conMatchingStaging.Mailing_Street__c = 'Test New';
                conMatchingStaging.Mailing_Country__c = 'Test New';
                conMatchingStaging.Residential_State__c = 'Test New';
                conMatchingStaging.Residential_City__c = 'Test New';
                conMatchingStaging.Residential_Street__c = 'Test New';
                conMatchingStaging.Residential_Country__c = 'Test New';
            }
            ContactMatchingStagingBatchManager.processContactMatching(conMatchingStagings);

            System.assertEquals(
                1,
                ContactsDAO.newInstance().getPersonContactsWithLimit(200).size(),
                'There should be 1 contact in total'
            );

            System.assertEquals(
                2,
                AddressesDAO.newInstance()
                    .getAddressesByContactIdsSet(contactIdsSet, AccessLevel.USER_MODE)
                    .size(),
                'There should be 2 address records'
            );

            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(1)) {
                system.assertEquals('Test New', con.MailingState, 'Mailing State should match');
                system.assertEquals('Test New', con.MailingCity, 'Mailing City should match');
                system.assertEquals('Test New', con.MailingStreet, 'Mailing Street should match');
                system.assertEquals('Test New', con.MailingCountry, 'Mailing Country should match');
                system.assertEquals('Test New', con.OtherState, 'Other State should match');
                system.assertEquals('Test New', con.OtherCity, 'Other City should match');
                system.assertEquals('Test New', con.OtherStreet, 'Other Street should match');
                system.assertEquals('Test New', con.OtherCountry, 'Other Country should match');
            }
        }
    }
}
