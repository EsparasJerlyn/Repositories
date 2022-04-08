/**
 * @description Test class for Registration Confirmation Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | April 7, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class RegistrationConfirmationEmailCtrlTest {
  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();

  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @IsTest
  public static void testGenerateAndSendEmail() {
    System.runAs(currentUser) {
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      contacts[0].email = 'testContact@testmail.com';
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

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );

      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
        courseConnection.Amount__c = 100;
        courseConnection.Paid_in_Full__c = 'Yes';
      }
      insert courseConnections;

      hed__Course_Enrollment__c courseConnectionParam = [
        SELECT
          Id,
          Course_Offering_Name__c,
          Paid_in_Full__c,
          hed__Contact__r.FirstName,
          hed__Contact__r.LastName,
          Amount__c,
          hed__Contact__r.Email
        FROM hed__Course_Enrollment__c
        LIMIT 1
      ];
      List<List<String>> paramList = new List<List<String>>();
      List<String> param = new List<String>();
      param.add(courseConnectionParam.Id);
      param.add(courseConnectionParam.Course_Offering_Name__c);
      param.add(courseConnectionParam.Paid_in_Full__c);
      param.add(courseConnectionParam.hed__Contact__r.FirstName);
      param.add(courseConnectionParam.hed__Contact__r.LastName);
      param.add(String.valueof(courseConnectionParam.Amount__c));
      param.add(courseConnectionParam.hed__Contact__r.Email);
      paramList.add(param);

      RegistrationConfirmationEmailCtrl.generateAndSendEmail(paramList);
      System.assertEquals(
        1,
        Limits.getEmailInvocations(),
        'Emails should be sent'
      );
      Test.stopTest();
    }
  }
}