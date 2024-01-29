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
      | roy.nino.s.regala         | Oct 10,2023           | DEPP-5866    | Updated lead score logic                    |
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

            List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
            leadScoreParentConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Total Max Score DUG',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined'
                )
            );

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing Consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 20,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
            leadScoreConfigChildList.addAll(TestDataFactory.createUndAndUndeterminedSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Yes',
                    'Is blank'
                },
                new List<Integer>{10,10}
            ));

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);  
            contactList[0].FirstName = 'Test Contact For Nurture';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;           
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void testContactCreationWithExploreStatus() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(10);
            List<Contact> contactListToUpdate = new List<Contact>();
            for (Contact record : contactList) { 
                if(record.FirstName == 'Test Contact For Nurture') {
                    record.Email_Opt_In_DateTime__c = Date.today();
                    contactListToUpdate.add(record);
                }
            }
            ContactsDAO.newInstance().updateRecords(contactListToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            for (Contact record : ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{contactListToUpdate[0].Id},AccessLevel.SYSTEM_MODE)) {  
                System.assertEquals(10,record.Lead_Score__c,'Contact Lead_Score__c did not match');
                System.assertEquals('Explore',record.Future_Student_Journey_Status__c,'Contact Future_Student_Journey_Status__c did not match');
            }
        }
    }


    @isTest
    private static void testContactCreationWithNoStatus() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0,10);   
            for(Contact record : newContacts){
                record.FirstName = 'Contact with No Status';
            }
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(10)){
                if(record.FirstName == 'Contact with No Status'){
                    System.assert(String.isBlank(record.Future_Student_Journey_Status__c),'Record Future_Student_Journey_Status__c did not match');
                }
            }
        }
    }


    @isTest
    private static void testContactCreationWithStudyStatus() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0,10);  
            Set<Id> contactIds = new Set<Id>(); 
            for(Contact con: newContacts){
                contactIds.add(con.Id);
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(contactIds, AccessLevel.SYSTEM_MODE)){
                System.assert(record.Future_Student_Journey_Status__c == 'Study','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testApplicationBlankWithApplication() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);  
            newContacts[0].HasOptedOutOfEmail = true;          
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //create 2 application to pass thre logic where status is not overwritten when same status would be set
            List<hed__Application__c> newApplications = TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID);
            newApplications.addAll(TestDataFactory.createTestApplicationRecordsWithContact(newContacts,ApplicationsDAO.QTAC_RECTYPE_ID));
            
            for(hed__Application__c app: newApplications){
                app.Calculated_Intake_Date__c = null;
                app.Is_Active__c = false;
            }

            Test.startTest();
            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);
            Test.stopTest();
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
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
           
            for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{newContacts[0].Id}, AccessLevel.SYSTEM_MODE)){
                System.assert(record.Future_Student_Journey_Status__c == 'Accept-Admit','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }

    
}