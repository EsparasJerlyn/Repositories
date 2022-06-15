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
 */
@isTest(SeeAllData=false)
public with sharing class ContactTriggerHandlerTest {
private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Person')
        .getRecordTypeId();
    public static final Id MC_PERSONA = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('MC_Persona')
        .getRecordTypeId();

  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @TestSetup
  static void testSetup() {
    System.runAs(currentUser) {
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

  @IsTest
  private static void insertContactImageSuccessTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

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

  @IsTest
  private static void insertContactImageErrorTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

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

  @IsTest
  private static void updateContactImageSuccessTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

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

  @IsTest
  private static void updateContactImageErrorTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

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
        User currUsr = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
            LIMIT 1
        ];

        List<Contact> cons = TestDataFactory.createTestContactRecords(1);

        System.runAs(currUsr) {
            Test.startTest();
            cons[0].FirstName = 'Contact FN 4';
            cons[0].LastName = 'Contact LN 4';
            cons[0].Email = 'test@email.com';
            cons[0].Work_Email__c = 'test_work@email.com';
            cons[0].QUT_Staff_Email__c = 'test_staff@email.com';
            cons[0].QUT_Learner_Email__c = 'test_learner@email.com';
            cons[0].hed__Preferred_Email__c = 'Work Email';
            insert cons;
            Test.stopTest();
        }

        System.assertEquals(
                3,
                [Select Id from Contact Where Parent_Person_Contact__c = :cons[0].Id].size(),
                'Number of child MC Persona contacts'
            );
    }

    @IsTest
    private static void insertContactTest(){
      User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];
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

    @IsTest
    private static void insertContactWithPrimaryBusinesssOrgTest(){
      User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

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

  /* @IsTest
  private static void contactDuplicatesExactMatchTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      List<Contact> testContacts = new List<Contact>();
      Contact testContact1 = TestDataFactory.createTestContactRecords(1).iterator().next();
      testContact1.Birthdate = Date.newInstance(1999, 1, 1);
      testContact1.Email = emailTest;
      testContact1.LastName = 'User';
      testContact1.RecordTypeId = PERSON;
      testContacts.add(testContact1);

      Contact testContact2 = TestDataFactory.createTestContactRecords(1).iterator().next();
      testContact2.Birthdate = Date.newInstance(1999, 1, 1);
      testContact2.LastName = 'User';
      testContact2.RecordTypeId = PERSON;
      testContacts.add(testContact2);

      insert testContacts;

      testContact2.Email = emailTest;
      update testContact2;

      Contact testContact3 = TestDataFactory.createTestContactRecords(1).iterator().next();
      testContact3.Birthdate = Date.newInstance(1999, 1, 1);
      testContact3.Email = emailTest;
      testContact3.LastName = 'User';
      testContact3.RecordTypeId = PERSON;

      Test.startTest();
      insert testContact3;
      Test.stopTest();

      System.assertEquals(
        2,
        [
          SELECT count()
          FROM Potential_Duplicate__c
          WHERE Contact__c IN : testContacts
        ],
        'There should be 2 potential duplicates created'
      );
    }
  }

  @IsTest
  private static void contactDuplicatesPartialMatchTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      Contact testContact1 = TestDataFactory.createTestContactRecords(1).iterator().next();
      testContact1.Birthdate = Date.newInstance(1999, 1, 1);
      testContact1.Email = emailTest;
      testContact1.LastName = 'User';
      testContact1.QUT_Employee_ID__c = '123';
      insert testContact1;

      Contact testContact2 = TestDataFactory.createTestContactRecords(1).iterator().next();
      testContact2.Email = emailTest;
      testContact2.LastName = 'UserNotMatch';
      testContact2.QUT_Employee_ID__c = '123';

      Test.startTest();
      insert testContact2;
      Test.stopTest();

      System.assertEquals(
        1,
        [
          SELECT count()
          FROM Potential_Duplicate__c
          WHERE Contact__c = : testContact1.Id
        ],
        'There should be 1 potential duplicate created'
      );
    }
  } */


  @IsTest
  static void detectLeadDuplicatesTest(){
    List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
    insert accounts;

    List<Lead> leads = new List<Lead>();
    leads.add(new Lead(
      FirstName = 'Test',
      LastName = 'Record',
      Company = 'TestCompany',
      Phone = '012345678',
      Street = 'TestStreet',
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
    marketingInteractionList.add(new Marketing_Interaction__c(Lead__c = leads[0].Id));
    marketingCourseAppList.add(new Marketing_Course_Application__c(Lead__c = leads[0].Id));
    marketingSegmentationList.add(new Marketing_Segmentation__c(Lead__c = leads[0].Id));
    insert marketingInteractionList;
    insert marketingCourseAppList;
    insert marketingSegmentationList;

    Test.startTest();
    List<Contact> contacts = new List<Contact>();
    contacts.add(new Contact(FirstName = 'Test', LastName = 'Record', Email = 'test@record.com', Company_Name__c = 'TestCompany', RecordTypeId = PERSON));
    insert contacts;

    String contactId = contacts[0].Id;
    List<Marketing_Interaction__c> marketingInts = [SELECT Id, Contact__c, Lead__c FROM Marketing_Interaction__c];
    String mktInteractionContact = [SELECT Contact__r.Id FROM Marketing_Interaction__c WHERE Lead__c =: leads[0].Id LIMIT 1].Contact__r.Id;
    String mktCourseAppContact = [SELECT Contact__r.Id FROM Marketing_Course_Application__c WHERE Lead__c =: leads[0].Id LIMIT 1].Contact__r.Id;
    String mktSegContact = [SELECT Contact__r.Id FROM Marketing_Segmentation__c WHERE Contact__c =: contactId LIMIT 1].Contact__r.Id;

    Test.stopTest();

    System.assertEquals(contactId, mktInteractionContact, 'Marketing Interaction was not updated.');
    System.assertEquals(contactId, mktCourseAppContact, 'Marketing Course Application was not updated.');
    System.assertEquals(contactId, mktSegContact, 'Marketing Segmentation was not updated.');

  }
}