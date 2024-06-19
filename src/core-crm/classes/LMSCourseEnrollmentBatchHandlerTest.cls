@isTest 
public class LMSCourseEnrollmentBatchHandlerTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup 
    static void setup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest(); 
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert bypass;
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
            insert courseOfferings;      

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(1, contacts[0].Id, courseOfferings);
            for(hed__Course_Enrollment__c courseEnrollment : courseConnections) {
                courseEnrollment.recordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            }
            insert courseConnections;
        }
    }


    @isTest
    static void testCourseEnrollmentLMSUpdate() 
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
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
            
            LMSCourseEnrollmentBatchHandler job = new LMSCourseEnrollmentBatchHandler();
            DataBase.executeBatch(job, 200); 
            Test.stopTest();

            hed__Course_Enrollment__c courseEnrollment = [SELECT Id, LMS_Integration_Status__c FROM hed__Course_Enrollment__c LIMIT 1];
            System.assertEquals('Sent', courseEnrollment.LMS_Integration_Status__c, 'LMS Course Enrollment Callout is completed.');
        }
    }
}