/**
 * @description Test Class for ContactWithMatchingLeadHelper
 * @see ..ContactWithMatchingLeadHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | June 1, 2022          | DEPP-2281              | creates test class           |
      | eccarius.munoz                 | June 28, 2022         | DEPP-3235              | Sets test records to 100     |
      | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Updated test class reference |
 */
@isTest
public with sharing class ContactWithMatchingLeadHelperTest {

    public static final Integer NUM_RECORDS = 50;

    public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Person')
        .getRecordTypeId();
    public static final Id MC_PERSONA = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('MC_Persona')
        .getRecordTypeId();


    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            makeData(NUM_RECORDS);
        }
        
    }

    private static void makeData(Integer recNum){

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

        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < recNum; i++){
            leads.add(new Lead(
                FirstName = 'Test' + i,
                LastName = 'Record' + i,
                Company = 'TestCompany',
                Phone = '012345678',
                Street = 'TestStreet',
                State = 'TestState',
                City = 'TestCity',
                Country = 'Japan',
                PostalCode = '4102',
                Email = 'test@record.com' + i,
                Work_Email__c = 'test@record.comw' + i,
                MobilePhone = '012345678',
                Personal_Mobile__c = '012345678',
                Company_Category__c = 'Corporate',
                ABN__c = '000',
                LeadABNEntity_Validation__c = 'Valid',
                LeadAddress_Validation__c = 'Valid',
                LeadMobile_Validation__c = 'Valid',
                Mobile_No_Locale__c = '012345678',
                LeadPersonalMobile_Validation__c = 'Valid',
                LeadPhone_Validation__c = 'Valid',
                LinkedIn_Profile_URL__c = 'test@record.com',
                WorkPhone_Validation__c = 'Valid',
                Phone_No_Locale__c  = '012345678',
                Lead_Type__c = 'Learner'
            ));
        }
        insert leads;

        List<Marketing_Interaction__c> marketingInteractionList = new List<Marketing_Interaction__c>();
        List<Marketing_Course_Application__c> marketingCourseAppList = new List<Marketing_Course_Application__c>();
        List<hed__Application__c> appList = new List<hed__Application__c>();
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < recNum; i++){
            marketingInteractionList.add(new Marketing_Interaction__c(Lead__c = leads[i].Id));
            marketingCourseAppList.add(new Marketing_Course_Application__c(Lead__c = leads[i].Id));
            appList.add(new hed__Application__c(Lead__c = leads[i].Id));
            contactList.add(new Contact(FirstName = 'MC Test', LastName = 'MC Record', Email = 'mctest@record.com', Company_Name__c = 'mcTestCompany', RecordTypeId = MC_PERSONA, Parent_Person_Lead__c = leads[i].Id));
        }
        insert marketingInteractionList;
        insert marketingCourseAppList;
        ApplicationsDAO.newInstance().insertRecords(appList, false, AccessLevel.SYSTEM_MODE);
        insert contactList;
    }

    @isTest
    static void detectLeadDuplicatesAndConvertTest(){
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
        
            List<Lead> leadList = [SELECT Id FROM Lead WHERE Lead_Type__c = 'Learner'];

            List<Contact> contacts = new List<Contact>();
            for(Integer i = 0; i < NUM_RECORDS; i++){
                contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Record' + i,
                    Email = 'test@record.com' + i,
                    Company_Name__c = 'TestCompany',
                    RecordTypeId = PERSON)
                );
            }

            insert contacts;

            Map<Id,Contact> contactsMap = new Map<Id,Contact>();
            List<Contact> contactList = [SELECT Id, Email, Work_Email__c, AccountId, Parent_Person_Contact__r.Id, Parent_Person_Contact__r.Email, Parent_Person_Contact__r.Work_Email__c, Parent_Person_Contact__r.AccountId FROM Contact WHERE RecordTypeId =: PERSON];
            for(Contact con : contactList){
                contactsMap.put(con.Id, con);
            }

            Set<Id> leadIds = new Set<Id>();
            for(Lead lead : leadList){
                leadIds.add(lead.Id);
            }

            Test.stopTest();

            List<Marketing_Interaction__c> mktInteractionContacts = [SELECT Contact__r.Id FROM Marketing_Interaction__c WHERE Lead__c IN : leadIds];
            List<Marketing_Course_Application__c> mktCourseAppContacts = [SELECT Contact__r.Id FROM Marketing_Course_Application__c WHERE Lead__c IN : leadIds];
            List<hed__Application__c> appContacts = ApplicationsDAO.newInstance().getApplicationsByLeadIds(leadIds,'SYSTEM_MODE'); 
            List<Marketing_Segmentation__c> mktSegContacts = [SELECT Contact__r.Id FROM Marketing_Segmentation__c WHERE Contact__c IN : contactsMap.keySet()];
            List<Contact> mcContacts = [SELECT Parent_Person_Contact__c FROM Contact WHERE Parent_Person_Lead__c IN : leadIds];

            

            for(Marketing_Interaction__c mi : mktInteractionContacts){
                System.assert(contactsMap.containsKey(mi.Contact__r.Id), 'Marketing Interaction was not updated.');
            }
            for(Marketing_Course_Application__c mca : mktCourseAppContacts){
                System.assert(contactsMap.containsKey(mca.Contact__r.Id), 'Marketing Course Application was not updated.');
            }
            for(hed__Application__c app : appContacts){
                System.assert(contactsMap.containsKey(app.hed__Applicant__c), 'Application was not updated.');
            }
            for(Marketing_Segmentation__c ms : mktSegContacts){
                System.assert(contactsMap.containsKey(ms.Contact__r.Id), 'Marketing Segmentation was not updated.');
            }
            for(Contact c : mcContacts){
                System.assert(contactsMap.containsKey(c.Parent_Person_Contact__c), 'MC Persona was not updated.');
            }   
        }
    }

    @isTest
    static void detectLeadDuplicatesAndConvertWorkEmailMatchTest(){
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();

            List<Lead> leadList = [SELECT Id, Email, Work_Email__c FROM Lead WHERE Lead_Type__c = 'Learner'];

            List<Contact> contacts = new List<Contact>();
            for(Integer i = 0; i < NUM_RECORDS; i++){
                contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Record' + i,
                    Email = 'test@record.comw' + i,
                    Company_Name__c = 'TestCompany',
                    RecordTypeId = PERSON)
                );
            }
            insert contacts;

            Map<Id,Contact> contactsMap = new Map<Id,Contact>();
            List<Contact> contactList = [SELECT Id, Email, Work_Email__c, AccountId, Parent_Person_Contact__r.Id, Parent_Person_Contact__r.Email, Parent_Person_Contact__r.Work_Email__c, Parent_Person_Contact__r.AccountId FROM Contact WHERE RecordTypeId =: PERSON];
            for(Contact con : contactList){
                contactsMap.put(con.Id, con);
            }

            Set<Id> leadIds = new Set<Id>();
            for(Lead lead : leadList){
                leadIds.add(lead.Id);
            }
            Test.stopTest();

            List<Marketing_Interaction__c> mktInteractionContacts = [SELECT Contact__r.Id FROM Marketing_Interaction__c WHERE Lead__c IN : leadIds];
            List<Marketing_Course_Application__c> mktCourseAppContacts = [SELECT Contact__r.Id FROM Marketing_Course_Application__c WHERE Lead__c IN : leadIds];
            List<hed__Application__c> appContacts = ApplicationsDAO.newInstance().getApplicationsByLeadIds(leadIds,'SYSTEM_MODE'); 
            List<Marketing_Segmentation__c> mktSegContacts = [SELECT Contact__r.Id FROM Marketing_Segmentation__c WHERE Contact__c IN : contactsMap.keySet()];
            List<Contact> mcContacts = [SELECT Parent_Person_Contact__c FROM Contact WHERE Parent_Person_Lead__c IN : leadIds];

            for(Marketing_Interaction__c mi : mktInteractionContacts){
                System.assert(contactsMap.containsKey(mi.Contact__r.Id), 'Marketing Interaction was not updated.');
            }
            for(Marketing_Course_Application__c mca : mktCourseAppContacts){
                System.assert(contactsMap.containsKey(mca.Contact__r.Id), 'Marketing Course Application was not updated.');
            }
            for(hed__Application__c app : appContacts){
                System.assert(contactsMap.containsKey(app.hed__Applicant__c), 'Application was not updated.');
            }
            for(Marketing_Segmentation__c ms : mktSegContacts){
                System.assert(contactsMap.containsKey(ms.Contact__r.Id), 'Marketing Segmentation was not updated.');
            }
            for(Contact c : mcContacts){
                System.assert(contactsMap.containsKey(c.Parent_Person_Contact__c), 'MC Persona was not updated.');
            }
        }
    }

    @isTest
    static void updateSingleContactWithMarketingSegTest(){
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();

            Contact contactWithMarketingSeg = new Contact(
                FirstName = 'Test',
                LastName = 'MS Record',
                Email = 'temptest@record.com',
                Company_Name__c = 'TestCompany',
                RecordTypeId = PERSON);
            insert contactWithMarketingSeg;

            Lead lead = new Lead(
                FirstName = 'Test',
                LastName = 'Record',
                Company = 'TestCompany',
                Email = 'test@record.com',
                Work_Email__c = 'test@record.comw',
                MobilePhone = '012345678',
                Company_Category__c = 'Corporate',
                Lead_Type__c = 'Learner'
            );
            insert lead;

            Map<Id,Contact> contactsMap = new Map<Id,Contact>();
            List<Contact> contactList = [SELECT Id, Email, Work_Email__c, AccountId, Parent_Person_Contact__r.Id, Parent_Person_Contact__r.Email, Parent_Person_Contact__r.Work_Email__c, Parent_Person_Contact__r.AccountId FROM Contact WHERE LastName = 'MS Record' AND RecordTypeId =: PERSON];
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Contact contact : contactList){
                contact.Email = 'test@record.com';
                contactsToUpdate.add(contact);
            }
            update contactsToUpdate;
            for(Contact con : contactsToUpdate){
                contactsMap.put(con.Id, con);
            }

            ContactWithMatchingLeadHelper.detectLeadDuplicates(contactsMap);

            List<Marketing_Segmentation__c> mktSegContacts = [SELECT Contact__r.Id FROM Marketing_Segmentation__c WHERE Contact__c IN : contactsMap.keySet()];
            
            Test.stopTest();

            for(Marketing_Segmentation__c ms : mktSegContacts){
                System.assert(contactsMap.containsKey(ms.Contact__r.Id), 'Marketing Segmentation was not updated.');
            }
      }
    }
    
}