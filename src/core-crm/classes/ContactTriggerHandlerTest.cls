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
 */
@isTest(SeeAllData=false)
public with sharing class ContactTriggerHandlerTest {
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
            cons[0].hed__WorkEmail__c = 'test_work@email.com';
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
}