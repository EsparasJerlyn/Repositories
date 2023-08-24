/**
 * @description Test Class for FutureStudentJourneyStatusHelper
 *
 * @see FutureStudentJourneyStatusHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | Aug 22,2023           | DEPP-5704    | Created file                                |
*/
@isTest
private class FutureStudentJourneyStatusHelperTest {
     
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });

        System.runAs(TestDataFactory.getESBIntegrationUser()){
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void testContactCreationWithExploreStatus() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);    
            for(Contact con: newContacts){
                con.Future_Student_Journey_Status__c = '';
            }        
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(10)){
                System.assert(record.Future_Student_Journey_Status__c == 'Explore','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }


    @isTest
    private static void testContactCreationWithNoStatus() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0,10);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(10)){
                System.assert(String.isBlank(record.Future_Student_Journey_Status__c),'Record Future_Student_Journey_Status__c did not match');
            }
        }
    }


    @isTest
    private static void testContactCreationWithStudyStatus() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0,10);   
            for(Contact con: newContacts){
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(10)){
                System.assert(record.Future_Student_Journey_Status__c == 'Study','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationBlankWithApplication() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Calculated_Intake_Date__c = null;
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(String.isBlank(record.Future_Student_Journey_Status__c),'Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationApplyStudyLink() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Application_Status__c = 'Apply';
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Apply','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationApplySAMS() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Application_Status__c = 'Apply';
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Apply','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationApplyQTAC() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            List<Account> accountList = AccountsDAO.newInstance()
            .getAccountsBySetNames(new Set<String>{'Test Account'});

            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID));
            
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );

            TermsDAO.newInstance().insertRecords(new List<hed__Term__c>{appliedIntakeTerm},false,AccessLevel.USER_MODE);

            for(hed__Application__c app: newApplications){
                app.Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Apply','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationOfferStudyLink() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Application_Status__c = 'Conditional Offer';
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Offer','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationOfferSAMS() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Application_Status__c = 'Offered';
                app.Offer_Status__c  = 'Offered';
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Offer','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationOfferQTAC() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            List<Account> accountList = AccountsDAO.newInstance()
            .getAccountsBySetNames(new Set<String>{'Test Account'});

            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID));
            
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );

            TermsDAO.newInstance().insertRecords(new List<hed__Term__c>{appliedIntakeTerm},false,AccessLevel.USER_MODE);

            for(hed__Application__c app: newApplications){
                app.Offer_Status__c = 'Deferment granted, wants considered higher prefs';
                app.Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Offer','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationAcceptAdmitStudyLink() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.STUDYLINK_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Application_Status__c = 'Acceptance - No Payment Required';
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Accept-Admit','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }


    @isTest
    private static void testApplicationAcceptAdmitSAMS() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Application_Status__c = 'Offered';
                app.Offer_Status__c  = 'Accepted';
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Accept-Admit','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationAcceptAdmitQTAC() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            List<Account> accountList = AccountsDAO.newInstance()
            .getAccountsBySetNames(new Set<String>{'Test Account'});

            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID));
            
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );

            TermsDAO.newInstance().insertRecords(new List<hed__Term__c>{appliedIntakeTerm},false,AccessLevel.USER_MODE);

            for(hed__Application__c app: newApplications){
                app.Offer_Status__c = 'Accepted unconditionally';
                app.Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Accept-Admit','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    
}