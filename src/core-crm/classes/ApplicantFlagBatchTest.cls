/**
 * @description Test Class of ApplicantFlagBatch
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Created file                 |
 */
@isTest
public with sharing class ApplicantFlagBatchTest {


    @testSetup
    static void setupMethod() {
        Test.startTest();
            TestDataFactory.generateTestUsers();
        Test.stopTest();
    }

    @isTest
    private static void runApplicantFlagBatchTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = new List<Contact>();
            newContacts.add(
                new Contact(
                    FirstName = 'Test FirstName1',
                    LastName =  '1LastName',
                    BirthDate = Date.valueOf('2000-06-28'),
                    Email = '1email@test.com',
                    QUT_Learner_Email__c = 'learner1email@test.com' ,
                    QUT_Staff_Email__c = 'staff1email@test.com',
                    Work_Email__c = 'work1email@test.com',
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = '1email@test.com',
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationRecords(newContacts,'Existing',ApplicationsDAO.QTAC_RECTYPE_ID),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            List<Contact> updateContacts = new List<Contact>();
            for(Contact con : newContacts){
                con.QUT_Applicant__c = true;
                updateContacts.add(con);
            }
            update updateContacts;
        }
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            Test.startTest();
                ApplicantFlagBatch batch = new ApplicantFlagBatch();
                Database.executeBatch(batch);
                System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'ApplicantFlagBatch'].isEmpty() , 'ApplicantFlagBatch Job was not executed');
            Test.stopTest();
            System.assert(![SELECT Id FROM Contact WHERE Email = '1email@test.com' AND QUT_Applicant__c = false ].isEmpty() , 'Contact Applicant Flag was not updated');
        }
    }

    private static List<hed__Application__c> createTestApplicationRecords(List<Contact> conList, String applicationStatus,String recordType) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = 'Test First' +con.FirstName,
                    LastName__c = 'Test Last' +con.LastName,
                    BirthDate__c = Date.valueOf('2000-06-28'),
                    Email__c = 'workTest'+con.Email,
                    Is_Active__c = true,
                    hed__Applicant__c = con.Id,
                    Calculated_Intake_Date__c = Date.today().addDays(-1),
                    RecordTypeId = recordType
                )
            );
        }
        return newApplications;
    }
}