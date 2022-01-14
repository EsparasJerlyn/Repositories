/**
 * @description Tests the Product Details Controller Test Class
 *
 * @see ProductDetailsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                     |
      |---------------------------|-----------------------|-----------|----------------------------------------------------|
      | roy.nino.s.regala         | December 10, 2021     | DEPP116   | Created file                                       | 
      | roy.nino.s.regala         | December 27, 2021     | DEPP1028  | Added testmethod for insertLearnerInfo             | 
*/
@isTest(SeeAllData=false)
private class ProductDetailsCtrlTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();

    @testSetup static void setupMethod() {
       List<Account> accounts;
       List<hed__Term__c> terms;
       List<Product_Request__c> prodRequest;
       List<hed__Course_Offering__c> courseOfferings;
       List<hed__Course__c> courses;
       List<Product2> products;
       Pricebook2 priceBook;
       PricebookEntry priceBookEntry;
        
       accounts = TestDataFactory.createTestAccountRecords(100);
       insert accounts;
       terms = TestDataFactory.createTestTermRecords(50,accounts[0].Id);
       insert terms;
       prodRequest = TestDataFactory.createTestProductRequestRecords(1);
       insert prodRequest;
       courses = TestDataFactory.createTestCourseRecords(50,accounts[0].Id,prodRequest[0].Id);
       insert courses;
       products = TestDataFactory.createTestProductRecords(50,courses);
       insert products;
       pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
       update pricebook;
       priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = products[0].Id, isActive = true);
       insert priceBookEntry;
       courseOfferings = TestDataFactory.createTestCourseOfferingRecord(50,courses,terms);
       insert courseOfferings;
       
    }

    @isTest
    static void testGetProductRelatedRecords()
    {
        Test.startTest();
        System.runAs(currentUser)
        {   
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getProductDetails = ProductDetailsCtrl.getProductRelatedRecords([SELECT Id FROM Product2 LIMIT 1].Id); 
            System.assert(!getProductDetails.courseOfferingList.isEmpty(),'no courseofferings found');
            System.assert(!getProductDetails.priceBookEntryList.isEmpty(),'no pricebookentries found');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductRelatedRecordsNegative()
    {
        boolean hasError = false;
        Test.startTest();
        System.runAs(currentUser)
        {   
            Product2 singleProduct = TestDataFactory.createTestInActiveProductRecords(1).iterator().next();
            insert singleProduct;
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(singleProduct.Id);
            System.assert(getProductDetails.courseOfferingList.isEmpty(),'has courseofferings found');
            System.assert(getProductDetails.priceBookEntryList.isEmpty(),'has pricebookentries found');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductRelatedRecordsError()
    {
        boolean hasError = false;
        Test.startTest();
        System.runAs(currentUser)
        {   
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            try{
                getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(null); 
            }catch(Exception e){
                hasError = true;
            }
            System.assert(hasError,'has no error');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertLearnerInfo()
    {
        List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1]);
        List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
        Test.startTest();
        System.runAs(currentUser)
        {  
            ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
            wrappedData.courseOfferingId = courseOffering[0].Id;

            ProductDetailsCtrl.insertLearnerInfo(contacts,wrappedData);
            System.assert(![SELECT ID FROM Contact].isEmpty(),'has no contacts created');
            System.assert(![SELECT ID FROM hed__Course_Enrollment__c].isEmpty(),'has no contact enrollement created');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertLearnerInfoError()
    {
        List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1]);
        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
        contacts[0].Email = 'testemail';
        boolean hasError = false;
        Test.startTest();
        System.runAs(currentUser)
        {  
            ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
            wrappedData.courseOfferingId = courseOffering[0].Id;
            try{
                ProductDetailsCtrl.insertLearnerInfo(contacts,wrappedData);
            }catch(Exception e){
                hasError = true;
            }
            System.assert(hasError,'has no error');
        }
        Test.stopTest();
    }


}