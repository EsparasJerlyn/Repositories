/**
 * @description Controller Class for addAssociatedProducts LWC
 * @see ../lwc/addAssociatedProducts
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | November 09, 2021     | DEPP-671             | Created file                 | 
      | alexander.cadalin         | July 27, 2022         | DEPP-2498            | Modified getProducts         | 
      | roy.nino.s.regala         | Aug 09, 2022          | DEPP-2498            | Modified to get ope products | 
 */
public with sharing class AddAssociatedProductsCtrl {

     private static final String SUCCESS_RESPONSE = 'Success';
     
     /**
      * @description Retrieves list of Active OPE Products based on Product Request
      * @param recordId - Record ID from record page
      * @param allOrAssociated - determine whether to return all active/available products, or only those associated to the current product request
      * @return List of ProductDetails
      */
     @AuraEnabled
     public static List<ProductDetails> getProducts(String recordId, String allOrAssociated){
          List<ProductDetails> productDetails =  new List<ProductDetails>();
          List<Product2> productList = new List<Product2>();
          if( allOrAssociated == 'all') {
               productList = 
                    [SELECT Id, Name, Course__r.RecordType.Name, Start_Date__c, End_Date__c, Program_Plan__r.RecordType.Name,
                         (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true AND IsActive = true) 
                    FROM Product2 
                    WHERE IsActive = true 
                         AND Available_On_Cart__c = true
                         AND Id NOT IN (SELECT Product__c FROM Associated_Products__c WHERE Product_Request__c =: recordId)
                         AND ((Course__r.ProductRequestId__r.Product_Specification__r.RecordType.DeveloperName = 'OPE'
                              AND Course__r.ProductRequestId__r.Child_of_Prescribed_Program__c = false)
                              OR ( Program_Plan__r.Product_Request__r.Product_Specification__r.RecordType.DeveloperName = 'OPE'
                                   AND Program_Plan__r.Program_Delivery_Structure__c != 'Flexible Program'))
                    ORDER BY Name ASC];
          } else if( allOrAssociated == 'associated') {
               productList = 
                    [SELECT Id, Name, Course__r.RecordType.Name, Start_Date__c, End_Date__c, Program_Plan__r.RecordType.Name,
                         (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true AND IsActive = true) 
                    FROM Product2 
                    WHERE Id IN (SELECT Product__c FROM Associated_Products__c WHERE Product_Request__c =: recordId) 
                    ORDER BY Name ASC];
          }
               
          for(Product2 product : productList){
               ProductDetails productDetail = new ProductDetails();
               productDetail.courseRecordType = product.Course__r.RecordType != null ? product.Course__r.RecordType.Name:product.Program_Plan__r.RecordType.Name;      
               productDetail.productName = product.Name;
               productDetail.startDate = product.Start_Date__c;
               productDetail.endDate = product.End_Date__c;
               productDetail.id = product.Id;
               Decimal price;
               for(PricebookEntry pricebookEntry : product.PricebookEntries){
                    price = pricebookEntry.UnitPrice;                   
               } 
               productDetail.standardPrice = price != null ? price : 0;
               productDetails.add(productDetail);
          }
     
          return productDetails;
     }

     /**
      * @description Retrieves all record types from Course
      * @return List of Record Types from Course
      */
     @AuraEnabled(cacheable=true)
     public static List<String> getCourseRecordTypes(){
          List<String> recordTypeNames = new List<String>();
          for(RecordType recordType : [SELECT Name from RecordType WHERE sObjectType='hed__Course__c']){
               recordTypeNames.add(recordType.Name);
          }
          return recordTypeNames;
     }

     /**
      * @description Inserts List of Associated Products based on the List passed.
      * @param productIds - List of product ids to associate
      * @param productRequestId - Product Request Id to associate with product
      * @return response string
      */
     @AuraEnabled
     public static String addAssociatedProduct (List<String> productIds, String productRequestId){
          String response;
          try{
               List<Associated_Products__c> associatedProductList = new List<Associated_Products__c>();
               List<PricebookEntry> pbEntriesToInsertList = new List<PricebookEntry>();
               for(String productId : productIds){
                    Associated_Products__c associatedProductToAdd = new Associated_Products__c();
                    associatedProductToAdd.Product__c = productId;
                    associatedProductToAdd.Product_Request__c  = productRequestId;
                    associatedProductToAdd.IsActive__c = true;
                    associatedProductList.add(associatedProductToAdd);
               }
               insert associatedProductList;

               List<BuyerGroupPriceBook> buyerGroupPriceBook2 = new List<BuyerGroupPriceBook>(
                    [    
                         SELECT Id, Pricebook2Id 
                         FROM BuyerGroupPriceBook
                         WHERE BuyerGroupId 
                         IN ( SELECT Id 
                              FROM BuyerGroup
                              WHERE Product_Request__c =: productRequestId
                              )
               ]);

               List<PricebookEntry> pbEntries = [ 
                    SELECT Id, UnitPrice, Product2Id
                    FROM PricebookEntry
                    WHERE Product2Id IN: productIds
                    AND Pricebook2.IsStandard = true
               ];
               if(!buyerGroupPriceBook2.isEmpty()){
                    for(PricebookEntry pbEntry: pbEntries){
                         pbEntriesToInsertList.add(new PricebookEntry(     
                              Product2Id = pbEntry.Product2Id, 
                              UnitPrice = pbEntry.UnitPrice, 
                              Pricebook2Id = buyerGroupPriceBook2[0].Pricebook2Id,
                              IsActive = true));
                    }
               }
               
               if(!pbEntriesToInsertList.isEmpty()){
                    insert pbEntriesToInsertList;
               }

               response = SUCCESS_RESPONSE;
          }catch(Exception e){
               response = e.getMessage();
          }
          return response;
     }

     /**
      * @description Wrapper class that holds data to be displayed
      */
     public class ProductDetails{
          @AuraEnabled
          public String id;
          @AuraEnabled
          public String productName;
          @AuraEnabled
          public String courseRecordType;
          @AuraEnabled
          public Date startDate;
          @AuraEnabled
          public Date endDate;
          @AuraEnabled
          public Decimal standardPrice;
      }
}