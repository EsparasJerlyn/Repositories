/**
 * @description Test Class for ApplicationTriggerHelper
 *
 * @see ApplicationTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                |
*/
@isTest
private class ApplicationTriggerHelperTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            ApplicationsDAO.newInstance().insertRecords(
                createTestApplicationRecords(newContacts,'Existing',ApplicationsDAO.STUDYLINK_RECTYPE_ID),
                false,
                AccessLevel.SYSTEM_MODE
            );
        }
    }

    @isTest
    private static void testApplicationInsertWithContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationRecords(newContacts,'Existing',ApplicationsDAO.STUDYLINK_RECTYPE_ID),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationUpdateRemoveContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            Id contactId = ContactsDAO.newInstance().getPersonContactsWithLimit(1).iterator().next()?.Id;                
            List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance().getApplicationsByContactIds(new Set<Id>{contactId},'SYSTEM_MODE');   
            
            for(hed__Application__c app: existingApplicationList){            
                
				app.Application_Status__c = 'Accepted';  
                app.hed__Applicant__c = null;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .updateRecords(
                    existingApplicationList,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }
    
    @isTest
    private static void testApplicationWithLeadApplicationStatusWithdrawn() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Id contactId = ContactsDAO.newInstance().getPersonContactsWithLimit(1).iterator().next()?.Id;                
            List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance().getApplicationsByContactIds(new Set<Id>{contactId},'USER_MODE');   
            
            for(hed__Application__c app: existingApplicationList){                           
                app.Application_Status__c = 'Withdrawn';  
            }
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .updateRecords(
                    existingApplicationList,
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }    
    
    private static List<hed__Application__c> createTestApplicationRecords(List<Contact> conList, String applicationStatus,String recordType) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = 'Test First' + FIRSTNAME,
                    LastName__c = 'Test Last' + LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'workTest' + EMAIL,
                    Application_Status__c = applicationStatus,
                    hed__Applicant__c = con.Id,
                    RecordTypeId = recordType
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
                    BirthDate = Date.valueOf(BIRTHDAY),
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
}