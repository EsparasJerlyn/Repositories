/**
 * @description Test Class for Application Service.
 *  
 * @see ApplicationService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | June 19,2023          | DEPP-5846    | Created file                                |
      | mark.j.mahilum            | May 06, 2024          | DEPP-7987    | Updated test class                          |
*/
@isTest
private class ApplicationServiceTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    private static void testApplicationBatchInsertNoMatchContact() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationStudyLinkRecords(recordsCount, recordsCount * 2,'Existing'),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationBatchInsertNewApplication() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationStudyLinkRecords(recordsCount, recordsCount * 2,'New'),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationBatchInsertOneContactMatch() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            List<hed__Application__c> applicationList = TestDataFactory.createTestApplicationStudyLinkRecords(0, recordsCount,'Existing');
            applicationList[0].Email__c = '0'+EMAIL;
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    applicationList,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }

            Contact con =  ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)[0];
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Marketing field should be false');
            System.assertEquals(false, con.Learner_Email_Opt_Out__c, 'Marketing field should be false');
            System.assertEquals(false, con.Staff_Email_Opt_Out__c, 'Marketing field should be false');
            System.assertEquals(false, con.Work_Email_Opt_Out__c, 'Marketing field should be false');
            System.assertEquals(false, con.Work_SMS_Opt_Out__c, 'Marketing field should be false');
            System.assertEquals(false, con.hed__SMS_Opt_Out__c, 'Marketing field should be false');
            System.assertEquals(false, con.DoNotCall, 'Marketing field should be false');
            System.assertEquals(true, con.Sync_to_MC__c, 'Marketing field should be true');
            System.assertEquals(false, con.Do_Not_Sync_To_MC_Override__c, 'Marketing field should be false');
            System.assert(con.Dont_Market_Reason__c == null, 'Marketing field Dont_Market_Reason__c should be empty');
            System.assert(con.Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
            System.assert(con.Learner_Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
            System.assert(con.Staff_Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
            System.assert(con.Work_Email_Opt_In_DateTime__c != null, 'Marketing field should be populated');
            System.assert(con.Work_SMS_Opt_In_DateTime__c != null, 'Marketing field should be populated');
            System.assert(con.SMS_Opt_In_DateTime__c != null, 'Marketing field should be populated');
        }
    }
    
    @isTest
    private static void testApplicationBatchInsertMultipleContactMatch() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = createTestContactRecords(0, 3);
			for (Integer i = 0; i < 3; i++) {
                newContacts[i].FirstName = FIRSTNAME;
                newContacts[i].LastName = LASTNAME;
                newContacts[i].BirthDate = null;
            }            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Application__c> newApplications = createTestApplicationStudyLinkRecords(0, recordsCount,'Existing');
            
			for (Integer i = 0; i < 3; i++) {
                newApplications[i].FirstName__c = FIRSTNAME;
                newApplications[i].LastName__c = LASTNAME;
                newApplications[i].BirthDate__c = null;
            }            
            
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    newApplications,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationBatchInsertEmailContactMatch() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = createTestContactRecords(0, 3);
			for (Integer i = 0; i < 3; i++) {
                newContacts[i].FirstName = FIRSTNAME + i;
                newContacts[i].LastName = LASTNAME + i;
                newContacts[i].Email = i + EMAIL;
            }            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);           
            List<hed__Application__c> newApplications = createTestApplicationStudyLinkRecords(0, recordsCount,'Existing');
            
			for (Integer i = 0; i < 3; i++) {
                newApplications[i].FirstName__c = FIRSTNAME;
                newApplications[i].LastName__c = LASTNAME;
                newApplications[i].Email__c = i + EMAIL;
            }            
                        
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    newApplications,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationBatchInsertEmailLeadMatch() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Lead> newLeads = createTestLeadRecords(0, 3);
			for (Integer i = 0; i < 3; i++) {
                newLeads[i].FirstName = FIRSTNAME + i;
                newLeads[i].LastName = LASTNAME + i;
                newLeads[i].Email = i + EMAIL;
            }            
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Application__c> newApplications = createTestApplicationStudyLinkRecords(0, recordsCount,'New');
            
			for (Integer i = 0; i < 3; i++) {
                newApplications[i].FirstName__c = FIRSTNAME;
                newApplications[i].LastName__c = LASTNAME;
                newApplications[i].Email__c = i + EMAIL;
            }            
            
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    newApplications,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationSAMBatchInsertNoMatchContact() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<hed__Application__c> newApplications = createTestApplicationStudyLinkRecords(0, recordsCount,'New');
            
            for(hed__Application__c app: newApplications){
                app.RecordTypeId = ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    newApplications,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationQTACBatchInsertNoMatchContact() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<hed__Application__c> newApplications = createTestApplicationStudyLinkRecords(0, recordsCount,'New');
                                                             
            for(hed__Application__c app: newApplications){
                app.RecordTypeId = ApplicationsDAO.QTAC_RECTYPE_ID;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    newApplications,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record should not be saved.');
            }
        }
    }
    
    private static List<hed__Application__c> createTestApplicationStudyLinkRecords(Integer startAtCount, Integer endBeforeCount, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = FIRSTNAME + i,
                    LastName__c = i + LASTNAME,
                    BirthDate__c = System.Today().addYears(-17).addDays(i),
                    Email__c = 'work' + i + EMAIL,
                    Application_Status__c = applicationStatus,
                    RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                    Indigenous_Status__c = 'Aboriginal',
                    Citizenship_Country__c = 'Australia',
                    Mobile__c = '0400000000' + i,
                    Citizenship_Status__c = 'Domestic'
                )
            );
        }
        return newApplications;
    }
    
    private static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = FIRSTNAME + i,
                    LastName = i + LASTNAME,
                    BirthDate = System.Today().addYears(-17).addDays(i),
                    Email = i + EMAIL,
                    QUT_Learner_Email__c = 'learner' + i + EMAIL,
                    QUT_Staff_Email__c = 'staff' + i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + EMAIL,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }
    
    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    FirstName = FIRSTNAME,
                    LastName = LASTNAME + i,
                    Email = i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    Company = 'Learner' + i
                )
            );
        }
        return newLeads;
    }
}