/**
* @description Test Class for ContactTriggerHandler
* @see ..ContactTriggerHandler
*
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                   | Change Summary               |
     |--------------------------------|-----------------------|------------------------|------------------------------|
     | john.bo.a.pineda               | April 25, 2022        | DEPP-1211              | Created file                 |
     | Ana                            | 29/4/22               | DEPP-2361              | Create child MC Persona      |
     | angelika.j.s.galang            | May 27, 2022          | DEPP-1455              | Added tests for duplicates   |
     | eccarius.munoz                 | May 31, 2022          | DEPP-2281              | detectLeadDuplicatesTest     |
     | alexander.cadalin              | June 22, 2022         | DEPP-3056              | contactDuplicateEmailsTest...|
     |                                | June 24, 2022         | DEPP-3056              | -rem global dupes tests      |
     | eugene.andrew.abuan            | July 01, 2022         | DEPP-3378              | Update logic for             |
     |                                |                       |                        |  sendEmailOnContact          |
     | eugene.andrew.abuan            | July 04, 2022         | DEPP-3387              | Update Email to Registered   |
     |                                |                       |                        | Email in sendEmailOnContact  |
     | alexander.cadalin              | July 30, 2022         | DEPP-3623              | Commented out old dupe checker

*/
@isTest
public with sharing class ContactTriggerHandlerTest {
    private static final String CATEGORY_CCE = 'Corporate Portal';
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Person')
        .getRecordTypeId();
    public static final Id MC_PERSONA = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('MC_Persona')
        .getRecordTypeId();
    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0]
                .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            insert contacts;
            
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            insert acc;
            Test.stopTest();
        }
    }
    
    @isTest
    private static void insertContactImageSuccessTest() {
        User currUsr = TestDataFactory.getProgramAdminUser();
        
        System.runAs(currUsr) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].FirstName = 'Contact FN 2';
            contacts[0].LastName = 'Contact LN 2';
            contacts[0]
                .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_mountains.jpg" alt="test.jpg"></img></p>';
            insert contacts;
            Test.stopTest();
            
            List<ContentDocumentLink> conContentDocuLink = [
                SELECT Id, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :contacts[0].Id
            ];
            
            System.assert(
                contacts[0].Id == conContentDocuLink[0].LinkedEntityId,
                'Contact Image File is created'
            );
        }
    }
    
    @isTest
    private static void insertContactImageErrorTest() {
        User currUsr = TestDataFactory.getProgramAdminUser();
        DmlException expectedException;
        System.runAs(currUsr) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].FirstName = 'Contact FN 3';
            contacts[0].LastName = 'Contact LN 3';
            contacts[0]
                .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img><img src="https://www.w3schools.com/w3css/img_nature.jpg" alt="test.jpg"></img></p>';
            
            try {
                insert contacts;
            } catch (DmlException d) {
                expectedException = d;
            }
            
            Test.stopTest();
            
            System.assertNotEquals(
                null,
                expectedException,
                'The record should be validated'
            );
        }
    }
    
    @isTest
    private static void updateContactImageSuccessTest() {
        User currUsr =TestDataFactory.getProgramAdminUser();
        System.runAs(currUsr) {
            Contact con = [
                SELECT Id, Contact_Image__c
                FROM Contact
                WHERE CreatedById = :currUsr.Id
                LIMIT 1
            ];
            con.Contact_Image__c = null;
            Test.startTest();
            update con;
            Test.stopTest();
            
            List<ContentDocumentLink> conContentDocuLink = [
                SELECT Id, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :con.Id
            ];
            
            System.assert(
                conContentDocuLink.isEmpty(),
                'Contact Image File is deleted'
            );
        }
    }
    
    @isTest
    private static void updateContactImageErrorTest() {
        User currUsr = TestDataFactory.getProgramAdminUser();

        DmlException expectedException;
        System.runAs(currUsr) {
            Contact con = [
                SELECT Id, Contact_Image__c
                FROM Contact
                WHERE CreatedById = :currUsr.Id
                LIMIT 1
            ];
            con.Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img><img src="https://www.w3schools.com/w3css/img_nature.jpg" alt="test.jpg"></img></p>';
            
            Test.startTest();
            
            try {
                update con;
            } catch (DmlException d) {
                expectedException = d;
            }
            
            Test.stopTest();
            
            System.assertNotEquals(
                null,
                expectedException,
                'The record should be validated'
            );
        }
    }
    
    @isTest
    private static void insertContact() {
        User currUsr = TestDataFactory.getProgramAdminUser();
        
        List<Contact> cons = TestDataFactory.createTestContactRecords(1);
        
        System.runAs(currUsr) {
            Test.startTest();
            cons[0].FirstName = 'Contact FN 4';
            cons[0].LastName = 'Contact LN 4';
            cons[0].Email = 'test@email.com';
            cons[0].Work_Email__c = 'test_work@email.com';
            cons[0].QUT_Staff_Email__c = 'test_staff@email.com';
            cons[0].QUT_Learner_Email__c = 'test_learner@email.com';
            cons[0].hed__Preferred_Email__c = 'Alternate Email';
            cons[0].hed__AlternateEmail__c = 'test@email.com';
            insert cons;
            Test.stopTest();
        }
        
        System.assertEquals(
            3,
            [Select Id from Contact Where Parent_Person_Contact__c = :cons[0].Id].size(),
            'Number of child MC Persona contacts'
        );
    }
    
    @isTest
    private static void insertContactTest(){
        User currUsr = TestDataFactory.getProgramAdminUser();
        System.runAs(currUsr){
            Account acc = [SELECT Id From Account WHERE RecordTypeId =: BUSINESS_ACC_RECTYPEID  LIMIT 1];
            
            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for(Contact con : conList){
                con.AccountId = acc?.Id;
            }
            
            Test.startTest();
            insert(conList);
            Test.stopTest();
            
            List<Contact> updatedContactList = new List<Contact>([SELECT Id FROM Contact WHERE hed__Primary_Organization__c != null]);
            System.assert(updatedContactList.size() == 100,'Contacts where not updated');
        }
    }
    
    @isTest
    private static void insertContactWithPrimaryBusinesssOrgTest(){
        User currUsr = TestDataFactory.getProgramAdminUser();
        
        System.runAs(currUsr){
            Account acc = [SELECT Id From Account WHERE RecordTypeId =: BUSINESS_ACC_RECTYPEID  LIMIT 1];
            
            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for(Contact con : conList){
                con.hed__Primary_Organization__c = acc?.Id;
            }
            
            Test.startTest();
            insert(conList);
            Test.stopTest();
            
            List<AccountContactRelation> insertedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN :conList AND AccountId =: acc.Id];
            System.assert(insertedACRList.size() == 100,'Account Contact Relation records created did not match expected');
        }
    }

     @isTest
        private static void sendEmailOnContact() {
            User currUsr = TestDataFactory.getProgramAdminUser();
            System.runAs(currUsr) {
                Set<Id> contactIdSet = new Set<Id>();
                List<Contact> contacts = new List<Contact>();
                contacts.add(new Contact(
                    FirstName = 'Alexa',
                    LastName = 'Ortiga',
                    Email = 'al.ortiga@email.test',
                    Registered_Email__c = 'al.ortiga@email.test',
                    QUT_Identity_ID__c = '12345',
                    QUT_Student_Username__c ='aortiga'
                ));
                insert contacts;

                Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
                insert studyStore;
                List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
                for (Account acc : accounts) {
                  acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                  acc.Organization_Unit_Level__c = '2';
                }
                insert accounts;

                List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100,accounts[0].Id);
                  insert terms;

                List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(100);
                insert prodRequest;

                List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100,accounts[0].Id,prodRequest[0].Id);
                insert courses;

                List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100,courses, terms);
                insert courseOfferings;

                Test.startTest();
                List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100,contacts[0].Id,courseOfferings);
                for (hed__Course_Enrollment__c courseConnection : courseConnections) {
                courseConnection.RecordTypeId = STUDENT_RECTYPEID;
                courseConnection.IsActive__c = TRUE;
                }
                insert courseConnections;


                List<Contact> cont = [SELECT Id, QUT_Student_Username__c FROM Contact WHERE QUT_Student_Username__c ='aortiga'];
                for(Contact c : cont){
                    contactIdSet.add(c.Id);
                }

                String message = ContactUserNameCreatedHelper.sendEmailUsernameCreated(contactIdSet);
                Test.stopTest();

                System.assert(message !=null, 'Email is not Sent to the user');
            }
        }

    /**
     * @Description Should set the contact owner when the current user is having UserType of PowerPartner
     */
    @IsTest
    private static void shouldSetContactOwner() {
        Contact contact = new Contact();
        User commerceUser = new User();
        Test.StartTest();
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Account account = new Account();
            account.Name = 'Test Account';
            account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
            insert account;

            contact.FirstName = 'Test Fname';
            contact.LastName = 'Test Lname';
            contact.email = 'test@email.com';
            contact.Work_Email__c = 'test@workemail.com';
            contact.hed__Preferred_Email__c = 'Alternate Email';
            contact.hed__AlternateEmail__c = 'test@email.com';
            contact.Registered_Email__c = 'test@email.com';
            contact.AccountId = account.Id;
            insert contact;

            BuyerGroup bg = new BuyerGroup();
            bg.Name = 'OPE BuyerGroup';
            insert bg;

            Id corporatePartnerProfileId = [SELECT Id FROM Profile WHERE Name = 'Corporate Partner' Limit 1].Id;

            //create corporate partner user
            commerceUser.IsActive = true;
            commerceUser.Username = contact.Work_Email__c + '.cce';
            commerceUser.Email = contact.Work_Email__c;
            commerceUser.LastName = contact.LastName;
            commerceUser.FirstName = contact.FirstName;
            commerceUser.ContactId = contact.Id;
            commerceUser.alias = contact.FirstName.substring(0, 1) + contact.LastName.substring(0, 2);
            commerceUser.LanguageLocaleKey = 'en_US';
            commerceUser.localesidkey = 'en_AU';
            commerceUser.emailEncodingKey = 'UTF-8';
            commerceUser.timeZoneSidKey = 'Australia/Brisbane';
            commerceUser.profileId = corporatePartnerProfileId;
            insert commerceUser;
            
        }
        Test.StopTest();

        //assign corporate partner permission set
        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        List<PermissionSet> permsets = new List<PermissionSet>();
        if(Schema.sObjectType.PermissionSet.isAccessible()){
            permsets = [SELECT Id FROM PermissionSet WHERE Label = 'Corporate Partner' LIMIT 1];
        }

        List<PermissionSetAssignment> userPermSetAssignments = new List<PermissionSetAssignment>();

    
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                PermissionSetId = permsets[0].Id,
                AssigneeId = commerceUser.Id
        );

            if( Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
                Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable()){
                insert permSetAssignment;
            }
        
        Contact c = new Contact(LastName = 'UnitTest');
        // Test
        
        System.runAs(commerceUser) {
            insert c;
        }

        User u = [SELECT Id,Contact.hed__Primary_Organization__r.OwnerId FROM User WHERE Id =: commerceUser.Id];
        // Verify
        Contact actualContact = [Select id, OwnerId from Contact where id = :c.id];
        System.assertEquals(u.Contact.hed__Primary_Organization__r.OwnerId, actualContact.OwnerId, 'Should set the contact owner when the current user is having UserType of PowerPartner.');
    }

    /**
     * @Description Should not set the contact owner when the current user is not having UserType of PowerPartner
     */
    @IsTest
    private static void shouldNotSetContactOwner() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
        System.runAs(PORTAL_SYS_ADMIN) {
            Contact c = new Contact(LastName = 'UnitTest');

            // Test
            User testUser = [Select Id from User where id = :UserInfo.getUserId()];
            Test.StartTest();
            insert c;
            Test.StopTest();

        // Verify
        Contact actualContact = [Select id, OwnerId from Contact where id = :c.id];
        System.assertEquals(testUser.Id, actualContact.OwnerId, 'Should not set the contact owner when the current user is not having UserType of PowerPartner.');
    }
  }
}
