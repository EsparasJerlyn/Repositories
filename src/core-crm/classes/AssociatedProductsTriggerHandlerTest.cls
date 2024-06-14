/**
 * @description Test Class for AssociatedProductsTriggerHanlder
 * @see ..AssociatedProductsTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 17, 2022       | DEPP-2665              | Created File                 |
 */
@isTest
public without sharing class AssociatedProductsTriggerHandlerTest {
    public static final String CCE_CATALOG = 'CCE Catalog';
    public static final String CCE_CATEGORY_QLS = 'QUTeX Learning Solutions'; 
    public static final String CCE_CATEGORY_CB = 'Corporate Bundle';
    private static final String PRODUCT_SPEC_RT = System.Label.RT_ProductSpecification_OPEProgramSpecification;
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PRODUCT_SPEC_RT).getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();


    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business_Organization')
        .getRecordTypeId();

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();

    private static final Id PR_CORPBUNDLE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Corporate_Bundle')
        .getRecordTypeId();

    public static final Id PR_STANDOFFERARRANGE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Standing_Offer_Arrangement')
        .getRecordTypeId(); 

    

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        System.runAs(PROGRAM_ADMIN){
            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;
    
            ProductCatalog prodCatalog = new ProductCatalog(Name = 'CCE Catalog');
            insert prodCatalog;
    
            ProductCategory prodCategCB = new ProductCategory(
            Name = CCE_CATEGORY_CB,
            CatalogId = prodCatalog.Id
            );
            insert prodCategCB;
    
            ProductCategory prodCategQLS = new ProductCategory(
                Name = CCE_CATEGORY_QLS,
                CatalogId = prodCatalog.Id
                );
            insert prodCategQLS;
    
    
            List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
            accountList[0].RecordTypeId = BUSINESS_ACC_RECTYPEID;
            insert accountList;
            
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            insert conList;
            
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accountList[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100,accounts[0].Id,prodRequest[0].Id);
            insert courses;

            List<Product2> products = TestDataFactory.createTestProductRecords(100,courses);
            for (Product2 prod : products) {
              prod.IsActive = true;
              prod.Ready_for_publishing__c = 'Yes';
              prod.QA_Review_Completed__c = 'Yes';
              prod.Available_on_Cart__c = true;
              prod.QA_Comments__c = 'qa comments';
              prod.Publishing_Start_date__c = Date.today().AddDays(-1);
            }
            insert products;

            Pricebook2 pricebook = new Pricebook2(
              isActive = true,
              id = Test.getStandardPricebookId()
            );
            update pricebook;
      
            List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
            for (Product2 prodPBEntry : products) {
              PricebookEntry priceBookEntry = new PricebookEntry();
              priceBookEntry.pricebook2id = pricebook.Id;
              priceBookEntry.UnitPrice = 12;
              priceBookEntry.product2Id = prodPBEntry.Id;
              priceBookEntry.isActive = true;
              priceBookEntryList.add(priceBookEntry);
            }
            insert priceBookEntryList;
        }
        
    }

    @isTest
    public static void includeToStoreTestStandingOfferArgmnt() {
        final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
        Test.startTest();
        System.runAs(PROGRAM_ADMIN){

            List<Product2> products = [SELECT Id
                                       FROM Product2
                                       WHERE Available_on_Cart__c = TRUE
                                       AND IsActive = TRUE
                                       AND CreatedById =: PROGRAM_ADMIN.Id
                                       LIMIT 100];
            
            List<ProductCategory> categoryQLS = [SELECT Id 
                                                 FROM ProductCategory 
                                                 WHERE Name =: CCE_CATEGORY_QLS
                                                 LIMIT 1];

            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
            List<Product_Request__c> productRequestList = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c productRequest : productRequestList){
                productRequest.RecordTypeId = PR_STANDOFFERARRANGE_RECTYPEID;
            }
            insert productRequestList;

            BuyerGroup bgToInsertList = new BuyerGroup(
                Product_Request__c = productRequestList[0].Id, 
                Name = 'SOA BG');
            insert bgToInsertList;

            CommerceEntitlementPolicy soaEnt = new CommerceEntitlementPolicy(
                Name = 'SOA Entitlement'
            );
            insert soaEnt;

            CommerceEntitlementBuyerGroup soaEntBG = new CommerceEntitlementBuyerGroup(
                BuyerGroupId = bgToInsertList.Id,
                PolicyId = soaEnt.Id
            );
            insert soaEntBG;

            List<Associated_Products__c> assocProductsListToAdd = new List<Associated_Products__c>();
            for(Integer i = 0; i < 25; i++) {
                Associated_Products__c assocProduct = new Associated_Products__c();
                assocProduct.Product__c = products[i].Id;
                assocProduct.Product_Request__c = productRequestList[0].Id;
                assocProductsListToAdd.add(assocProduct);
            }
            insert assocProductsListToAdd;

            List<ProductCategoryProduct> prodCategProd = [SELECT Id 
                                                          FROM ProductCategoryProduct 
                                                          WHERE ProductCategoryId =: categoryQLS[0].Id];

            System.assert(!prodCategProd.IsEmpty(), 'No Products were inserted in the QUTeX Learning Solutions Category');
        }
        Test.stopTest();
    }
}
