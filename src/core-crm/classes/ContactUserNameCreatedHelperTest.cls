/**
 * @description Test Class for ContactUserNameCreated
 *
 * @see ../ContactUserNameCreatedHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | eugene.andrew.abuan       | July 04, 2022         | DEPP-3380    | Created file                                              | 
      |                           |                       |              |                                                           |
*/

@isTest
public with sharing class ContactUserNameCreatedHelperTest {

    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();


    @testSetup
    static void testSetup() {
      Test.startTest();
      TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
      Test.stopTest();
    }

    @isTest
    private static void sendEmailOnContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
          
            Integer i = 0;
            List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
            for (Contact contact : contacts) {
              contact.Registered_Email__c = 'test' + i + '@mail.com';
              contact.QUT_Student_Username__c = 'U1248792' + i;
              i++;
            }
            insert contacts;
            Test.startTest();
            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            
            Set<Id> contactIdSet = new Set<Id>();
            for(Contact con : [SELECT Id, QUT_Student_Username__c FROM Contact]){
              contactIdSet.add(con.Id);
            }
            
            String message = ContactUserNameCreatedHelper.sendEmailUsernameCreated(contactIdSet);
            Test.stopTest();
            
            System.assert(message !=null, 'Email is not Sent to the user');
            List<Task> createdTask = [SELECT Id, WhoId FROM Task WHERE WhoId=:contacts[0].Id];
            System.assert(createdTask!=null, 'Task was not created for the Contact.');
        }
    }

    @isTest
    public static void emailDeliverabilityTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
          // Create Accounts
          List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
          for (Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
          }
          insert accounts;

          // Create Contacts
          Integer i = 0;
          List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
          for (Contact contact : contacts) {
            contact.Registered_Email__c = 'test' + i + '@mail.com';
            contact.QUT_Student_Username__c = 'U1248792' + i;
            i++;
          }
          insert contacts;

          // 
          Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
          insert studyStore;

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

          // Create Course Connection
          List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100, contacts[0].Id, courseOfferings);
          for (hed__Course_Enrollment__c courseConnection : courseConnections){
            courseConnection.RecordTypeId = STUDENT_RECTYPEID;
          }
          insert courseConnections;

          Test.stopTest();

          List<Task> createdTask = [SELECT Id, WhoId FROM Task WHERE WhoId=:contacts[0].Id];
          System.assert(createdTask!=null, 'createdTask was not created for the Contact.');
      }
    }
}
