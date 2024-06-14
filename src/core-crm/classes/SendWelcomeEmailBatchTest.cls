/**
 * @description Batch class to send welcome email to contacts
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email           | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala   	    | July 30, 2022         | DEPP-3557            | Created file                 | 
      | alexander.cadalin         | September 07, 2022    |                      | Test Error Fixes             |
      | kenneth.f.alsay           | December 06, 2023     | DEPP-7339            | Updated for changes to SendWelcomeEmailBatch.cls |
 */
@isTest
public with sharing class SendWelcomeEmailBatchTest {

    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    	.get('Student')
    	.getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }
        
    @isTest
    private static void sendWelcomEmailTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(
                FirstName = 'test firstname',
                LastName = 'test lastname',
                Email = 'registeredemail@email.test',
                Registered_Email__c = 'registeredemail@email.test',
                QUT_Student_Username__c ='aortiga'
            ));
            insert contacts;

            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for (Account acc : accounts) {
              acc.RecordTypeId = ACCT_UNIV_DEP_ID;
              acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1,accounts[0].Id);
            insert terms;
        
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
    
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
            courses[0].Primary_Delivery_Platform__c = 'QUT Canvas';
            insert courses;
    
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,courses, terms);
            courseOfferings[0].hed__Start_Date__c = System.Today() + 7;
            insert courseOfferings;

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(1,contacts[0].Id,courseOfferings);
            for (hed__Course_Enrollment__c courseConnection : courseConnections) {
            courseConnection.RecordTypeId = STUDENT_RECTYPEID;
            courseConnection.hed__Status__c = 'Active';
            }
            
            Test.startTest();
            insert courseConnections;

			      SendWelcomeEmailBatch batch = new SendWelcomeEmailBatch();
            Database.executeBatch(batch);

            Test.stopTest();
            
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SendWelcomeEmailBatch'].isEmpty() , 'SendWelcomeEmailBatch Job was not executed');
        }
    }
}