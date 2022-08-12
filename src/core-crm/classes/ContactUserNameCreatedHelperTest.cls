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

@IsTest
public with sharing class ContactUserNameCreatedHelperTest {

    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();
    
    
    @TestSetup
    static void testSetup() {
      TestDataFactory.generateTestUsers();
    }

    @isTest
    private static void sendEmailOnContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
          test.startTest();

            Integer i = 0;
            List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
            for (Contact contact : contacts) {
              contact.Registered_Email__c = 'test' + i + '@mail.com';
              contact.QUT_Student_Username__c = 'U1248792' + i;
              i++;
            }
            insert contacts;

            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
            for (Account acc : accounts) {
              acc.RecordTypeId = ACCT_UNIV_DEP_ID;
              acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100,accounts[0].Id);
              insert terms;
        
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(100);
            insert prodRequest;
    
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100,accounts[0].Id,prodRequest[0].Id);
            insert courses;
    
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100,courses, terms);
            insert courseOfferings;

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(100,contacts[0].Id,courseOfferings);
            for (hed__Course_Enrollment__c courseConnection : courseConnections) {
            courseConnection.RecordTypeId = STUDENT_RECTYPEID;
            courseConnection.IsActive__c = TRUE;
            }
            insert courseConnections;
        
            Set<Id> contactIdSet = new Set<Id>();
            List<Contact> cont = [SELECT Id, QUT_Student_Username__c FROM Contact];
            for(Contact c : cont){
                contactIdSet.add(c.Id);
            }
            
            String message = ContactUserNameCreatedHelper.sendEmailUsernameCreated(contactIdSet);
            test.stopTest();
            
            System.assert(message !=null, 'Email is not Sent to the user');
        }
    }
}