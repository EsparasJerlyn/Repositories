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
      |                           |                       |                      |                              | 
 */
public with sharing class AddAssociatedProductsCtrl {

     private static final String SUCCESS_RESPONSE = 'Success';
     private static final String DEFAULT_REC_TYPE = 'Program Plan';
     
     /**
      * @description Retrieves list of Active OPE Products based on Product Request
      * @param recordId - Record ID from record page
      * @return List of ProductDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<ProductDetails> getProducts(String recordId){    
         List<ProductDetails> productDetails =  new List<ProductDetails>();
         List<Product2> productList =[SELECT Id, Name, Course__r.RecordType.Name, Start_Date__c, End_Date__c, (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true AND IsActive = true) 
                                        FROM Product2 
                                       WHERE IsActive = true AND Family = 'OPE' AND Id NOT IN (SELECT Product__c FROM Associated_Products__c WHERE Product_Request__c =: recordId)];
                  
         for(Product2 product : productList){
              ProductDetails productDetail = new ProductDetails();
              productDetail.courseRecordType = product.Course__r.RecordType != null ? product.Course__r.RecordType.Name:DEFAULT_REC_TYPE;      
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
               for(String productId : productIds){
                    Associated_Products__c associatedProductToAdd = new Associated_Products__c();
                    associatedProductToAdd.Product__c = productId;
                    associatedProductToAdd.Product_Request__c  = productRequestId;
                    associatedProductList.add(associatedProductToAdd);
               }
               insert associatedProductList;
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