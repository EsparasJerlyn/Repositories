/**
 * @description Test class for Virtual Final Confirmation Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | April 7, 2022         | DEPP-1479              | Created file                 |
      | rhea.b.torres                  | November 4, 2022      | DEPP-4720              | Deleted unused method        |
      |                                |                       |                        | generatePDFandSendEmail()    |      |                                |                       |                        |                              |
 */
@isTest
public with sharing class VirtualFinalConfirmationEmailCtrlTest {
  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

  @testSetup
  static void makeData(){
    TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
  }

  @isTest
  public static void testGeneratePDFandSendEmail() {
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
      courseOfferings[0].Delivery_Type__c = 'Online Classroom';
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
        session.Date__c = Date.newInstance(2022, 01, 06);
        session.Start_Time_v2__c = Time.newInstance(15, 12, 30, 0);
        session.End_Time_v2__c = Time.newInstance(15, 12, 30, 0);
        session.Facilitator__c = contacts[0].Id;
        session.Location__c = fac.Id;
      }
      insert sessions;

      ApexPages.currentPage().getParameters().put('courseConnectionId', courseConnections[0].Id);

      VirtualFinalConfirmationEmailCtrl virtualFinalConfirmationCtrl = new VirtualFinalConfirmationEmailCtrl();

      System.assertEquals(courseConnections[0].Id, virtualFinalConfirmationCtrl.courseConnect.Id, 'courseConnection should be set');
      System.assertEquals(10, virtualFinalConfirmationCtrl.sessions.size(), 'sessions should be created');
      Test.stopTest();
    }
  }
}
