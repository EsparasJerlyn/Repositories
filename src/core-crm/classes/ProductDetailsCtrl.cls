/**
 * @description Controller Class for productDetails and productDetailsDisplay LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | roy.nino.s.regala         | December 03, 2021     | DEPP-116             | Created file                               |
      | roy.nino.s.regala         | February 04, 2022     | DEPP-213             | Added insertion of Expression of Interest  | 
 */
public without sharing class ProductDetailsCtrl {
    
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
        List<hed__Course_Offering__c> filteredCourseOfferings = new List<hed__Course_Offering__c>();

        Product2 productOnPage =[SELECT Id,Course__c, Program_Plan__c,
                                    (SELECT UnitPrice, Pricebook2.Name, Pricebook2.isStandard
                                    FROM PricebookEntries  
                                    WHERE IsActive = true ORDER BY CreatedDate,Pricebook2.IsStandard DESC)  
                                FROM Product2 WHERE Id =: productId];

        if(!productOnPage.PricebookEntries.isEmpty()){
            pricebookEntries = productOnPage.PricebookEntries;
        }

        if(productOnPage.Course__c != null){
            
            courseOfferings = [SELECT Id, hed__Start_Date__c, Available_Seats__c, On_Hold_Seat__c	
                                FROM hed__Course_Offering__c 
                                WHERE hed__Start_Date__c > TODAY 
                                AND hed__Course__c =: productOnPage.Course__c
                                ORDER BY hed__Start_Date__c];

            for(hed__Course_Offering__c courseOffering : courseOfferings){
                Decimal availableSeatTemp = courseOffering.Available_Seats__c != null?courseOffering.Available_Seats__c:0;
                Decimal onHoldSeatTemp = courseOffering.On_Hold_Seat__c != null?courseOffering.On_Hold_Seat__c:0;
                Decimal answer = availableSeatTemp - onHoldSeatTemp;
                if( answer > 0){
                    filteredCourseOfferings.add(courseOffering);
                }
            }
        }

        prodDetailsData.priceBookEntryList = pricebookEntries;
        prodDetailsData.courseOfferingList = filteredCourseOfferings;
        prodDetailsData.productOnPage = productOnPage;
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

    @AuraEnabled
    public static void insertExpressionOfInterest(Id userId,Id productId){
        User loggedInUser = [SELECT Id, Contact.Id FROM User WHERE Id =: userId];
        List<Expression_of_Interest__c> existingInterest =  new List<Expression_of_Interest__c>([SELECT Id 
                                                                                                FROM Expression_of_Interest__c 
                                                                                                WHERE Contact__c =: loggedInUser.Contact.Id AND
                                                                                                Product__c =: productId AND
                                                                                                Type__c = 'Register Interest' AND
                                                                                                Status__c = 'Active']);
        if(!existingInterest.isEmpty()){
            AuraHandledException auraEx = new AuraHandledException('Register Interest Exists');
            throw auraEx;
        }else{
            Expression_of_Interest__c expressionOfInterest = new Expression_of_Interest__c( Contact__c = loggedInUser.Contact.Id, 
                                                                                            Product__c = productId,
                                                                                            Type__c = 'Register Interest',
                                                                                            Status__c = 'Active'); 
            insert(expressionOfInterest);   
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
        @AuraEnabled
        public Product2 productOnPage;
    }

    /**
     * @description wrapper that contains the additional data needed to insert records
     */
    public class WrapperClass{
        @AuraEnabled
        public String courseOfferingId {get; set;}
    }
}
