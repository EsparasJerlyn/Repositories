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
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class ContactTriggerHandlerTest {
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
}