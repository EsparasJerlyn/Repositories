/**
 * @description Tests the Create Product and Offering Controller Test Class
 *
 * @see createProductsAndOfferingsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA             | Change Summary                                                                                                              |
      |---------------------------|-----------------------|------------------|-----------------------------------------------------------------------------------------------------------------------------|
      | adrian.c.habasa           | October 18, 2021      | DEPP-476         | Created file                                                                                                                |
      | eugene.andrew.abuan       | November 9, 2021      | DEPP-35          | Added method testGetProductRequests                                                                                         |
      | roy.nino.s.regala         | November 25, 2021     | DEPP-362,38,37   | Added method testGetRelatedCourseProgramRequestRecordType, testUpdateProductRequests,testUpsertProgramPlanAndPlanRequirement|
*/

@isTest
public with sharing class CreateProductsAndOfferingsCtrlTest {

   private static Map <String,Schema.RecordTypeInfo> productRequestRecordTypes = Product_Request__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
   private static Id programRequestRTId = productRequestRecordTypes.get('Program Request').getRecordTypeId();
   private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
   private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

   @testSetup static void setupMethod()
   {
       TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
       List<Account> accounts;
       List<hed__Course__c> courses;
       List<hed__Course__c> coursesProgramRequest;
       List<hed__Course_Offering__c> courseOfferings;
       List<Product2> products;
       List<Product_Request__c> prodRequest;
       List<Product_Request__c> prodRequestProgramRequest;
       List<hed__Program_Plan__c> programPlanList;
       List<hed__Term__c> terms;
       accounts = TestDataFactory.createTestAccountRecords(1);
       for(Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
       }
       insert accounts;
       terms = TestDataFactory.createTestTermRecords(100,accounts[0].Id);
       insert terms;
       prodRequest = TestDataFactory.createTestProductRequestRecords(1);
       insert prodRequest;

       prodRequestProgramRequest = TestDataFactory.createTestProductRequestRecords(1);
       prodRequestProgramRequest[0].Product_Request_Name__c = 'Program Request';
       prodRequestProgramRequest[0].RecordTypeId = programRequestRTId;
       insert prodRequestProgramRequest;

       Test.startTest();
       courses = TestDataFactory.createTestCourseRecords(50,accounts[0].Id,prodRequest[0].Id);
       insert courses;
       coursesProgramRequest = TestDataFactory.createTestCourseRecords(50,accounts[0].Id,prodRequestProgramRequest[0].Id);
       insert coursesProgramRequest;
       programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
       programPlanList[0].Product_Request__c = prodRequestProgramRequest[0].Id;
       insert programPlanList;
       products = TestDataFactory.createTestProductRecords(50,courses);
       insert products;
       products = TestDataFactory.createTestProductRecords(50);
       for(Product2 product: products){
           product.Program_Plan__c = programPlanList[0].Id;
       }
       insert products;
       courseOfferings = TestDataFactory.createTestCourseOfferingRecord(50,courses,terms);
       insert courseOfferings;
       Test.stopTest();
    }

    @isTest
    static void testGetRelatedCourse()
    {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            CreateProductsAndOfferingsCtrl.CourseWithOfferings getCourses = new CreateProductsAndOfferingsCtrl.CourseWithOfferings();
            getCourses = CreateProductsAndOfferingsCtrl.getRelatedCourse(string.valueOf([SELECT Id FROM Product_Request__c LIMIT 1].Id));
            System.assert(!getCourses.courseList.isEmpty(),'Error while getting data');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetRelatedCourseProgramRequestRecordType()
    {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            CreateProductsAndOfferingsCtrl.CourseWithOfferings getCourses = new CreateProductsAndOfferingsCtrl.CourseWithOfferings();
            getCourses = CreateProductsAndOfferingsCtrl.getRelatedCourse(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:programRequestRTId LIMIT 1].Id));
            System.assert(!getCourses.courseList.isEmpty(),'Error while getting data');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductRequests()
    {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            List<Product_Request__c> productRequestToUpdate = new List<Product_Request__c>();
            List<Product_Request__c> productRequestList  = new List<Product_Request__c>([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:programRequestRTId]);
            for(Product_Request__c productRequest: productRequestList){
                productRequest.Product_Request_Status__c = 'Design';
                productRequestToUpdate.add(productRequest);
            }
            CreateProductsAndOfferingsCtrl.updateProductRequests(productRequestToUpdate);
            System.assert(![SELECT Id FROM Product_Request__c WHERE Product_Request_Status__c = 'Design'].isEmpty(),'Error Updating product requests');
        }
        Test.stopTest();
    }
}
