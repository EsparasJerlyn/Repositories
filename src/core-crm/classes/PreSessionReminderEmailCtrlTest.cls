/**
 * @description Test class for Pre-Session Reminder Email Template
 * @see PreSessionReminderEmailCtrl
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | April 7, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class PreSessionReminderEmailCtrlTest {
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
  public static void testGeneratePDFandSendEmail() {
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
      }
      insert courseConnections;

      List<Session__c> sessions = TestDataFactory.createTestSessionRecords(10);
      hed__Facility__c fac = new hed__Facility__c();
      fac.Name = 'test';
      insert fac;
        
      for (Session__c session : sessions) {
        session.Course_Connection__c = courseConnections[0].Id;
        session.Course_Offering__c = courseOfferings[0].Id;
        session.Date__c =  Date.newInstance(2022, 01, 06);
        session.Start_Time_v2__c =Time.newInstance(15, 12, 30, 0);
        session.End_Time_v2__c =Time.newInstance(15, 12, 30, 0);
        session.Facilitator__c = contacts[0].Id; 
        session.Location__c = fac.Id;  
      }
      insert sessions;

      PageReference pageRef = Page.SessionSchedulePDFView;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage()
        .getParameters()
        .put('courseConnectionId', courseConnections[0].Id);

      PreSessionReminderEmailCtrl preSessionRemEmailCtrl = new PreSessionReminderEmailCtrl();
      preSessionRemEmailCtrl.courseConnect = courseConnections[0];
      preSessionRemEmailCtrl.courseOffering = courseOfferings[0];
      preSessionRemEmailCtrl.sessions = sessions;

      hed__Course_Enrollment__c courseConnectionParam = [
        SELECT
          Id,
          Course_Offering_Name__c,
          hed__Contact__r.FirstName,
          hed__Contact__r.LastName,
          hed__Contact__r.Email
        FROM hed__Course_Enrollment__c
        LIMIT 1
      ];
      List<List<String>> paramList = new List<List<String>>();
      List<String> param = new List<String>();
      param.add(courseConnectionParam.Id);
      param.add(courseConnectionParam.Course_Offering_Name__c);
      param.add(courseConnectionParam.hed__Contact__r.FirstName);
      param.add(courseConnectionParam.hed__Contact__r.LastName);
      param.add(courseConnectionParam.hed__Contact__r.Email);
      paramList.add(param);

      PreSessionReminderEmailCtrl.generatePDFandSendEmail(paramList);
      System.assertEquals(
        1,
        Limits.getEmailInvocations(),
        'Emails should be sent'
      );
      Test.stopTest();
    }
  }
}