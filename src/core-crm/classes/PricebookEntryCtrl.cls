/**
 * @description Controller Class for productPricing LWC
 * @see ../lwc/productPricing
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | arsenio.jr.dayrit         | February 07, 2022     | DEPP-1406            | Created file                               |
      | roy.nino.s.regala         | February 11, 2022     | DEPP-1406,1773,1257  | Added return for products and pricebook    |
      | john.bo.a.pineda          | May 13, 2022          | DEPP-2591            | Added logic for BuyerGroup PriceBook       |
      | roy.nino.s.regala         | Aug 5, 2022           | DEPP-2498            | Added logic for BuyerGroup PriceBook       |
      | kathy.cornejo             | September 22, 2022    | DEPP-4394            | Fixed Pricing for Program w/o Pathway      |
 */
public with sharing class PricebookEntryCtrl {
    public static List<String> priceBookIdsOPE = new List<String>();
    /**
     * @description fetches List Price  and pricebooks related to the product request
     * @param prodReqId - id of product request
     * @return  ResponseWrapper - contains list of pricebooks and pricebookentries and product
     */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getPricebookEntries(String prodReqId){

        String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
        String PR_PWP = System.Label.RT_ProductRequest_Program_Without_Pathway;
        ResponseWrapper response = new ResponseWrapper();
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        List<BuyerGroupPricebook> priceBookListOPE = new List<BuyerGroupPricebook>();
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();
        Product2 product = new Product2();
        List<hed__Program_Plan__c> program = new List<hed__Program_Plan__c>();
        List<hed__Course__c> course = new List<hed__Course__c>();
        Set<String> priceBookIdsSet = new Set<String>();

        Product_Request__c prodRecList1 = [SELECT Id, Name, RecordTypeId, RecordType.developerName, Product_Specification__r.RecordType.DeveloperName FROM Product_Request__c WHERE Id = : prodReqId];

        if(prodRecList1.RecordType.developerName == PR_PROGRAM || prodRecList1.RecordType.developerName == PR_PWP){
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

        priceBookListOPE = [Select Id, BuyerGroup.Name, Pricebook2Id from BuyerGroupPricebook WHERE BuyerGroup.Name = 'OPE BuyerGroup' AND Pricebook2.IsActive = true];
        if(!priceBookListOPE.isEmpty()){
            for(BuyerGroupPricebook pb: priceBookListOPE){
                priceBookIdsOPE.add(pb.Pricebook2Id);
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
        
        priceBookList = [SELECT Id, Name, IsStandard FROM PriceBook2 WHERE IsActive = true AND ID NOT IN: priceBookIdsSet AND (IsStandard = true OR ID IN:priceBookIdsOPE) ORDER BY Name,IsStandard DESC];
       
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
                                                                  FROM PricebookEntry WHERE Product2Id =: prod.Id AND (Pricebook2.IsStandard = true OR Pricebook2Id IN :priceBookIdsOPE) ORDER BY CreatedDate]);
        return response;
    }

    @AuraEnabled
    public static void upsertPricebookEntries(List<PricebookEntry> pbToUpsert){
        upsert pbToUpsert;

        // Get OPE Buyer Group Id
        Id opeBuyerGroupId = [SELECT Id FROM BuyerGroup WHERE Name = 'OPE BuyerGroup' LIMIT 1].Id;

        // Get Set of PriceBook Ids from PBEntries to be saved
        Set<Id> pbIdSet = new Set<Id>();
        for(PricebookEntry pb : pbToUpsert){
            pbIdSet.add(pb.Pricebook2Id);
        }

        // Get Non-Standard PriceBook Ids
        Set<Id> pbIdNonStandardSet = (new Map<Id, Pricebook2>([SELECT Id FROM Pricebook2 WHERE Id IN :pbIdSet AND IsStandard = FALSE])).keySet();

        // Get Buyer Group PriceBook Ids
        Set<Id> bgPriceBookIdSet =  new Set<Id>();
        List<BuyerGroupPricebook> bgPriceBookList = [SELECT Id, Pricebook2Id FROM BuyerGroupPricebook WHERE Pricebook2Id IN :pbIdNonStandardSet];
        for(BuyerGroupPricebook bgPriceBook : bgPriceBookList){
            bgPriceBookIdSet.add(bgPriceBook.Pricebook2Id);
        }

        // Process Data
        List<BuyerGroupPricebook> insertBGPriceBookList = new List<BuyerGroupPricebook>();
        for(Id pbId : pbIdNonStandardSet){
            // Check if PriceBook Id is not yet configured on Buyer Group PriceBook Ids
            if(!bgPriceBookIdSet.contains(pbId)){
                BuyerGroupPricebook bgPriceBook = new BuyerGroupPricebook();
                bgPriceBook.BuyerGroupId = opeBuyerGroupId;
                bgPriceBook.Pricebook2Id = pbId;
                bgPriceBook.IsActive = true;
                insertBGPriceBookList.add(bgPriceBook);
            }
        }

        if(insertBGPriceBookList.size() > 0){
            insert insertBGPriceBookList;
        }
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