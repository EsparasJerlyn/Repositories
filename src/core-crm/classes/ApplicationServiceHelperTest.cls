/**
 * @description Test Class for ApplicationServiceHelper
 *
 * @see ApplicationService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | June 19,2023          | DEPP-5846    | Created file                                |
      | mark.j.mahilum            | May 06, 2024          | DEPP-7987    | Updated test class to cover changes in      |
      |                           |                       |              | contact matching logic                      |
*/
@isTest
private class ApplicationServiceHelperTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;

    static {
        ImplementationSelector.DAO.setMock(new ConMatchingServiceConfigurationsDAOMock());
        String developerName = ConMatchingServiceConfigurationsDAO.APPLICATION_BATCH;
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
    }

    @isTest
    private static void testApplicationBatchInsertNoMatchContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<hed__Application__c> appList = TestDataFactory.createTestApplicationStudyLinkRecords(
                recordsCount,
                recordsCount * 2,
                'Existing'
            );
            Integer count = 0;
            Set<String> systemKeyIds = new Set<String>();
            for (hed__Application__c app : appList) {
                app.StudyLink_ApplicantID__c = '1' + count;
                app.QTAC_ApplicantID__c = '2' + count;
                systemKeyIds.add(app.StudyLink_ApplicantID__c);
                systemKeyIds.add(app.QTAC_ApplicantID__c);
            }
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(appList, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<hed__Application__c> newAppList = [SELECT id, hed__applicant__r.ContactMobile_Locale__c  FROM hed__Application__c WHERE hed__applicant__c != NULL];
            
            for(hed__Application__c app:newAppList){
                System.assertEquals(ContactsDAO.AU_LOCALE, app.hed__applicant__r.ContactMobile_Locale__c, 'Locale did not match');
            }

            //check if application are associated with contact
            System.assertEquals(
                newAppList.size(),
                srList.size(),
                'Contact created is not match'
            );

            //check if the application are all processed
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Contact created is not match'
            );

            System.assertEquals(
                40,
                ContactAlternateIdsDAO.newInstance()
                    .getContactAlternateIdsBySystemKeyIdSet(systemKeyIds, AccessLevel.SYSTEM_MODE)
                    .size(),
                'No contact alternate ids created'
            );
        }
    }

    @isTest
    private static void testApplicationBatchInsertNoMatchContactCreateNewLead() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestApplicationStudyLinkRecords(
                        recordsCount,
                        recordsCount * 2,
                        'New'
                    ),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();

            List<hed__Application__c> appList = [SELECT id, Lead__r.LeadMobile_Locale__c  FROM hed__Application__c WHERE Lead__c != NULL];
            
            for(hed__Application__c app:appList){
                System.assertEquals(LeadsDAO.AU_LOCALE, app.Lead__r.LeadMobile_Locale__c, 'Locale did not match');
            }

            //check if application are associated with new lead
            System.assertEquals(
                appList.size(),
                srList.size(),
                'Lead created is not match'
            );

            //check if the application are all processed
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Application batch process size is not match'
            );
        }
    }

    @isTest
    private static void testApplicationBatchSystemKeyMatched() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
            List<Contact> contactRecords = TestDataFactory.createTestApplicationContactRecords(
                0,
                3
            );
            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.SYSTEM_MODE);

            for (Integer i = 0; i < contactRecords.size(); i++) {
                contactAlternateIds.add(
                    TestDataFactory.createTestConAltIdRecordByContactAndType(
                        contactRecords[i].Id,
                        'StudyLink Applicant ID',
                        contactRecords[i].Id
                    )
                );
            }

            ContactAlternateIdsDAO.newInstance()
                .insertRecords(contactAlternateIds, true, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationStudyLinkRecords(
                0,
                3,
                'New'
            );

            for (Integer i = 0; i < 3; i++) {
                newApplications[i].StudyLink_ApplicantID__c = contactRecords[i].Id;
            }

            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            //check if application are associated with contact using system key
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE hed__applicant__c != NULL].size(),
                srList.size(),
                'Contact match is not the same'
            );

            //check if the application are all processed
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Application batch process size is not match'
            );

            Map<String, String> conAltIdsMap = new Map<String, String>();
            //Get the alternate Id of contact
            for (Contact_Alternate_ID__c conAltId : [
                SELECT id, Contact_Alternate_Id__c, Contact__c
                FROM Contact_Alternate_ID__c
                WHERE Alternate_Id_Type__c = 'StudyLink Applicant ID'
            ]) {
                conAltIdsMap.put(conAltId.Contact_Alternate_Id__c, conAltId.Contact__c);
            }

            //check if contact system key is matched with the application StudyLink_ApplicantID__c id
            for (hed__Application__c app : [
                SELECT Id, StudyLink_ApplicantID__c, hed__applicant__c
                FROM hed__Application__c
                WHERE hed__applicant__c != NULL
            ]) {
                //check if application has the same alternate id = studylink Id
                System.assertEquals(
                    conAltIdsMap.containsKey(app.StudyLink_ApplicantID__c),
                    true,
                    'Application is not match with system key'
                );
                //check if the associated contact is the same as what is associated with alternate Id
                System.assertEquals(
                    conAltIdsMap.get(app.StudyLink_ApplicantID__c),
                    app.hed__applicant__c,
                    'Application is not match with system key'
                );
            }
        }
    }

    @isTest
    private static void testApplicationBatchMultipleMatched() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
            List<Contact> contactRecords = TestDataFactory.createTestApplicationContactRecords(
                0,
                3
            );
            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.SYSTEM_MODE);

            for (Integer i = 0; i < contactRecords.size(); i++) {
                contactAlternateIds.add(
                    TestDataFactory.createTestConAltIdRecordByContactAndType(
                        contactRecords[i].Id,
                        'StudyLink Applicant ID',
                        '22333444'
                    )
                );
            }

            ContactAlternateIdsDAO.newInstance()
                .insertRecords(contactAlternateIds, true, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationStudyLinkRecords(
                0,
                3,
                'New'
            );

            for (Integer i = 0; i < 3; i++) {
                newApplications[i].StudyLink_ApplicantID__c = '22333444';
            }

            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            //check if application is not associated with contact
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE hed__applicant__c = NULL].size(),
                srList.size(),
                'Contact match is not the same'
            );

            //check if the application are all processed
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Application batch process size is not match'
            );

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance()
                .getLogEntriesByRelatedRecordId(
                    new Map<Id, hed__Application__c>(newApplications).keySet(),
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntries.isEmpty(), 'there should be log entries');

            for (LogEntry__c logEntry : logEntries) {
                String logErrorMessage = logEntry.Message__c;
                Boolean isErrorExpected = logErrorMessage.containsIgnoreCase(
                    'There has been multiple matches found for the following application'
                );
                System.assertEquals(
                    isErrorExpected,
                    true,
                    'Error message should be sanction student not found'
                );
            }
        }
    }

    @isTest
    private static void testApplicationBatchMultipleInsufficeintDetails() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
            List<Contact> contactRecords = TestDataFactory.createTestApplicationContactRecords(
                0,
                3
            );
            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.SYSTEM_MODE);

            for (Integer i = 0; i < contactRecords.size(); i++) {
                contactAlternateIds.add(
                    TestDataFactory.createTestConAltIdRecordByContactAndType(
                        contactRecords[i].Id,
                        'StudyLink Applicant ID',
                        '22333444'
                    )
                );
            }

            ContactAlternateIdsDAO.newInstance()
                .insertRecords(contactAlternateIds, true, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationStudyLinkRecords(
                0,
                3,
                'New'
            );

            for (Integer i = 0; i < 3; i++) {
                newApplications[i].FirstName__c = '';
                newApplications[i].LastName__c = '';
                newApplications[i].BirthDate__c = Date.valueOf(BIRTHDAY);
                newApplications[i].Email__c = 'work' + i + EMAIL;
            }

            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            //check if application is not associated with contact
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE hed__applicant__c = NULL].size(),
                srList.size(),
                'Contact match is not the same'
            );

            //check if the application are all processed
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Application batch process size is not match'
            );

            List<LogEntry__c> logEntries = LogEntriesDAO.newInstance()
                .getLogEntriesByRelatedRecordId(
                    new Map<Id, hed__Application__c>(newApplications).keySet(),
                    AccessLevel.USER_MODE
                );

            System.assert(!logEntries.isEmpty(), 'there should be log entries');

            //check if error is logged and associated with the application
            for (LogEntry__c logEntry : logEntries) {
                System.assertEquals(
                    'Insufficient information to match',
                    logEntry.Message__c,
                    'Error message should be sanction student not found'
                );
            }
        }
    }

    @isTest
    private static void testApplicationBatchInsertMatchToExistingLead() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> newLeads = TestDataFactory.createTestLeadRecordForApplication(0, 3);
            Map<String, String> leadEmailMap = new Map<String, String>();
            for (Integer i = 0; i < 3; i++) {
                newLeads[i].FirstName = FIRSTNAME + i;
                newLeads[i].LastName = LASTNAME + i;
                newLeads[i].Email = i + EMAIL;
                leadEmailMap.put(newLeads[i].Email, newLeads[i].FirstName);
            }
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationStudyLinkRecords(
                0,
                3,
                'New'
            );

            for (Integer i = 0; i < 3; i++) {
                newApplications[i].FirstName__c = FIRSTNAME + i;
                newApplications[i].LastName__c = LASTNAME + i;
                newApplications[i].BirthDate__c = Date.valueOf(BIRTHDAY);
                newApplications[i].Email__c = i + EMAIL;
            }

            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            //check if application are associated with new lead
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Lead__c != NULL].size(),
                srList.size(),
                'Lead created is not match'
            );

            //check if the application are all processed
            System.assertEquals(
                [SELECT id FROM hed__Application__c WHERE Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Application batch process size is not match'
            );

            //check if Existing Lead is link to the Application via email
            for (hed__Application__c app : [
                SELECT Id, Email__c, FirstName__c, Lead__c
                FROM hed__Application__c
                WHERE Lead__c != NULL
            ]) {
                //check if application has the same email with existing lead
                System.assertEquals(
                    leadEmailMap.containsKey(app.Email__c),
                    true,
                    'Application is not match with system key'
                );
                //check if the associated lead is the same firstname
                System.assertEquals(
                    leadEmailMap.get(app.Email__c),
                    app.FirstName__c,
                    'Application is not match with system key'
                );
            }
        }
    }
}