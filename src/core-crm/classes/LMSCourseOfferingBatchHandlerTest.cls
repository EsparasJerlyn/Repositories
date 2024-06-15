@isTest 
public class LMSCourseOfferingBatchHandlerTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setup() {
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
        for(hed__Course_Offering__c courseOffering : courseOfferings){
            courseOffering.LMS_Integration_Status__c = 'isChanged';
            courseOffering.LMS_Creation_Date__c = System.today();
        }
        insert courseOfferings;   
        
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void testCourseOfferingLMSUpdate()
    {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
		System.runAs(PORTAL_SYS_ADMIN) {
            hed__Course__c course = [SELECT Id, Primary_Delivery_Platform__c FROM hed__Course__c LIMIT 1];
            course.Primary_Delivery_Platform__c = 'QUT Canvas';
            update course;
            
            Test.startTest();
            LMSCourseOfferingBatchHandler job = new LMSCourseOfferingBatchHandler();
            DataBase.executeBatch(job, 200); 
            Test.stopTest();

            hed__Course_Offering__c courseOffering = [SELECT Id, LMS_Integration_Status__c FROM hed__Course_Offering__c LIMIT 1];
            System.assertEquals('Sent', courseOffering.LMS_Integration_Status__c, 'LMS Course Offering Callout is completed.');
        }
    }
}