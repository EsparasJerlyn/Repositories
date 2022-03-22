/**
 * @description Test Class for the PublishingEndDateBatch
 * 
 * @see PublishingEndDateBatch
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | March 01, 2022	      | DEPP-1256            | Created file                 |
      |                           |                       |                      |                              | 
 */
@IsTest(SeeAllData=false) 
public with sharing class PublishingEndDateBatchTest {
    
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

        List<Product2> products = TestDataFactory.createTestProductRecords(numberOfRecords,courses);
        insert products;
    }
    
    @IsTest
    public static void testPublishingEndDateBatch() {  
        System.runAs(currentUser){              
    
            try{
                
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 100];
            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = 'In Delivery';
            }
            List<hed__Course__c> courses = [SELECT Id,ProductRequestID__c FROM hed__Course__c];
            update productRequests;
            
            List<Product2> products = [SELECT Id,Publishing_End_date__c,IsActive,Course__r.ProductRequestID__c FROM Product2 LIMIT 100];
            for(Product2 product : products){
                product.IsActive = true;
                product.Decommission_Product__c = true;
                product.Decommission_Reason__c = 'test';
                product.Publishing_End_date__c = date.today();
            }
            update products;
            
            Test.startTest();
        
            PublishingEndDateBatch batch = new PublishingEndDateBatch();
            Id batchId = Database.executeBatch(batch);
            
            Test.stopTest();
            
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'PublishingEndDateBatch'].isEmpty() , 'PublishingEndDate Job was not executed');
    
                
            }catch(Exception e){
               System.debug('ERROR: ' + e.getMessage());
            }
        }
    }
 }