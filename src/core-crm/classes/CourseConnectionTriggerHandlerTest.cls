/**
* @description Tests Class for CourseConnectionTriggerHandler
* @see CourseConnectionTriggerHandlerTest
*
* @author Accenture
*
* @history
*
*  | Developer Email             | Date                  | JIRA                   | Change Summary                                           |
|--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
| johnbo.pineda@qut.edu.au       | December 06, 2021     | DEPP-789               | Created file                                             |
| johnbo.pineda@qut.edu.au       | January 05, 2021      | DEPP-1382              | Updated Test Class to include changes for DEPP-1382.     |
| johnbo.pineda@qut.edu.au       | January 31, 2021      | DEPP-1519              | Updated Test Class to include changes for DEPP-1519.     |
| Ana                            | 29/4/22               | DEPP-2361              | Updated Test Class to include changes for DEPP-2361.     |
| john.bo.a.pineda               | June 23, 2022         | DEPP-3222              | Updated Test Class to include changes for DEPP-3222.     |
| rhea.b.torres                  | August 18, 2022       | DEPP-2002              | Updated Test Class to include changes for DEPP-2002.     |
| kenneth.f.alsay                | December 06, 2023     | DEPP-7339              | Added QUT_Program_Administrator to generateTestUsers     |
 */
@isTest
public with sharing class CourseConnectionTriggerHandlerTest{

  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
  public static final Id PROG_STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Student_Program').getRecordTypeId();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
  private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName()
    .get('CCE')
    .getRecordTypeId();

  @testSetup
  static void makeData(){
    Test.startTest();
    TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    Test.stopTest();
  }

  @isTest
  private static void insertCourseConnection(){
    final String STR_EMAIL_TEMPLATE = 'Test Email Template';
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
    
      Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
      insert studyStore;
      List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
      for (Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      Integer i = 0;
      List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
      for (Contact contact : contacts){
        contact.Registered_Email__c = 'test' + i + '@mail.com';
        contact.QUT_Student_Username__c = 'U1248792' + i;
        i++;
      }
      insert contacts;
      Test.startTest();
      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100, accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(100);
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100, accounts[0].Id, prodRequest[0].Id);
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100, courses, terms);
      for (hed__Course_Offering__c courseOffering : courseOfferings){
        courseOffering.hed__Start_Date__c = Date.today() + 1;
        courseOffering.hed__End_Date__c = Date.today() + 2;
      }
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(100);
      insert programPlans;

      List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(100, programPlans);
      insert programOfferings;

      EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1, new Map<String, String>{ STR_EMAIL_TEMPLATE => 'Test Email Subject' }).iterator().next();
      insert template;

      List<Communication_Schedule__c> commScheds = TestDataFactory.createTestCommunicationScheduleRecords(100, courses, programPlans);
      for (Communication_Schedule__c commSched : commScheds){
        commSched.Email_on_Registration__c = true;
        commSched.On_Registration_Template__c = String.valueOf(template.Id);
      }
      insert commScheds;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100, contacts[0].Id, courseOfferings);

      for (hed__Course_Enrollment__c courseConnection : courseConnections){
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      courseConnections[1].RecordTypeId = PROG_STUDENT_RECTYPEID;
      courseConnections[1].hed__Course_Offering__c = null;
      courseConnections[1].Program_Offering__c = programOfferings[0].Id;
      courseConnections[2].RecordTypeId = PROG_STUDENT_RECTYPEID;
      courseConnections[2].hed__Course_Offering__c = null;
      courseConnections[2].Program_Offering__c = programOfferings[0].Id;
      courseConnections[3].hed__Course_Offering__c = courseOfferings[0].Id;
      insert courseConnections;

      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [SELECT Id, Total_Number_of_Registered_Learners__c
                                                       FROM hed__Course_Offering__c
                                                       WHERE Id = :courseOfferings[0].Id];

      System.assertEquals(2, courseOfferingsResult[0].Total_Number_of_Registered_Learners__c, 'Total Student Enrolment Count for Course Offering after creating new Course Connection');

      List<Program_Offering__c> programOfferingsResult = [SELECT Id, Total_Number_of_Registered_Learners__c
                                                    FROM Program_Offering__c
                                                    WHERE Id = :programOfferings[0].Id];

      System.assertEquals(2, programOfferingsResult[0].Total_Number_of_Registered_Learners__c, 'Total Student program Enrolment Count for Course Offering after creating new Course Connection');
    }
  }

  @isTest
  private static void updateCourseConnection(){
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      
      Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
      insert studyStore;
      List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
      for (Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100, accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(100);
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100, accounts[0].Id, prodRequest[0].Id);
      insert courses;
      Test.startTest();
      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100, courses, terms);
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(100);
      insert programPlans;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100, contacts[0].Id, courseOfferings);

      for (hed__Course_Enrollment__c courseConnection : courseConnections){
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      Set<Id> courseOfferIdSet = new Set<Id>();
      courseOfferIdSet.add(courseOfferings[0].Id);
      courseOfferIdSet.add(courseOfferings[1].Id);

      List<hed__Course_Enrollment__c> courseEnrollList = [SELECT Id, hed__Course_Offering__c
                                                    FROM hed__Course_Enrollment__c
                                                    WHERE hed__Course_Offering__c = :courseOfferIdSet];

      for (hed__Course_Enrollment__c courseEnroll : courseEnrollList){
        courseEnroll.hed__Course_Offering__c = courseOfferings[0].Id;
      }

      update courseEnrollList;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [SELECT Id, Total_Number_of_Registered_Learners__c
                                                       FROM hed__Course_Offering__c
                                                       WHERE Id = :courseOfferIdSet];

      System.assertEquals(2, courseOfferingsResult[0].Total_Number_of_Registered_Learners__c, 'Total Course Connection Count of Course Connection 1 after updating Course Connection 2 have the same Course Offer');
      System.assertEquals(0, courseOfferingsResult[1].Total_Number_of_Registered_Learners__c, 'Total Course Connection Count of Course Connection 2 after updating Course Connection 2 have the same Course Offer as Course Connection 1');
    }
  }


  @isTest
  private static void updateCourseConnectionStatus(){
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      
      Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
      insert studyStore;
      List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
      for (Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100, accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(100);
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100, accounts[0].Id, prodRequest[0].Id);
      insert courses;
      Test.startTest();
      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100, courses, terms);
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(100);
      insert programPlans;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100, contacts[0].Id, courseOfferings);

      for (hed__Course_Enrollment__c courseConnection : courseConnections){
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
      }
      insert courseConnections;

      Set<Id> courseOfferIdSet = new Set<Id>();
      courseOfferIdSet.add(courseOfferings[0].Id);
      courseOfferIdSet.add(courseOfferings[1].Id);

      List<hed__Course_Enrollment__c> courseEnrollList = [SELECT Id, hed__Course_Offering__c
                                                    FROM hed__Course_Enrollment__c
                                                    WHERE hed__Course_Offering__c = :courseOfferIdSet];

      for (hed__Course_Enrollment__c courseEnroll : courseEnrollList){
        courseEnroll.hed__Course_Offering__c = courseOfferings[0].Id;
        courseEnroll.hed__Status__c = 'Cancelled';
      }

      update courseEnrollList;
      Test.stopTest();

      System.assert(![Select Id FROM hed__Course_Enrollment__c WHERE hed__Status__c = 'Cancelled' LIMIT 1].isEmpty(), 'course enrollment was not cancelled');
    }
  }

  @isTest
  private static void deleteCourseConnection(){
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      
      Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
      insert studyStore;
      List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
      for (Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100, accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100, accounts[0].Id, prodRequest[0].Id);
      insert courses;
      Test.startTest();
      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100, courses, terms);
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(100);
      insert programPlans;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100, contacts[0].Id, courseOfferings);

      for (hed__Course_Enrollment__c courseConnection : courseConnections){
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
        courseConnection.hed__Status__c = 'Active';
      }
      insert courseConnections;

      Id courseOfferId = courseOfferings[0].Id;

      List<hed__Course_Enrollment__c> courseEnrollList = [SELECT Id
                                                    FROM hed__Course_Enrollment__c
                                                    WHERE hed__Course_Offering__c = :courseOfferId];

      delete courseEnrollList;
      Test.stopTest();

      List<hed__Course_Offering__c> courseOfferingsResult = [SELECT Id, Total_Number_of_Registered_Learners__c
                                                       FROM hed__Course_Offering__c
                                                       WHERE Id = :courseOfferId];

      System.assertEquals(0, courseOfferingsResult[0].Total_Number_of_Registered_Learners__c, 'Total Course Connection Count for Course Offering after deleting Course Connection');

      System.assertEquals(0, courseOfferingsResult[0].Total_Number_of_Registered_Learners__c, 'Total Course Connection Count for Program Offering after deleting Course Connection');
    }
  }

  @isTest
  private static void insertCourseConnectionForDiagnosticTool() {
    Id diagnosticToolRecTypeId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
                                            .get(Label.RT_ProductRequest_Diagnostic_Tool)
                                            .getRecordTypeId();
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      List<Account> accounts;
      accounts = TestDataFactory.createTestAccountRecords(100);
      for(Account acc : accounts){
          acc.RecordTypeId = ACCT_UNIV_DEP_ID;
          acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;
      List<Contact> conList;
      conList = TestDataFactory.createTestContactRecords(100);
      insert conList;
      Test.startTest();
      List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
      insert oppList;

      List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();

      List<Product_Request__c> diagnosticToolList = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
      for(Product_Request__c pr : diagnosticToolList){
        pr.RecordTypeId = diagnosticToolRecTypeId;        
      }
      insert diagnosticToolList;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        100,
        accounts[0].Id
      );
      insert terms;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        100,
        accounts[0].Id,
        diagnosticToolList[0].Id
      );
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        100,
        courses,
        terms
      );
      for(hed__Course_Offering__c courseOffering : courseOfferings){
        courseOffering.hed__Start_Date__c = Date.today()+1;
        courseOffering.hed__End_Date__c = Date.today()+2;
      }
      insert courseOfferings;

      Integer i = 0;
      List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
      for (Contact contact : contacts) {
        contact.Registered_Email__c = 'test' + i + '@mail.com';
        i++;
      }
      insert contacts;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        100,
        contacts[0].Id,
        courseOfferings
      );

      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
        courseConnection.hed__Status__c = 'Active';
      }
      insert courseConnections;

      Test.stopTest();

      List<Session__c> sessionList = [SELECT Id, Name FROM Session__c];
      System.assertEquals(100, sessionList.size(), 'Session list is not equal to 100');
      System.assert(sessionList[0].Name != null, 'Session Name is empty');
    }
  }
}