/**
 * @description test class for RelatedProductsCtrl
 * @see ../classes/RelatedProductsCtrl
 * 
 * @author Accenture
 * 
 * @history
 *   | Developer                 | Date                  | JIRA                 | Change Summary               |
     |---------------------------|-----------------------|----------------------|------------------------------|
     | roy.nino.s.regala         | August 09, 2022       | DEPP-2498            | Created file                 | 
     | roy.nino.s.regala         | Sep 09, 2022          | DEPP-4188            | Fixed assertion error        | 
     |                           |                       |                      |                              | 
*/

@isTest
public with sharing class RelatedProductsCtrlTest {

     private static final Id SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Standing_Offer_Arrangement').getRecordTypeId();
     private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
     private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
     private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
     private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
     private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
         .get(ACCT_UNIV_DEP)
         .getRecordTypeId();
     private static final Id PROGRAM_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();
  
     @testSetup 
     static void setupMethod() {
         Test.startTest();
         TestDataFactoryUser.generateUserSystemAdministrator();
         TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
         Test.stopTest();
         final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;  

         System.runAs(PORTAL_SYS_ADMIN){
 
             ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
             insert prodCatalog;
     
             ProductCategory prodCateg = new ProductCategory(
                 Name = 'Products',
                 CatalogId = prodCatalog.Id
             );
             insert prodCateg;
     
             CommerceEntitlementPolicy commEntPolicy = new CommerceEntitlementPolicy(
                 Name = 'OPE Entitlement'
             );
             insert commEntPolicy;
     
             List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
     
             for(Account acc: accountList){
                 acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
             }
             insert accountList;
     
             List<Account> accounts;
             accounts = TestDataFactory.createTestAccountRecords(1);
             for(Account acc : accounts){
                 acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                 acc.Organization_Unit_Level__c = '2';
             }
             insert accounts;
             List<Contact> conList;
             conList = TestDataFactory.createTestContactRecords(2);
             insert conList;
     
             // Create CCE Product Specification
             List<Opportunity> closedWonOpportunityList = TestDataFactory.createClosedWonOpportunities(1, accounts[0].Id, conList.iterator().next()?.Id);
             insert closedWonOpportunityList;
             List<Product_Specification__c> cceProductSpecification = TestDataFactory.retrieveCCEProductSpecifications();

             // Create OPE Product Specification
             List<Opportunity> qualifyOpportunityList = TestDataFactory.createTestOpportunityRecords(1, accounts[0].Id, conList.iterator().next()?.Id);
             insert qualifyOpportunityList;
             List<Product_Specification__c> opeProductSpecification = TestDataFactory.createTestProductSpecsRecords(1,conList,qualifyOpportunityList);
             opeProductSpecification[0].RecordTypeId = opeProdSpecId;
             opeProductSpecification[0].Stage__c = 'Idea';
             insert opeProductSpecification;

             List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(1,cceProductSpecification[0].Id);
             soaRequest.addAll(TestDataFactory.createTestProductRequestRecords(1,opeProductSpecification[0].Id));

             Pricebook2 priceBook;
             pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
             update pricebook;
     
             for(Product_Request__c pr : soaRequest){
                 pr.RecordTypeId = SOA_ID;        
             }

             insert soaRequest;
     
             List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
             List<PriceBook2> soaPBList = new List<PriceBook2>();
             for(Integer i = 0; i<soaRequest.size();i++){
             bgToInsertList.add(new BuyerGroup(Name ='SOA' + i, Product_Request__c = soaRequest[i].Id));
             }
             
             insert bgToInsertList;
     
             List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,cceProductSpecification[0].Id);
             courseRequest.addAll(TestDataFactory.createTestProductRequestRecords(1,opeProductSpecification[0].Id));
             for(Product_Request__c pr : courseRequest){
                 pr.RecordTypeId = ACTIVITY_ID;        
             }
             insert courseRequest;
     
             List<hed__Course__c> courses = new List<hed__Course__c>();
             for(Product_Request__c prC: courseRequest){
             courses.addAll(TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prC.Id));
             }
     
             for(hed__Course__c c: courses){
             c.RecordTypeId = ACTIVITY_COURSE_ID;
             }
             insert courses;
     
             List<Product_Request__c> programRequest;
             programRequest = TestDataFactory.createTestProductRequestRecords(1,cceProductSpecification[0].Id);
             programRequest.addAll(TestDataFactory.createTestProductRequestRecords(1,opeProductSpecification[0].Id));

             for(Product_Request__c progamR:programRequest){
             progamR.RecordTypeId = PROGRAM_ID;
             }
             insert programRequest;
     
             List<hed__Program_Plan__c> programPlanList;
             programPlanList = TestDataFactory.createTestProgramPlanRecords(2);
             for(Integer i = 0; i < programRequest.size(); i++){
             programPlanList[i].Product_Request__c = programRequest[i].Id;
             programPlanList[i].Program_Delivery_Structure__c = 'Prescribed Program';
             }
             insert programPlanList;
     
             List<Related_Product_Request__c> relatedPRInsert = new List<Related_Product_Request__c>();
             for(Integer i = 0; i < soaRequest.size(); i ++){
             relatedPRInsert.add(new Related_Product_Request__c(Program__c = soaRequest[i].Id, Course__c = programRequest[i].Id));
             }
             insert relatedPRInsert;
     
             List<Associated_Products__c> assocProdList = new List<Associated_Products__c>();
     
             List<Product2> prodList = new List<Product2>([SELECT Id From Product2 WHERE Course__c IN: courses]);
     
             for(Integer i = 0; i < prodList.size(); i ++){
             assocProdList.add(new Associated_Products__c(Product__c = prodList[i].Id, Product_Request__c = soaRequest[i].Id, IsActive__c = true));
             }
     
             insert assocProdList;
     
             List<Product2> allProducts = new List<Product2>([SELECT Id FROM Product2]);
             List<PriceBookEntry> pbEToInsert = new List<PriceBookEntry>();
             List<PriceBookEntry> soaPBEToInsert = new List<PriceBookEntry>();
             
             List<Id> pbIds = new List<Id>();
             List<BuyerGroupPriceBook> bgPriceBookList = new List<BuyerGroupPriceBook>([
                SELECT Id, Pricebook2Id
                FROM BuyerGroupPriceBook
                WHERE BuyerGroupId IN: bgToInsertList
            ]);

            for(BuyerGroupPriceBook bgpb: bgPriceBookList){
                pbIds.add(bgPB.Pricebook2Id);
            }
            soaPBList = [SELECT Id FROM Pricebook2 WHERE Id IN: pbIds];
             
             for(Integer i = 0; i < allProducts.size(); i ++){
             pbEToInsert.add(new PricebookEntry(Pricebook2Id = priceBook.Id, UnitPrice = 12, Product2Id = allProducts[i].Id, IsActive = true));
             soaPBEToInsert.add(new PricebookEntry(Pricebook2Id = soaPBList[0].Id, UnitPrice = 12, Product2Id = allProducts[i].Id, IsActive = true));
             soaPBEToInsert.add(new PricebookEntry(Pricebook2Id = soaPBList[1].Id, UnitPrice = 12, Product2Id = allProducts[i].Id, IsActive = true));
             }
             insert pbEToInsert;
             insert soaPBEToInsert;
         }
     }
     

     @isTest
     public static void getProductsWithPricingTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               List<Product_Request__c> prList = new List<Product_Request__c>([
                    SELECT Id FROM Product_Request__c 
                    WHERE Product_Specification__r.RecordType.DeveloperName = 'CCE'
                    AND RecordTypeId =: SOA_ID
                    LIMIT 1
               ]);
               Test.startTest();
               System.assert(
                    !RelatedProductsCtrl.getProductsWithPricing(prList[0].Id).isEmpty(),
                    'No products retrieved'
                    );
               Test.stopTest();
          }
          
     }


     @isTest
     public static void getProductsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               List<Product2> allProducts = new List<Product2>([
                    SELECT Id 
                    FROM Product2
               ]);
     
               for(Product2 prod: allProducts){
                    prod.Ready_for_publishing__c = 'Yes';
                    prod.QA_Comments__c = 'qa comments';
                    prod.QA_Review_Completed__c = 'Yes';
                    prod.Publishing_Start_Date__c = Date.today();
                    prod.Available_On_Cart__c = true;
               }
               update allProducts;
               
               List<Product_Request__c> prList = new List<Product_Request__c>([
                    SELECT Id FROM Product_Request__c 
                    WHERE Product_Specification__r.RecordType.DeveloperName = 'CCE'
                    LIMIT 1
               ]);
               Test.startTest();
               System.assert(
                    !RelatedProductsCtrl.getProducts(prList[0].Id).isEmpty(),
                    'No products retrieved'
                    );
               Test.stopTest();
          }
          
     }

     @isTest
     public static void upsertPricebookEntriesTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               List<PricebookEntry> allPbEntry = new List<PricebookEntry>([
                    SELECT Id, UnitPrice
                    FROM PricebookEntry
               ]);
     
               for(PricebookEntry pb: allPbEntry){
                    pb.UnitPrice = 10;
               }
               Test.startTest();
               RelatedProductsCtrl.upsertPricebookEntries(allPbEntry);
               System.assert(
                    ![SELECT Id FROM PricebookEntry WHERE UnitPrice = 10].isEmpty(), 
                    'PricebookEntry not updated'
                    );
               Test.stopTest();

          }
     }

     @isTest
     public static void upsertAssociatedProductstTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               List<Associated_Products__c> allAssocProd = new List<Associated_Products__c>([
                    SELECT Id, IsActive__c
                    FROM Associated_Products__c
               ]);
     
               for(Associated_Products__c assoc: allAssocProd){
                    assoc.IsActive__c = false;
               }
               Test.startTest();
               RelatedProductsCtrl.upsertAssociatedProducts(allAssocProd);
               System.assert(
                    ![SELECT Id FROM Associated_Products__c WHERE IsActive__c = false].isEmpty(), 
                    'Associated products not updated'
                    );
               Test.stopTest();

          }
          
     }
     
}