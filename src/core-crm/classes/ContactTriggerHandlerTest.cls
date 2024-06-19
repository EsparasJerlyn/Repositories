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
     | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added createMarketingSegmentationTest|
     | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variables     |
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
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
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
            contactList[0].FirstName = 'Test Contact For Explore';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;           
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
        }

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0]
                .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            insert contacts;
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            insert acc;
        }
    }
    
    @isTest
    private static void insertContactImageSuccessTest() {
        User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        
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
        User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
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
        User currUsr =TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        System.runAs(currUsr) {
            Contact con = [
                SELECT Id, Contact_Image__c
                FROM Contact
                WHERE CreatedById = :currUsr.Id
                LIMIT 1
            ];
            System.assert(con != null, 'Query returns no Contact record.');

            con.Contact_Image__c = null;
            Test.startTest();
            update con;
            Test.stopTest();
            
            List<ContentDocument> conContentDocuLink = [
                SELECT Id
                FROM ContentDocument
                WHERE Title = 'ContactImage.jpg'
            ];
            
            System.assert(
                conContentDocuLink.isEmpty(),
                'Contact Image File is not deleted'
            );
        }
    }
    
    @isTest
    private static void updateContactImageErrorTest() {
        User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;

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
        User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        
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
        User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
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
        User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        
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
            User currUsr = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
        List<PermissionSet> permsets = new List<PermissionSet>();
        if(Schema.sObjectType.PermissionSet.isAccessible()){
            permsets = [SELECT Id FROM PermissionSet WHERE Label = 'Corporate Partner' LIMIT 1];
        }

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
        Contact mcContact = [SELECT Id, Owner.Name FROM Contact WHERE RecordTypeId =: MC_PERSONA LIMIT 1];
        System.assertEquals(u.Contact.hed__Primary_Organization__r.OwnerId, actualContact.OwnerId, 'Should set the contact owner when the current user is having profile of corporate partner.');
        System.assertEquals(mcContact.Owner.Name,'Sys Admin Integration User', 'mc persona contacts should be owned by sys admin integration user');
    }

    /**
     * @Description Should not set the contact owner when the current user is not having UserType of PowerPartner
     */
    @IsTest
    private static void shouldNotSetContactOwner() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Contact c = new Contact(LastName = 'UnitTest');

            // Test
            User testUser = [Select Id from User where id = :UserInfo.getUserId()];
            Test.StartTest();
            insert c;
            Test.StopTest();

        // Verify
        Contact actualContact = [Select id, OwnerId from Contact where id = :c.id];
        System.assertEquals(testUser.Id, actualContact.OwnerId, 'Should not set the contact owner when the current user is not having profile of corporate partner.');
    }
  }

  @IsTest
    private static void shouldSetStatustoExplore() {
   
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(10);
            List<Contact> contactListToUpdate = new List<Contact>();
            for (Contact record : contactList) { 
                if(record.FirstName == 'Test Contact For Explore') {
                    record.HasOptedOutOfEmail = true;
                    contactListToUpdate.add(record);
                }
            }
            ContactsDAO.newInstance().updateRecords(contactListToUpdate, false, AccessLevel.SYSTEM_MODE);
            
            List<Contact> contactListToUpdate2 = new List<Contact>();

            for (Contact record : contactListToUpdate) { 
                if(record.FirstName == 'Test Contact For Explore') {
                    record.HasOptedOutOfEmail = false;
                    record.Email_Opt_In_DateTime__c = Date.today();
                    contactListToUpdate2.add(record);
                }
            }
            MarketingConsentHelper.runSetOptOutAndInDates.clear();
            ContactsDAO.newInstance().updateRecords(contactListToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            for (Contact record : ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{contactListToUpdate[0].Id},AccessLevel.SYSTEM_MODE)) {  
                System.assertEquals(10,record.Lead_Score__c,'Contact Lead_Score__c did not match');
                System.assertEquals('Explore',record.Future_Student_Journey_Status__c,'Contact Future_Student_Journey_Status__c did not match');
            }
        }
    }

    private static void shouldSetStatustoNotExplore() {
   
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;           
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE); 

            Lead_Score_Detail__c lcd = new Lead_Score_Detail__c();
            lcd.Total_Lead_Score__c = -50;
            insert lcd;

            for (Contact record : newContacts) {  
                record.Lead_Score_Detail__c = lcd.Id;
            }

            ContactsDAO.newInstance().updateRecords(newContacts, false, AccessLevel.SYSTEM_MODE); 

            for (Contact record : ContactsDAO.newInstance().getPersonContactsWithLimit(10)) {  
                System.assert(String.isBlank(record.Future_Student_Journey_Status__c),'Contact Future_Student_Journey_Status__c did not match');
            }
        }
    }
    
    @isTest
    private static void createMarketingSegmentationTest() {        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            for(Integer i=0; i < 10; i++){
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].email = i + 'test@email.com'; 
                contacts[i].Work_Email__c =  i + 'test@workemail.com';
            }
            Database.SaveResult[] srList = ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.USER_MODE);
            Test.stopTest();
            Set<Id> contactIds = new Set<Id>();            
            for (Database.SaveResult sr : srList) {
                contactIds.add(sr.getId());
            }
            List<Marketing_Segmentation__c> marketingSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactIds(contactIds, AccessLevel.USER_MODE);
            
            for(Marketing_Segmentation__c marketingSeg : marketingSegList){
                System.assert(marketingSeg.Contact__c != null, 'No Marketing Segmentation record created for the contact');
            }
        }
    }

    @isTest
    private static void processSystemKeyChangeOnContactTriggerInsert() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactRecords = TestDataFactory.createTestContactRecords(100);
            Integer count = 0;
            Set<String> systemKeyIds = new Set<String>();
            for (Contact con : contactRecords) {
                con.QUT_Employee_ID__c = '01' + count++;
                con.QUT_Student_ID__c = 'O2' + count++;
                systemKeyIds.add(con.QUT_Employee_ID__c);
                systemKeyIds.add(con.QUT_Student_ID__c);
            }
            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assertEquals(
                200,
                ContactAlternateIdsDAO.newInstance()
                    .getContactAlternateIdsBySystemKeyIdSet(systemKeyIds, AccessLevel.USER_MODE)
                    .size(),
                'There should be 200 alternate ids created'
            );
        }
    }

    @isTest
    private static void processSystemKeyChangeOnContactTriggerUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactRecords = TestDataFactory.createTestContactRecords(100);
            Integer count = 0;
            Set<String> systemKeyIdsOnInsert = new Set<String>();
            Set<String> systemKeyIdsOnUpdate = new Set<String>();
            Set<String> allSystemKeyIds = new Set<String>();

            for (Contact con : contactRecords) {
                con.QUT_Employee_ID__c = '01' + count++;
                con.QUT_Student_ID__c = 'O2' + count++;
                systemKeyIdsOnInsert.add(con.QUT_Employee_ID__c);
                systemKeyIdsOnInsert.add(con.QUT_Student_ID__c);
            }

            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assertEquals(
                200,
                ContactAlternateIdsDAO.newInstance()
                    .getContactAlternateIdsBySystemKeyIdSet(
                        systemKeyIdsOnInsert,
                        AccessLevel.USER_MODE
                    )
                    .size(),
                'There should be 200 active alternate ids created'
            );

            for (Contact con : contactRecords) {
                con.QUT_Employee_ID__c = '03' + count++;
                con.QUT_Student_ID__c = 'O4' + count++;
                systemKeyIdsOnUpdate.add(con.QUT_Employee_ID__c);
                systemKeyIdsOnUpdate.add(con.QUT_Student_ID__c);
            }

            ContactsDAO.newInstance().updateRecords(contactRecords, true, AccessLevel.USER_MODE);
            allSystemKeyIds.addAll(systemKeyIdsOnInsert);
            allSystemKeyIds.addAll(systemKeyIdsOnUpdate);

            List<Contact_Alternate_ID__c> conAltIds = ContactAlternateIdsDAO.newInstance()
                .getContactAlternateIdsBySystemKeyIdSet(allSystemKeyIds, AccessLevel.USER_MODE);

            System.assertEquals(
                200,
                conAltIds.size(),
                'There should be 200 alternate active alternate ids created'
            );

            for (Contact_Alternate_ID__c conAltId : conAltIds) {
                System.assert(
                    systemKeyIdsOnUpdate.contains(conAltId.Contact_Alternate_Id__c),
                    'Contact alternate id should exist in the set of contact alternate ids on update'
                );
            }
        }
    }
} 