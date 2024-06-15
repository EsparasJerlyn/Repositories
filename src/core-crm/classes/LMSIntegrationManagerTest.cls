/**
 * @description Test Class for LMSIntegrationManager
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  		| JIRA         					| Change Summary                              	|
 *    |---------------------------|-----------------------------|-------------------------------|-----------------------------------------------|
 *    | kenneth.f.alsay           | September 26, 2023          | DEPP-6629                     | Deleted testCalloutLMSCourse                  |
 *    | kenneth.f.alsay           | December 19, 2023           | DEPP-7447                     | Updated course offering setup                 |
 */
@isTest 
public class LMSIntegrationManagerTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    
    @testSetup static void setup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;
            
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
            insert terms;
            
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, prodRequest[0].Id);
            insert courses;
            
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            courseOfferings[0].hed__Start_Date__c = System.today();
            courseOfferings[0].LMS_Integration_Status__c = 'isChanged';
            insert courseOfferings; 
            
            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(1, contacts[0].Id, courseOfferings);
            for(hed__Course_Enrollment__c courseEnrollment : courseConnections) {
                courseEnrollment.recordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            }
            insert courseConnections;
        }
    }
    
    @isTest
    static void testCourseOfferingLMSUpdate()
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
           	hed__Course__c course = [SELECT Id, Primary_Delivery_Platform__c FROM hed__Course__c LIMIT 1];
            course.Primary_Delivery_Platform__c = 'QUT Canvas';
            update course;
            
            hed__Course_Offering__c courseOfferingOld = [SELECT Id, LMS_Creation_Date__c FROM hed__Course_Offering__c LIMIT 1];
            courseOfferingOld.LMS_Creation_Date__c = System.today()-10;
            update courseOfferingOld;
            
            Test.startTest();
            LMSCourseOfferingBatchHandler job = new LMSCourseOfferingBatchHandler();
            DataBase.executeBatch(job, 1); 
            Test.stopTest();

            hed__Course_Offering__c courseOffering = [SELECT Id, LMS_Integration_Status__c FROM hed__Course_Offering__c LIMIT 1];
            System.assertEquals('Sent', courseOffering.LMS_Integration_Status__c, 'LMS Course Offering Callout is completed.');
        }
    }
    
    @isTest
    static void testCourseEnrollmentLMSUpdate() 
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Contact contact = [SELECT Id, QUT_Identity_ID__c, QUT_Employee_ID__c, QUT_Student_ID__c  FROM Contact LIMIT 1];
            contact.QUT_Identity_ID__c = 'test';
            contact.QUT_Student_ID__c = 'test';
            update contact;

            hed__Course__c course = [SELECT Id, Mark_Content_as_Complete__c, Primary_Delivery_Platform__c, LMS_Integration_Status__c FROM hed__Course__c LIMIT 1];
            course.Primary_Delivery_Platform__c = 'QUT Canvas';
            update course;

            hed__Course_Offering__c courseOffering = [SELECT Id, LMS_Integration_Status__c, hed__Start_Date__c FROM hed__Course_Offering__c LIMIT 1];
            courseOffering.LMS_Integration_Status__c = 'Success';
            courseOffering.hed__Start_Date__c = System.Today();
            update courseOffering;
            
            hed__Course_Enrollment__c courseEnrollmentOld = [SELECT Id, Course_Offering_Start_Date__c FROM hed__Course_Enrollment__c LIMIT 1];
            courseEnrollmentOld.LMS_Integration_Status__c = null;
            update courseEnrollmentOld;
            
            Test.startTest();
            LMSCourseEnrollmentBatchHandler job = new LMSCourseEnrollmentBatchHandler();
            DataBase.executeBatch(job, 200); 
            Test.stopTest();

            hed__Course_Enrollment__c courseEnrollment = [SELECT Id, LMS_Integration_Status__c FROM hed__Course_Enrollment__c LIMIT 1];
            System.assertEquals('Sent', courseEnrollment.LMS_Integration_Status__c, 'LMS Course Enrollment Callout is completed.');
        }
    }
    
    @isTest
    static void testLearnerRegisterUpdate() 
    {        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            SAMSRegisterLearnerBatchHandler job = new SAMSRegisterLearnerBatchHandler();
            DataBase.executeBatch(job, 1); 
            Test.stopTest();

            Contact contact = [SELECT Id, SAMS_Integration_Status__c FROM Contact LIMIT 1];
            System.assertEquals('Sent', contact.SAMS_Integration_Status__c, 'SAMS Learner Register Callout is completed.');
        }
    }
    
}