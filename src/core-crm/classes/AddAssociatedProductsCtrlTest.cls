/**
 * @description Test Class for AddAssociatedProductsCtrl
 * @see ../lwc/AddAssociatedProductsCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | November 09, 2021     | DEPP-671             | Created file                 | 
      |                           |                       |                      |                              | 
 */
@isTest(SeeAllData=false)
public with sharing class AddAssociatedProductsCtrlTest {
    
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Integer numberOfRecords = 100;

    @TestSetup
    static void setupMethod(){
        List<Product_Request__c> productRequestList = TestDataFactory.createTestProductRequestRecords(1);
        for(Product_Request__c productRequest : productRequestList){
            productRequest.Product_Request_Status__c = 'Release';            
        }
                
        List<Product2> productList = TestDataFactory.createTestProductRecords(numberOfRecords);
        List<Product2> productListToAdd = new List<Product2>();
        for(Product2 product :productList){
            product.Family = 'OPE';
            product.Description = 'Test Description';
            product.IsActive = true;
            productListToAdd.add(product); 
        }

        Test.startTest();
        insert productRequestList;
        insert productListToAdd;
        Test.stopTest();
    }

    @IsTest
    static void getProductsTest(){        
        List<AddAssociatedProductsCtrl.ProductDetails> productList = new List<AddAssociatedProductsCtrl.ProductDetails>();
        Test.startTest();
        System.runAs(currentUser){
            String recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
            productList = AddAssociatedProductsCtrl.getProducts(recordId);
        }          
        Test.stopTest();
        System.assertEquals(100, productList.size(), 'Product list retrieved did not match expexted.');        
    }

    @IsTest
    static void getCourseRecordTypesTest(){        
        List<String> recordTypes = new List<String>();
        Test.startTest();
        System.runAs(currentUser){
            recordTypes = AddAssociatedProductsCtrl.getCourseRecordTypes();
        }
        Test.stopTest();
        System.assert(!recordTypes.isEmpty(), 'No Record Types retrieved.');        
    }

    @IsTest
    static void addAssociatedProductTest(){                
        String response;
        Test.startTest();
        System.runAs(currentUser){
            List<AddAssociatedProductsCtrl.ProductDetails> productList = new List<AddAssociatedProductsCtrl.ProductDetails>();
            String recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;            
            productList = AddAssociatedProductsCtrl.getProducts(recordId);

            List<String> productIds = new List<String>();  
            for(AddAssociatedProductsCtrl.ProductDetails prodDetails : productList){
                productIds.add(prodDetails.id);
            }
            response = AddAssociatedProductsCtrl.addAssociatedProduct(productIds, recordId);
        }          
        Test.stopTest();
        System.assertEquals('Success', response, 'Failed to associate product(s).');        
    }

    @IsTest
    static void addAssociatedProductTestFail(){        
        String response;
        Test.startTest();
        System.runAs(currentUser){
            List<AddAssociatedProductsCtrl.ProductDetails> productList = new List<AddAssociatedProductsCtrl.ProductDetails>();
            String recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;            
            productList = AddAssociatedProductsCtrl.getProducts(recordId);

            List<String> productIds = new List<String>();  
            for(AddAssociatedProductsCtrl.ProductDetails prodDetails : productList){
                productIds.add(prodDetails.id);
            }
            response = AddAssociatedProductsCtrl.addAssociatedProduct(productIds, null);
        }          
        Test.stopTest();
        System.assertNotEquals('Success', response, 'Associated Products cant be saves withouth product request id.');        
    }    
}