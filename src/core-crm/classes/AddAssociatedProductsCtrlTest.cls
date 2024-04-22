/**
 * @description Test Class for AddAssociatedProductsCtrl
 * @see ../lwc/AddAssociatedProductsCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | November 09, 2021     | DEPP-671             | Created file                 | 
      | alexander.cadalin         | July 28, 2022         | DEPP-2498            | Modified getProducts         | 
      | roy.nino.s.regala         | August 8, 2022        | DEPP-2498            | Updated code coverage        |
 */
@isTest
public with sharing class AddAssociatedProductsCtrlTest {
    
    private static final String PRODUCT_SPEC_RT = System.Label.RT_ProductSpecification_OPEProgramSpecification;
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PRODUCT_SPEC_RT).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static Integer numberOfRecords = 100;
	private static Integer numberOfAssocProductRecords = 25;
    
    @testSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        
        List<PriceBookEntry> pbToInsert = new List<PriceBookEntry>();
        List<BuyerGroup> bgToInsert = new List<BuyerGroup>();

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

        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;
        List<Contact> conList;
        conList = TestDataFactory.createTestContactRecords(1);
        insert conList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,accounts[0].Id,conList.iterator().next()?.Id);
        insert oppList;
        List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
            for(Integer i = 0 ; i < prodSpecList.size() ; i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
        }
        insert prodSpecList;

        List<Product_Request__c> productRequestList = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
        for(Product_Request__c productRequest : productRequestList){
            productRequest.Product_Request_Status__c = 'Release';            
        }
        insert productRequestList;

        bgToInsert.add(new BuyerGroup(Product_Request__c = productRequestList[0].Id, Name = 'SOA BG'));
        insert bgToInsert;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(100,accounts[0].Id,productRequestList[0].Id);
        insert courses;

        Pricebook2 priceBook;
        pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
        update pricebook;
                   
        List<Product2> productList = [  SELECT Id, Ready_for_publishing__c, QA_Comments__c, QA_Review_Completed__c, Publishing_Start_Date__c FROM Product2 LIMIT 100];
        for(Product2 prod: productList){
            prod.Ready_for_publishing__c = 'Yes';
            prod.QA_Comments__c = 'qa comments';
            prod.QA_Review_Completed__c = 'Yes';
            prod.Publishing_Start_Date__c = Date.today();
            pbToInsert.add(new PricebookEntry(Pricebook2Id = priceBook.Id, UnitPrice = 12, Product2Id = prod.Id));
        }

        update productList;
        insert pbToInsert;

        List<Associated_Products__c> assocProductsListToAdd = new List<Associated_Products__c>();
        for(Integer i = 0; i < numberOfAssocProductRecords; i++) {
            Associated_Products__c assocProduct = new Associated_Products__c();
            assocProduct.Product__c = productList[i].Id;
            assocProduct.Product_Request__c = productRequestList[0].Id;
            assocProductsListToAdd.add(assocProduct);
        }
        
        insert assocProductsListToAdd;
    }

    @isTest
    static void getAllProductsTest(){        
        List<AddAssociatedProductsCtrl.ProductDetails> productList = new List<AddAssociatedProductsCtrl.ProductDetails>();
        Test.startTest();
        System.runAs(TestDataFactorUser.selectUserQUTeXProgramAdministrator){
            String recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
            productList = AddAssociatedProductsCtrl.getProducts(recordId, 'all');
        }          
        Test.stopTest();
        System.assertEquals(
            numberOfRecords - numberOfAssocProductRecords, // Associated products no longer gets queried.
            productList.size(), 
            'Product list retrieved did not match expected.');        
    }
	
    @isTest 
    static void getAssociatedProductsTest() {
        List<AddAssociatedProductsCtrl.ProductDetails> productList = new List<AddAssociatedProductsCtrl.ProductDetails>();
        Test.startTest();
        System.runAs(TestDataFactorUser.selectUserQUTeXProgramAdministrator){
            String recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
            productList = AddAssociatedProductsCtrl.getProducts(recordId, 'associated');
        }          
        Test.stopTest();
        System.assertEquals(numberOfAssocProductRecords, productList.size(), 'Product list retrieved did not match expected.');
    }
    
    @isTest
    static void getCourseRecordTypesTest(){        
        List<String> recordTypes = new List<String>();
        Test.startTest();
        System.runAs(TestDataFactorUser.selectUserQUTeXProgramAdministrator){
            recordTypes = AddAssociatedProductsCtrl.getCourseRecordTypes();
        }
        Test.stopTest();
        System.assert(!recordTypes.isEmpty(), 'No Record Types retrieved.');        
    }

    @isTest
    static void addAssociatedProductTest(){                
        String response;
        Test.startTest();
        System.runAs(TestDataFactorUser.selectUserQUTeXProgramAdministrator){
            String recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;    

            List<String> productIds = new List<String>();  
            List<Product2> productList = new List<Product2>([  SELECT Id FROM Product2 LIMIT 100]);
            for(Product2 prod: productList){
                productIds.add(prod.Id);
            }
            response = AddAssociatedProductsCtrl.addAssociatedProduct(productIds, recordId);
        }          
        Test.stopTest();
        System.assertEquals('Success', response, 'Failed to associate product(s).');        
    }
}