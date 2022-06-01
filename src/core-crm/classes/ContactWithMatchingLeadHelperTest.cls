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
 */
@isTest(SeeAllData=false)
public with sharing class ContactWithMatchingLeadHelperTest {

    public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Person')
        .getRecordTypeId();
    public static final Id MC_PERSONA = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('MC_Persona')
        .getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);  
        insert accounts;
                
        List<Lead> leads = new List<Lead>();
            leads.add(new Lead(
            FirstName = 'Test',
            LastName = 'Record',
            Company = 'TestCompany',
            Phone = '012345678',
            Street = 'TestStreet',
            State = 'TestState',
            City = 'TestCity',
            Country = 'Japan',
            PostalCode = '4102',
            Email = 'test@record.com',
            Personal_Email__c = 'test@record.com',
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
        insert leads;

        List<Marketing_Interaction__c> marketingInteractionList = new List<Marketing_Interaction__c>();
        List<Marketing_Course_Application__c> marketingCourseAppList = new List<Marketing_Course_Application__c>();
        List<Marketing_Segmentation__c> marketingSegmentationList = new List<Marketing_Segmentation__c>();
        List<Contact> contactList = new List<Contact>();
        marketingInteractionList.add(new Marketing_Interaction__c(Lead__c = leads[0].Id));
        marketingCourseAppList.add(new Marketing_Course_Application__c(Lead__c = leads[0].Id));
        marketingSegmentationList.add(new Marketing_Segmentation__c(Lead__c = leads[0].Id));
        contactList.add(new Contact(FirstName = 'MC Test', LastName = 'MC Record', Email = 'mctest@record.com', Company_Name__c = 'mcTestCompany', RecordTypeId = MC_PERSONA, Parent_Person_Lead__c = leads[0].Id));
        insert marketingInteractionList;
        insert marketingCourseAppList;
        insert marketingSegmentationList; 
        insert contactList;
    }

    @IsTest
    static void detectLeadDuplicatesAndConvertTest(){

        List<Lead> leadList = [SELECT Id FROM Lead WHERE Lead_Type__c = 'Learner' LIMIT 1];

        Test.startTest();
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Record', Email = 'test@record.com', Company_Name__c = 'TestCompany', RecordTypeId = PERSON));
        insert contacts;

        String contactId = contacts[0].Id;

        Map<Id,Contact> contactsMap = new Map<Id,Contact>();
        contactsMap.put(contactId, contacts[0]);
        ContactWithMatchingLeadHelper.detectLeadDuplicates(contactsMap);
        
        String mktInteractionContact = [SELECT Contact__r.Id FROM Marketing_Interaction__c WHERE Lead__c =: leadList[0].Id LIMIT 1].Contact__r.Id;
        String mktCourseAppContact = [SELECT Contact__r.Id FROM Marketing_Course_Application__c WHERE Lead__c =: leadList[0].Id LIMIT 1].Contact__r.Id;
        String mktSegContact = [SELECT Contact__r.Id FROM Marketing_Segmentation__c WHERE Contact__c =: contactId LIMIT 1].Contact__r.Id;
        String mcContact = [SELECT Parent_Person_Contact__c FROM Contact WHERE Parent_Person_Lead__c =: leadList[0].Id LIMIT 1].Parent_Person_Contact__c;
        
        Test.stopTest();

        System.assertEquals(contactId, mktInteractionContact, 'Marketing Interaction was not updated.');
        System.assertEquals(contactId, mktCourseAppContact, 'Marketing Course Application was not updated.');
        System.assertEquals(contactId, mktSegContact, 'Marketing Segmentation was not updated.');
        System.assertEquals(contactId, mcContact, 'MC Persona was not updated.');
    }
        
}
    

