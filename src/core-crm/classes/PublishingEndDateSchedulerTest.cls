/**
 * @description Tests the PublishingEndDateScheduler
 *
 * @see PublishingEndDateScheduler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | February 15, 2022     | DEPP-1256    | Created file                                | 
      |                           |                       |              |                                             | 
*/

@IsTest(SeeAllData=false)
public class PublishingEndDateSchedulerTest {
    
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static Integer numberOfRecords = 100;         
	
    @TestSetup
    static void setupMethod(){
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;

        List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(numberOfRecords);
        for(Product_Request__c productRequest : productRequests){
            productRequest.RecordTypeId = opeShortProdReqId;
        }
        insert productRequests;

        hed__Facility__c facility = new hed__Facility__c();
        facility.Name = 'test';
        insert facility;                

        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
        for(Integer i = 0 ; i < courses.size() ; i++){
            courses[i].ProductRequestID__c = productRequests[i].Id;
            courses[i].RecordTypeId = opeShortCourseId;
            courses[i].Location__c = facility.Id;             
        }
        insert courses;
    }

    @IsTest
    static void testPublishingEndDateScheduler(){
          System.runAs(currentUser){              
            String cronExpression = Label.Publishing_End_Date_Cron_Expression;
              
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 100];
            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = 'Release';
            }
            update productRequests;
            
            Test.startTest();
            List<Product2> products = [SELECT Id, Core_Concepts__c, Description, End_Date__c, More_Details__c, 
                    Name, Overview__c, Start_Date__c, Who_Should_Participate__c, Publishing_End_date__c,IsActive
                    FROM Product2 LIMIT 100];
            for(Product2 product : products){
                 product.Publishing_End_date__c = date.today();
            }
            update products;
              
           String jobId = System.Schedule('Test PublishingEndDateTest daily at 12AM', cronExpression, new PublishingEndDateScheduler());
           Test.stopTest();
             
         	List<CronTrigger> cts = [SELECT Id, TimesTriggered, NextFireTime FROM CronTrigger WHERE ID =: jobId ];
            
            DateTime midnight = Datetime.newInstance(date.today(), time.newInstance(0, 0, 0, 0));
            String dayToday = midnight.format('EEEE');

            if(dayToday == 'Friday'){
                System.assertEquals(midnight.addDays(3),cts[0].NextFireTime, 'Error, Next fire is Not Monday');
            }else if(dayToday =='Saturday'){
                System.assertEquals(midnight.addDays(2),cts[0].NextFireTime, 'Error, Next fire is Not Monday');
            }else if(dayToday == 'Sunday'){
                System.assertEquals(midnight.addDays(1),cts[0].NextFireTime, 'Error, Next fire is Not Monday');
            }
            else{
                System.assertEquals(midnight.addHours(24),cts[0].NextFireTime, 'Error Not Scheduled in Midnight');
            }
        }
    }
}