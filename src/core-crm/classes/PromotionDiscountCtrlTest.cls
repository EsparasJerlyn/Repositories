/**
 * @description PromotionDiscountCtrl Test Class
 * @see PromotionDiscountCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Nov 27, 2022          | DEPP-4721              | Created file                 |

 */
@isTest
public with sharing class PromotionDiscountCtrlTest {

    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
     private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
     private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
     private static final Integer NUMBER_OF_RECORDS = 10;
     private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
     private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
          .get(RT_CONTACT_PERSON)
          .getRecordTypeId();

     @testSetup
     static void setupData(){
          
          Test.startTest();
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
          Test.stopTest();
          createRecord(RT_ACTIVITY_ID);
     }

   
    @isTest
     static void getDiscountTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               //getDiscount(String selectedPBId, String standardPBId, String offeringId, Boolean prescribedProgram, String couponCode) {

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];

               Test.startTest();
               PromotionDiscountCtrl.DiscountData discountData = new PromotionDiscountCtrl.DiscountData();
               PromotionDiscountCtrl.DiscountWrapper discountWrapper = new PromotionDiscountCtrl.DiscountWrapper();
               discountWrapper.selectedPBId = samplePbe[0].Id;
               discountWrapper.standardPBId = samplePbe[0].Id;
               discountWrapper.offeringId = sampleOffering[0].Id;
               discountWrapper.prescribedProgram = false;
               discountWrapper.couponCode = 'test124';

               discountData = PromotionDiscountCtrl.getDiscount(JSON.serialize(discountWrapper));
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     @istest
     static void getDiscountProductTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];

               //create promotion
               Promotion promotionTest = new Promotion(
                    Name = 'Test Promotion2',
                    IsActive = true
               );
               insert promotionTest;

               Coupon couponTest = new Coupon(
                    CouponCode = 'test124',
                    Status = 'Active',
                    StartDateTime = System.now() - 1,
                    EndDateTime = System.now() + 1,
                    PromotionId = promotionTest.Id
               );
               insert couponTest;

               PromotionTarget promotionTargetTest = new PromotionTarget(
                    TargetType ='Product',
                    AdjustmentType = 'PercentageDiscount',  
                    AdjustmentPercent = 50,
                    PromotionId = promotionTest.Id,
                    TargetId = sampleProduct[0].Id
               );
               insert promotionTargetTest;

               Test.startTest();

               PromotionDiscountCtrl.DiscountData discountData = new PromotionDiscountCtrl.DiscountData();
               PromotionDiscountCtrl.DiscountWrapper discountWrapper = new PromotionDiscountCtrl.DiscountWrapper();
               discountWrapper.selectedPBId = samplePbe[0].Id;
               discountWrapper.standardPBId = samplePbe[0].Id;
               discountWrapper.offeringId = sampleOffering[0].Id;
               discountWrapper.prescribedProgram = false;
               discountWrapper.couponCode = 'test124';

               discountData = PromotionDiscountCtrl.getDiscount(JSON.serialize(discountWrapper));
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     @istest
     static void getDiscountInvalidCoupon(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];


               Test.startTest();

               PromotionDiscountCtrl.DiscountData discountData = new PromotionDiscountCtrl.DiscountData();
               PromotionDiscountCtrl.DiscountWrapper discountWrapper = new PromotionDiscountCtrl.DiscountWrapper();
               discountWrapper.selectedPBId = samplePbe[0].Id;
               discountWrapper.standardPBId = samplePbe[0].Id;
               discountWrapper.offeringId = sampleOffering[0].Id;
               discountWrapper.prescribedProgram = false;
               discountWrapper.couponCode = 'test123';

               discountData = PromotionDiscountCtrl.getDiscount(JSON.serialize(discountWrapper));
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     @istest
     static void getDiscountProductCategoryTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];

               WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
               insert testWebStore;
     
               ProductCatalog prodCatalog = new ProductCatalog(Name = 'CCE Catalog');
               insert prodCatalog;
     
               ProductCategory prodCategCB = new ProductCategory(
               Name = 'Test Category',
               CatalogId = prodCatalog.Id
               );
               insert prodCategCB;
     
               ProductCategory prodCategQLS = new ProductCategory(
                    Name = 'Test Category',
                    CatalogId = prodCatalog.Id
                    );
               insert prodCategQLS;

               //create promotion
               Promotion promotionTest = new Promotion(
                    Name = 'Test Promotion2',
                    IsActive = true
               );
               insert promotionTest;

               //create promotion
               Promotion_Product__c promotiontProductTest = new Promotion_Product__c(
                    IsActive__c = true,
                    Product__c = sampleProduct[0].Id,
                    Promotion__c = promotionTest.Id
               );
               insert promotiontProductTest;

               Coupon couponTest = new Coupon(
                    CouponCode = 'test124',
                    Status = 'Active',
                    StartDateTime = System.now() - 1,
                    EndDateTime = System.now() + 1,
                    PromotionId = promotionTest.Id
               );
               insert couponTest;

               PromotionTarget promotionTargetTest = new PromotionTarget(
                    TargetType ='ProductCategory',
                    AdjustmentType = 'PercentageDiscount',  
                    AdjustmentPercent = 50,
                    PromotionId = promotionTest.Id,
                    TargetId = prodCategCB.Id
               );
               insert promotionTargetTest;

               Test.startTest();
               
               PromotionDiscountCtrl.DiscountData discountData = new PromotionDiscountCtrl.DiscountData();
               PromotionDiscountCtrl.DiscountWrapper discountWrapper = new PromotionDiscountCtrl.DiscountWrapper();
               discountWrapper.selectedPBId = samplePbe[0].Id;
               discountWrapper.standardPBId = samplePbe[0].Id;
               discountWrapper.offeringId = sampleOffering[0].Id;
               discountWrapper.prescribedProgram = false;
               discountWrapper.couponCode = 'test124';

               discountData = PromotionDiscountCtrl.getDiscount(JSON.serialize(discountWrapper));
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     private static void createRecord(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

             List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
             for(Account account : accounts){
                  account.RecordTypeId = ACCT_UNIV_DEP_ID;
                  account.Organization_Unit_Level__c = '2';
              }
             insert accounts;

             Account act = new Account(Name = 'QUT Experience');
             insert act;

             List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
             for(Product_Request__c productRequest : productRequests){
                  productRequest.RecordTypeId = productRequestRecordType;
             }
             insert productRequests;

             List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
             insert courses;

             Pricebook2 priceBook;
             pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
             update pricebook;

             Product2 product = new Product2(Name = courses[0].Name, Course__c = courses[0].Id);
             insert product;

             PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, IsActive = true, Pricebook2Id = priceBook.Id, UnitPrice = 250.00);
             insert pbe;

             List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
             insert terms;

             List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
             insert courseOfferings;

             //create promotion
             Promotion promotionTest = new Promotion(
                  Name = 'Test Promotion',
                  IsActive = true
             );
             insert promotionTest;

             Coupon couponTest = new Coupon(
                  CouponCode = 'test123',
                  Status = 'Active',
                  StartDateTime = System.now() - 1,
                  EndDateTime = System.now() + 1,
                  PromotionId = promotionTest.Id
             );
             insert couponTest;

             PromotionTarget promotionTargetTest = new PromotionTarget(
                  TargetType ='Transaction',
                  AdjustmentType = 'PercentageDiscount',  
                  AdjustmentPercent = 50,
                  PromotionId = promotionTest.Id
             );
             insert promotionTargetTest;
             
        }
   }
}
