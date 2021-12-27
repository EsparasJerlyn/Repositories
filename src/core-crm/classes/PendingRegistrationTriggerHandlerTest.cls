/**
 * @description Tests Class for PendingRegistrationTrigger
 * @see PendingRegistrationTriggerHandlerTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | johnbo.pineda@qut.edu.au       | December 21, 2021     | DEPP-1150              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class PendingRegistrationTriggerHandlerTest {
  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @isTest
  private static void insertPendingRegistration() {
    System.runAs(currentUser) {
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        10,
        accounts[0].Id
      );
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
        1
      );
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        10,
        accounts[0].Id,
        prodRequest[0].Id
      );
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        10,
        courses,
        terms
      );
      insert courseOfferings;

      List<Pending_Registration__c> pendingRegistrations = TestDataFactory.createTestPendingRegistrationRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );
      insert pendingRegistrations;

      Id courseOfferId = courseOfferings[0].Id;
      Pending_Registration__c newPendingReg = new Pending_Registration__c();
      newPendingReg.Contact__c = contacts[0].Id;
      newPendingReg.Course_Offering__c = courseOfferId;
      newPendingReg.Start_Time__c = System.now();

      insert newPendingReg;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [
        SELECT Id, On_Hold_Seat__c
        FROM hed__Course_Offering__c
        WHERE Id = :courseOfferId
      ];

      System.assertEquals(
        2,
        courseOfferingsResult[0].On_Hold_Seat__c,
        'On Hold Seat Count after creating new Pending Registration'
      );
    }
  }

  @isTest
  private static void updatePendingRegistration() {
    System.runAs(currentUser) {
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        10,
        accounts[0].Id
      );
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
        1
      );
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        10,
        accounts[0].Id,
        prodRequest[0].Id
      );
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        10,
        courses,
        terms
      );
      insert courseOfferings;

      List<Pending_Registration__c> pendingRegistrations = TestDataFactory.createTestPendingRegistrationRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );
      insert pendingRegistrations;

      Set<Id> courseOfferIdSet = new Set<Id>();
      courseOfferIdSet.add(courseOfferings[0].Id);
      courseOfferIdSet.add(courseOfferings[1].Id);

      List<Pending_Registration__c> pendRegList = [
        SELECT Id, Course_Offering__c
        FROM Pending_Registration__c
        WHERE Course_Offering__c = :courseOfferIdSet
      ];

      for (Pending_Registration__c pendReg : pendRegList) {
        pendReg.Course_Offering__c = courseOfferings[0].Id;
      }

      update pendRegList;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [
        SELECT Id, On_Hold_Seat__c
        FROM hed__Course_Offering__c
        WHERE Id = :courseOfferIdSet
      ];

      System.assertEquals(
        2,
        courseOfferingsResult[0].On_Hold_Seat__c,
        'On Hold Seat Count of Pending Registration 1 after updating Pending Registration 2 have the same Course Offer'
      );
      System.assertEquals(
        0,
        courseOfferingsResult[1].On_Hold_Seat__c,
        'On Hold Seat Count of Pending Registration 2 after updating Pending Registration 2 have the same Course Offer as Pending Registration 1'
      );
    }
  }

  @isTest
  private static void deletePendingRegistration() {
    System.runAs(currentUser) {
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        10,
        accounts[0].Id
      );
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
        1
      );
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        10,
        accounts[0].Id,
        prodRequest[0].Id
      );
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        10,
        courses,
        terms
      );
      insert courseOfferings;

      List<Pending_Registration__c> pendingRegistrations = TestDataFactory.createTestPendingRegistrationRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );
      insert pendingRegistrations;

      Id courseOfferId = courseOfferings[0].Id;

      List<Pending_Registration__c> pendRegList = [
        SELECT Id
        FROM Pending_Registration__c
        WHERE Course_Offering__c = :courseOfferId
      ];

      delete pendRegList;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [
        SELECT Id, On_Hold_Seat__c
        FROM hed__Course_Offering__c
        WHERE Id = :courseOfferId
      ];

      System.assertEquals(
        0,
        courseOfferingsResult[0].On_Hold_Seat__c,
        'On Hold Seat Count after deleting Pending Registration'
      );
    }
  }
}
