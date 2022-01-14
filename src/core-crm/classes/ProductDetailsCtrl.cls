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
            courseOfferings = [SELECT Id, hed__Start_Date__c, Available_Seats__c	
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
     * @description inserts new contacts and course connections with link to selected offering
     * @param learnerInfoList - ids of contact records 
     * @param wrappedData - data aside from contact (course offering ID)
     */
    @AuraEnabled
    public static void insertLearnerInfo(List<Contact> learnerInfoList, WrapperClass wrappedData){
        try {
            List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

            insert(learnerInfoList);
            for(Contact con: learnerInfoList){

                courseConnectionList.add(new hed__Course_Enrollment__c(
                    hed__Contact__c = con.Id,
                    hed__Course_Offering__c = Id.valueOf(wrappedData.courseOfferingId),
                    hed__Status__c = 'Current'));
            }
            insert(courseConnectionList);
        } catch (Exception e) {
            system.debug(e);
            system.debug('error on ProductDetailsCtrl.insertLearnerInfo');
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            throw auraEx;
        }
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

    /**
     * @description wrapper that contains the additional data needed to insert records
     */
    public class WrapperClass{
        @AuraEnabled
        public String courseOfferingId {get; set;}
    }
}
