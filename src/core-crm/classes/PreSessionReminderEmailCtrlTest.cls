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
@isTest
public with sharing class PreSessionReminderEmailCtrlTest{
  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

  @testSetup
  static void makeData(){
    Test.startTest();
    TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    Test.stopTest();
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
      insert bypass;
    }
  }

  @isTest
  public static void controllerWithSessionTest(){
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for (Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      contacts[0].email = 'testContact@testmail.com';
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10, accounts[0].Id, prodRequest[0].Id);
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10, courses, terms);
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
      insert programPlans;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(10, contacts[0].Id, courseOfferings);

      for (hed__Course_Enrollment__c courseConnection : courseConnections){
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      List<Session__c> sessions = TestDataFactory.createTestSessionRecords(10);
      hed__Facility__c fac = new hed__Facility__c();
      fac.Name = 'test';
      insert fac;

      for (Session__c session : sessions){
        session.Course_Connection__c = courseConnections[0].Id;
        session.Course_Offering__c = courseOfferings[0].Id;
        session.Date__c = Date.today()+1;
        session.Start_Time_v2__c = Time.newInstance(15, 12, 30, 0);
        session.End_Time_v2__c = Time.newInstance(15, 12, 30, 0);
        session.Facilitator__c = contacts[0].Id;
        session.Location__c = fac.Id;
      }
      insert sessions;

      ApexPages.currentPage().getParameters().put('courseConnectionId', courseConnections[0].Id);
      PreSessionReminderEmailCtrl preSessionRemEmailCtrl = new PreSessionReminderEmailCtrl();

      System.assert(preSessionRemEmailCtrl.courseConnect.Id != null, 'courseConnection should be set');
      System.assertEquals(10, preSessionRemEmailCtrl.sessions.size(), 'sessions should be retrieved');
      Test.stopTest();
    }
  }

  @isTest
  public static void controllerWithoutSessionTest(){
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for (Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      contacts[0].email = 'testContact@testmail.com';
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10, accounts[0].Id, prodRequest[0].Id);
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10, courses, terms);
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
      insert programPlans;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(10, contacts[0].Id, courseOfferings);

      for (hed__Course_Enrollment__c courseConnection : courseConnections){
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      List<Session__c> sessions = TestDataFactory.createTestSessionRecords(10);
      hed__Facility__c fac = new hed__Facility__c();
      fac.Name = 'test';
      insert fac;

      for (Session__c session : sessions){
        session.Course_Connection__c = courseConnections[0].Id;
        session.Course_Offering__c = courseOfferings[0].Id;
        session.Date__c = Date.today();
        session.Start_Time_v2__c = Time.newInstance(15, 12, 30, 0);
        session.End_Time_v2__c = Time.newInstance(15, 12, 30, 0);
        session.Facilitator__c = contacts[0].Id;
        session.Location__c = fac.Id;
      }
      insert sessions;

      ApexPages.currentPage().getParameters().put('courseConnectionId', courseConnections[0].Id);
      PreSessionReminderEmailCtrl preSessionRemEmailCtrl = new PreSessionReminderEmailCtrl();

      System.assert(preSessionRemEmailCtrl.courseConnect.Id != null, 'courseConnection should be set');
      System.assertEquals(0, preSessionRemEmailCtrl.sessions.size(), 'no sessions should be retrieved');
      Test.stopTest();
    }
  }
}