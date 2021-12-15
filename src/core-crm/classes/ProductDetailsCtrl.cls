/**
 * @description Controller Class for productDetails LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | December 03, 2021     | DEPP-116             | Created file                 |
      |                           |                       |                      |                              | 
 */
public with sharing class ProductDetailsCtrl {
    
     /**
     * @description fetches course offerings and pricebooks related to the product
     * @param productId - id of product on productdetailpage
     * @return course offerings and pricebook entries related to the product
     */
    @AuraEnabled(cacheable=true)    
    public static ProductDetailsData getProductRelatedRecords(Id productId){
        ProductDetailsData prodDetailsData = new ProductDetailsData();
        List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        Product2 productOnPage =[SELECT Id,Course__c, 
                                    (SELECT UnitPrice, Pricebook2.Name, Pricebook2.isStandard
                                    FROM PricebookEntries  
                                    WHERE IsActive = true ORDER BY CreatedDate,Pricebook2.IsStandard DESC)  
                                FROM Product2 WHERE Id =: productId];

        if(!productOnPage.PricebookEntries.isEmpty()){
            pricebookEntries = productOnPage.PricebookEntries;
        }

        if(productOnPage.Course__c != null){
            courseOfferings = [SELECT Id, hed__Start_Date__c, hed__Faculty__r.name, hed__Faculty__r.description, Available_Seats__c, hed__Faculty__r.PhotoUrl, hed__Facility__r.Display_Name__c	
                                FROM hed__Course_Offering__c 
                                WHERE hed__Start_Date__c > TODAY 
                                AND hed__Course__c =: productOnPage.Course__c
                                ORDER BY hed__Start_Date__c];
        }

        prodDetailsData.priceBookEntryList = pricebookEntries;
        prodDetailsData.courseOfferingList = courseOfferings;
        return prodDetailsData;
    }

    /**
     * @description wrapper that contains list of course offerings and pricebook entries
     */
    public class ProductDetailsData{
        @AuraEnabled
        public List<hed__Course_Offering__c> courseOfferingList;
        @AuraEnabled
        public List<PricebookEntry> priceBookEntryList;
    }
}
