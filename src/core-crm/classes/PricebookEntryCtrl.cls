
/**
 * @description Controller Class for productPricing LWC
 * @see ../lwc/productPricing
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | arsenio.jr.dayrit         | February 07, 2022     | DEPP-1406            | Created file                               |
      | roy.nino.s.regala         | February 11, 2022     | DEPP-1406,1773,1257  | Added return for products and pricebook    | 
 */
public with sharing class PricebookEntryCtrl {
    /**
     * @description fetches List Price  and pricebooks related to the product request
     * @param prodReqId - id of product request
     * @return  ResponseWrapper - contains list of pricebooks and pricebookentries and product
     */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getPricebookEntries(String prodReqId){ 

        String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
        ResponseWrapper response = new ResponseWrapper();
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();
        Product2 product = new Product2();
        List<hed__Program_Plan__c> program = new List<hed__Program_Plan__c>();
        List<hed__Course__c> course = new List<hed__Course__c>();
        Set<String> priceBookIdsSet = new Set<String>();

        Product_Request__c prodRecList1 = [SELECT Id, Name,RecordTypeId, RecordType.developerName FROM Product_Request__c WHERE Id = : prodReqId];

        if(prodRecList1.RecordType.developerName == PR_PROGRAM){
            program = [SELECT Id, Name, Product_Request__c, (SELECT Id, Name FROM Products__r) FROM hed__Program_Plan__c WHERE Product_Request__c =: prodReqId];
            if(!program.isEmpty() && !program[0].Products__r.isEmpty()){
                product = program[0].Products__r[0];
            }
        }else{
            course = [SELECT Id, Name, ProductRequestID__c, (SELECT Id, Name FROM Products__r) FROM hed__Course__c WHERE ProductRequestID__c =: prodReqId];
            if(!course.isEmpty() && !course[0].Products__r.isEmpty()){
                product = course[0].Products__r[0];
            }
        }

        if(product != null){
            priceBookEntries = getPBEntries(product);
        }

        if(!priceBookEntries.isEmpty()){
            for(PriceBookEntry pbWrapper:priceBookEntries){
                priceBookIdsSet.add(pbWrapper.Pricebook2Id);
            }
        }

        priceBookList = [SELECT Id, Name, IsStandard FROM PriceBook2 WHERE IsActive = true AND ID NOT IN: priceBookIdsSet ORDER BY Name,IsStandard DESC];

        response.priceBookEntries = priceBookEntries;
        response.priceBooks = priceBookList;
        response.product = product;
        return response;

    }

    /**
     * @description fetches pricebook entries related to the product and productrequest
     * @param prodReqId - id of product request
     * @return  ResponseWrapper - contains list of pricebooks and pricebookentries and product  
     */
    @AuraEnabled (cacheable=true)
    public static List<PriceBookEntry> getPBEntries(Product2 prod){
        List<PriceBookEntry> response = new List<PriceBookEntry>([SELECT Id, UnitPrice, Product2Id, Pricebook2Id, Pricebook2.Name,Pricebook2.IsStandard, Discount__c, Early_Bird_No_of_Days__c, IsActive 
                                                                  FROM PricebookEntry WHERE Product2Id =: prod.Id ORDER BY CreatedDate]);
        return response;
    }

    @AuraEnabled 
    public static void upsertPricebookEntries(List<PricebookEntry> pbToUpsert){
        upsert pbToUpsert;
    }

    public class ResponseWrapper {
        @AuraEnabled 
        public List<PriceBookEntry> priceBookEntries;
        @AuraEnabled 
        public List<PriceBook2> priceBooks;
        @AuraEnabled 
        public Product2 product;
    }
}