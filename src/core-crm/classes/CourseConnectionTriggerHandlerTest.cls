/**
 * @description Tests Class for CourseConnectionTriggerHandler
 * @see CourseConnectionTriggerHandlerTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | johnbo.pineda@qut.edu.au       | December 06, 2021     | DEPP-789               | Created file                                             |
      | johnbo.pineda@qut.edu.au       | January 05, 2021      | DEPP-1382              | Updated Test Class to include changes for DEPP-1382.     |
      | johnbo.pineda@qut.edu.au       | January 31, 2021      | DEPP-1519              | Updated Test Class to include changes for DEPP-1519.     |
      |                                |                       |                        |                                                          |
 */
@isTest(SeeAllData=false)
public with sharing class CourseConnectionTriggerHandlerTest {
  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();

  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @isTest
  private static void insertCourseConnection() {
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

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
        10
      );
      insert programPlans;

      List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(
        10,
        programPlans
      );
      insert programOfferings;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings,
        programOfferings
      );

      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      Id courseOfferId = courseOfferings[0].Id;
      Id programOfferId = programOfferings[0].Id;
      hed__Course_Enrollment__c newCourseEnroll = new hed__Course_Enrollment__c();
      newCourseEnroll.RecordTypeId = STUDENT_RECTYPEID;
      newCourseEnroll.hed__Contact__c = contacts[0].Id;
      newCourseEnroll.hed__Course_Offering__c = courseOfferId;
      newCourseEnroll.Program_Offering__c = programOfferId;

      insert newCourseEnroll;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [
        SELECT Id, Total_Course_Connections__c
        FROM hed__Course_Offering__c
        WHERE Id = :courseOfferId
      ];

      List<Program_Offering__c> programOfferingsResult = [
        SELECT Id, Total_Course_Connections__c
        FROM Program_Offering__c
        WHERE Id = :programOfferId
      ];

      System.assertEquals(
        2,
        courseOfferingsResult[0].Total_Course_Connections__c,
        'Total Course Connection Count for Course Offering after creating new Course Connection'
      );

      System.assertEquals(
        2,
        programOfferingsResult[0].Total_Course_Connections__c,
        'Total Course Connection Count for Program Offering after creating new Course Connection'
      );
    }
  }

  @isTest
  private static void updateCourseConnection() {
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

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
        10
      );
      insert programPlans;

      List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(
        10,
        programPlans
      );
      insert programOfferings;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings,
        programOfferings
      );

      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      Set<Id> courseOfferIdSet = new Set<Id>();
      courseOfferIdSet.add(courseOfferings[0].Id);
      courseOfferIdSet.add(courseOfferings[1].Id);

      Set<Id> programOfferIdSet = new Set<Id>();
      programOfferIdSet.add(programOfferings[0].Id);
      programOfferIdSet.add(programOfferings[1].Id);

      List<hed__Course_Enrollment__c> courseEnrollList = [
        SELECT Id, hed__Course_Offering__c, Program_Offering__c
        FROM hed__Course_Enrollment__c
        WHERE hed__Course_Offering__c = :courseOfferIdSet
      ];

      for (hed__Course_Enrollment__c courseEnroll : courseEnrollList) {
        courseEnroll.hed__Course_Offering__c = courseOfferings[0].Id;
        courseEnroll.Program_Offering__c = programOfferings[0].Id;
      }

      update courseEnrollList;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [
        SELECT Id, Total_Course_Connections__c
        FROM hed__Course_Offering__c
        WHERE Id = :courseOfferIdSet
      ];

      List<Program_Offering__c> programOfferingsResult = [
        SELECT Id, Total_Course_Connections__c
        FROM Program_Offering__c
        WHERE Id = :programOfferIdSet
      ];

      System.assertEquals(
        2,
        courseOfferingsResult[0].Total_Course_Connections__c,
        'Total Course Connection Count of Course Connection 1 after updating Course Connection 2 have the same Course Offer'
      );
      System.assertEquals(
        0,
        courseOfferingsResult[1].Total_Course_Connections__c,
        'Total Course Connection Count of Course Connection 2 after updating Course Connection 2 have the same Course Offer as Course Connection 1'
      );

      System.assertEquals(
        2,
        programOfferingsResult[0].Total_Course_Connections__c,
        'Total Course Connection Count of Course Connection 1 after updating Course Connection 2 have the same Program Offer'
      );
      System.assertEquals(
        0,
        programOfferingsResult[1].Total_Course_Connections__c,
        'Total Course Connection Count of Course Connection 2 after updating Course Connection 2 have the same Program Offer as Course Connection 1'
      );
    }
  }

  @isTest
  private static void deleteCourseConnection() {
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

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
        10
      );
      insert programPlans;

      List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(
        10,
        programPlans
      );
      insert programOfferings;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings,
        programOfferings
      );

      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      Id courseOfferId = courseOfferings[0].Id;
      Id programOfferId = programOfferings[0].Id;

      List<hed__Course_Enrollment__c> courseEnrollList = [
        SELECT Id
        FROM hed__Course_Enrollment__c
        WHERE hed__Course_Offering__c = :courseOfferId
      ];

      delete courseEnrollList;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [
        SELECT Id, Total_Course_Connections__c
        FROM hed__Course_Offering__c
        WHERE Id = :courseOfferId
      ];

      List<Program_Offering__c> programOfferingsResult = [
        SELECT Id, Total_Course_Connections__c
        FROM Program_Offering__c
        WHERE Id = :programOfferId
      ];

      System.assertEquals(
        0,
        courseOfferingsResult[0].Total_Course_Connections__c,
        'Total Course Connection Count for Course Offering after deleting Course Connection'
      );

      System.assertEquals(
        0,
        courseOfferingsResult[0].Total_Course_Connections__c,
        'Total Course Connection Count for Program Offering after deleting Course Connection'
      );
    }
  }
}
