/**
 * @description Tests the Create Product and Offering Controller Test Class
 *
 * @see createProductsAndOfferingsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                      |
      |---------------------------|-----------------------|-----------|-------------------------------------|
      | adrian.c.habasa           | October 18, 2021      | DEPP-476  | Created file                        | 
      | eugene.andrew.abuan       | November 9, 2021      | DEPP-35   | Added method testGetProductRequests | 
*/

@isTest
public with sharing class CreateProductsAndOfferingsCtrlTest {
   
   private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
   
   @testSetup static void setupMethod()
   {
       List<Account> accounts;
       List<hed__Course__c> courses;
       List<hed__Course_Offering__c> courseOfferings;
       List<Product2> products;
       List<Product_Request__c> prodRequest;
       List<hed__Term__c> terms;
       accounts = TestDataFactory.createTestAccountRecords(1);
       insert accounts;
       terms = TestDataFactory.createTestTermRecords(100,accounts[0].Id);
       insert terms;
       prodRequest = TestDataFactory.createTestProductRequestRecords(1);
       insert prodRequest;

       Test.startTest();
       courses = TestDataFactory.createTestCourseRecords(100,accounts[0].Id,prodRequest[0].Id);
       insert courses;
       products = TestDataFactory.createTestProductRecords(100,courses);
       insert products;
       courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100,courses,terms);
       insert courseOfferings;
       Test.stopTest();
    }

   @isTest
    static void testGetRelatedCourse()
    {
        Test.startTest();
        System.runAs(currentUser)
        {   
            CreateProductsAndOfferingsCtrl.CourseWithOfferings getCourses = new CreateProductsAndOfferingsCtrl.CourseWithOfferings();
            getCourses = CreateProductsAndOfferingsCtrl.getRelatedCourse(string.valueOf([SELECT Id From Product_Request__c LIMIT 1].Id));  
            System.assert(!getCourses.courseList.isEmpty(),'Error while getting data');
        }
            Test.stopTest();
        }

    @isTest
    static void testGetProductRequests()
    {
        Test.startTest();
        System.runAs(currentUser)
        {
            String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            List<Product_Request__c> prodReqToTest = CreateProductsAndOfferingsCtrl.getProductRequests(prodReqId);        
            System.assertEquals(1, prodReqToTest.size() , 'Product Request did not match expected.');
        }
        Test.stopTest();
    }
}
