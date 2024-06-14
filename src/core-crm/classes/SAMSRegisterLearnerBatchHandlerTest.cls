@isTest 
public class SAMSRegisterLearnerBatchHandlerTest {

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
            insert courseOfferings;      

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(1, contacts[0].Id, courseOfferings);
            for(hed__Course_Enrollment__c courseEnrollment : courseConnections) {
                courseEnrollment.recordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            }
            insert courseConnections;
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