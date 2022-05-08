@isTest 
public class LMSCourseBatchHandlerTest {

    @testSetup static void setup() {
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
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
    }

    @isTest
    static void testCourseLMSUpdate() 
    {
        hed__Course__c course = [SELECT Id, Mark_Content_as_Complete__c, Primary_Delivery_Platform__c FROM hed__Course__c LIMIT 1];
        course.Mark_Content_as_Complete__c = true;
        course.Primary_Delivery_Platform__c = 'Blackboard';
        update course;
        
        Test.startTest();
        LMSCourseBatchHandler job = new LMSCourseBatchHandler();
        DataBase.executeBatch(job, 1); 
        Test.stopTest();

        hed__Course__c courseAfterUpdate = [SELECT Id, isLMSTriggered__c FROM hed__Course__c LIMIT 1];
        System.assertEquals(true, courseAfterUpdate.isLMSTriggered__c, 'LMS Course Callout is completed.');
    }
}
