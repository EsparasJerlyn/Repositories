/**
 * @description Controller Class for relatedProducts LWC
 * @see ../lwc/relatedProducts
 * 
 * @author Accenture
 * 
 * @history
 *   | Developer                 | Date                  | JIRA                 | Change Summary               |
     |---------------------------|-----------------------|----------------------|------------------------------|
     | roy.nino.s.regala         | August 03, 2022       | DEPP-2498            | Created file                 | 
     |                           |                       |                      |                              | 
*/
public with sharing class RelatedProductsCtrl {

     private static final String SUCCESS_RESPONSE = 'Success';
     private static Map<String,Associated_Products__c> productToAsocProdMap = new Map<String,Associated_Products__c>();
     private static Boolean isStatusCompleted = false;
     private static String priceBookId = ''; 

     /**
     * @description Retrieves list of Active OPE Products based on Product Request
     * @param recordId - Record ID from record page
     * @return List of ProductDetails
     */
     @AuraEnabled(cacheable=true)
     public static List<ProductDetails> getProductsWithPricing(String recordId){  
           
          Set<Id> cceProductsSet = new Set<Id>();
          List<BuyerGroupPriceBook> buyerGroupPriceBook2 = new List<BuyerGroupPriceBook>(
               [    
                    SELECT Id, Pricebook2Id 
                    FROM BuyerGroupPriceBook
                    WHERE BuyerGroupId 
                    IN ( SELECT Id 
                         FROM BuyerGroup
                         WHERE Product_Request__c =: recordId
                         )
               ]);

          if(!buyerGroupPriceBook2.isEmpty()){
               priceBookId = buyerGroupPriceBook2[0].Pricebook2Id;
          }

          Product_Request__c currentProductRequest = [
               SELECT Id, Product_Request_Status__c 
               FROM Product_Request__c
               WHERE Id =: recordId
               WITH SECURITY_ENFORCED 
          ];

          if(currentProductRequest.Product_Request_Status__c == 'Completed'){
               isStatusCompleted = true;
          }

          for(Related_Product_Request__c rpr: [   
               SELECT Course__r.Product_Request_Status__c,
               Program__r.Product_Request_Status__c
               FROM Related_Product_Request__c
               WHERE Program__c =: recordId 
               AND Course__c != null
               WITH SECURITY_ENFORCED ]){
                    cceProductsSet.add(rpr.Course__c);
          }  

          for(Associated_Products__c assocProd:[  
               SELECT Id, Product__c, IsActive__c, 
               Product_Request__r.Product_Request_Status__c
               FROM Associated_Products__c 
               WHERE Product_Request__c =: recordId
               WITH SECURITY_ENFORCED ]){
                    productToAsocProdMap.put(assocProd.Product__c,assocProd);
          }                                              
          

          List<Product2> productList =[   
               SELECT Id, Name, Program_Plan__r.Product_Request__c, 
               Program_Plan__r.RecordType.Name,
               Course__r.ProductRequestID__c, Course__r.RecordType.Name, 
               Course__r.ProductRequestID__r.Product_Request_Status__c,
               Program_Plan__r.Product_Request__r.Product_Request_Status__c,
               Start_Date__c, End_Date__c, Available_On_Cart__c,
                    (    SELECT Id, UnitPrice, Pricebook2.IsStandard, Discount__c 
                         FROM PricebookEntries 
                         WHERE (Pricebook2.IsStandard = true  
                         OR (Pricebook2Id =: priceBookId 
                         AND IsActive = true))) 
               FROM Product2 
               WHERE Id IN: productToAsocProdMap.keySet() 
               OR Course__r.ProductRequestID__c IN: cceProductsSet
               OR Program_Plan__r.Product_Request__c IN: cceProductsSet
               WITH SECURITY_ENFORCED ];
          
          return buildProductsTable(productList);
     }  

     private static List<ProductDetails> buildProductsTable(List<Product2> productList){

          List<ProductDetails> productDetails = new List<ProductDetails>();

          for(Product2 product : productList){
               ProductDetails productDetail = new ProductDetails();

               if(product.Course__r.RecordType != null){
                    productDetail.courseRecordType = product.Course__r.RecordType.Name;
                    productDetail.status = product.Course__r.ProductRequestID__r.Product_Request_Status__c;
                    productDetail.idUrl = '/' + product.Course__r.ProductRequestID__c;
               }else{
                    productDetail.courseRecordType = product.Program_Plan__r.RecordType.Name;
                    productDetail.status = product.Program_Plan__r.Product_Request__r.Product_Request_Status__c;
                    productDetail.idUrl = '/' + product.Program_Plan__r.Product_Request__c;
               }

               productDetail.productName = product.Name;
               productDetail.startDate = product.Start_Date__c;
               productDetail.id = product.Id;
               productDetail.priceBookId = priceBookId;
               productDetail.isActive = product.Available_On_Cart__c;
               productDetail.isOPE = false;

               if(productToAsocProdMap.containsKey(product.Id)){
                    productDetail.isActive = productToAsocProdMap.get(product.Id).IsActive__c;
                    productDetail.isOPE = true;
                    productDetail.assocProdId = productToAsocProdMap.get(product.Id).Id;
               }

               for(PricebookEntry pricebookEntry : product.PricebookEntries){
                    if(pricebookEntry.Pricebook2.IsStandard == true){
                         productDetail.standardPrice = priceBookEntry.UnitPrice;
                    }else{
                         productDetail.ccePrice = pricebookEntry.UnitPrice;
                         productDetail.ccePriceBookEntryId = pricebookEntry.Id;
                         productDetail.discount = pricebookEntry.Discount__c;
                    }                   
               } 
               productDetail.isStatusCompleted = isStatusCompleted;
               productDetails.add(productDetail);
          }

          return productDetails;
     }

     @AuraEnabled(cacheable=true)
     public static List<ProductDetails> getProducts(String recordId){    
          List<ProductDetails> productDetails =  new List<ProductDetails>();
          List<Product2> productList =[      SELECT Id, Name, Course__r.RecordType.Name, 
                                             Start_Date__c, End_Date__c, Program_Plan__r.RecordType.Name
                                             FROM Product2 
                                             WHERE Available_on_Cart__c = true 
                                             AND Id NOT IN (SELECT Product__c 
                                                            FROM Associated_Products__c 
                                                            WHERE Product_Request__c =: recordId) 
                                             AND ((Course__r.ProductRequestId__r.Product_Specification__r.RecordType.DeveloperName = 'OPE'
                                             AND Course__r.ProductRequestId__r.Child_of_Prescribed_Program__c = false) 
                                             OR ( Program_Plan__r.Product_Request__r.Product_Specification__r.RecordType.DeveloperName = 'OPE'
                                             AND Program_Plan__r.Program_Delivery_Structure__c != 'Flexible Program'))];

          for(Product2 product : productList){
               ProductDetails productDetail = new ProductDetails();
               productDetail.courseRecordType = product.Course__r.RecordType != null ? product.Course__r.RecordType.Name:product.Program_Plan__r.RecordType.Name;      
               productDetail.productName = product.Name;
               productDetail.startDate = product.Start_Date__c;
               productDetail.endDate = product.End_Date__c;
               productDetail.id = product.Id;
               productDetails.add(productDetail);
          }
          
          return productDetails;
     }



     @AuraEnabled
     public static void upsertPricebookEntries(List<PricebookEntry> pbToUpsert){
          if(!pbToUpsert.isEmpty()){
               upsert pbToUpsert;
          }
     }

     @AuraEnabled
     public static void upsertAssociatedProducts(List<Associated_Products__c> assocProdToUpsert){
          if(!assocProdToUpsert.isEmpty()){
               upsert assocProdToUpsert;
          }
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
          @AuraEnabled
          public Decimal ccePrice;
          @AuraEnabled
          public String priceBookId;
          @AuraEnabled
          public String ccePriceBookEntryId;
          @AuraEnabled
          public Decimal discount;
          @AuraEnabled
          public Boolean isActive;
          @AuraEnabled
          public Boolean isOPE;
          @AuraEnabled
          public String assocProdId;
          @AuraEnabled
          public String idUrl;
          @AuraEnabled
          public String status;
          @AuraEnabled
          public Boolean isStatusCompleted;
     }
}