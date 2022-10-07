/**
 * @description Controller Class for cceManageRegistrationSection LWC
 * @see ../lwc/cceManageRegistrationSection
 * 
 * @author Accenture
 * 
 * @history
 *  | Developer                 | Date                  | JIRA                 | Change Summary                  |
    |---------------------------|-----------------------|----------------------|---------------------------------|
    | roy.nino.s.regala         | Aug 01, 2022          | DEPP-2498            | Created file                    | 
    | kathy.cornejo             | Sept 28, 2022         | DEPP-4460            | Fixed Pricing for CCE           | 
*/
public without sharing class CceManageRegistrationSectionCtrl {

    /**
     * @description retrieves learners related to the child PRs
    * @param prodReqId - Record ID from record page
    * @return List of LearnerDetails
    */
    @AuraEnabled(cacheable=true)
    public static List<LearnerDetails> getLearnerDetails(String productReqId){
        Set<Id> childProdRequestIds = new Set<Id>();
        Set<String> pbEntryIds = new Set<String>();
        Set<String> pbIds = new Set<String>();
        List<LearnerDetails> learnerDetailsList = new List<LearnerDetails>();
        List<BuyerGroupPriceBook> buyerGroupPBList = new List<BuyerGroupPriceBook>([
            SELECT Id, Pricebook2Id FROM BuyerGroupPriceBook 
            WHERE BuyerGroup.Product_Request__c =: productReqId
        ]);

        for(BuyerGroupPriceBook bgPb:buyerGroupPBList){
            pbIds.add(bgPb.Pricebook2Id);
        }

        for(PriceBookEntry pbE: [SELECT Id FROM PricebookEntry WHERE Pricebook2Id IN:pbIds]){
            pbEntryIds.add(pbE.Id);
        }


        for(Related_Product_Request__c rpr: [   SELECT Course__c
                                                FROM Related_Product_Request__c
                                                WHERE Program__c =: productReqId]){
                                                childProdRequestIds.add(rpr.Course__c);
                                            }
        for(Associated_Products__c assocProd:[  SELECT Id,Product__r.Course__r.ProductRequestID__c, 
                                                Product__r.Program_Plan__r.Product_Request__c, IsActive__c
                                                FROM Associated_Products__c 
                                                WHERE Product_Request__c =: productReqId]){
                                                    if( assocProd.Product__c != null &&
                                                        assocProd.Product__r.Course__c != null &&
                                                        assocProd.Product__r.Course__r.ProductRequestID__c != null){
                                                            childProdRequestIds.add(assocProd.Product__r.Course__r.ProductRequestID__c);
                                                    }else if(
                                                        assocProd.Product__c != null &&
                                                        assocProd.Product__r.Program_Plan__c != null &&
                                                        assocProd.Product__r.Program_Plan__r.Product_Request__c != null){
                                                            childProdRequestIds.add(assocProd.Product__r.Program_Plan__r.Product_Request__c);
                                                    }
                                                }

        List<hed__Course_Enrollment__c> learnerList = new List<hed__Course_Enrollment__c>(
                [
                    SELECT Id, CreatedDate, Course_Name__c, hed__Contact__r.Name, Amount__c, Cart_Item__r.TotalPrice, hed__Status__c
                    FROM hed__Course_Enrollment__c
                    WHERE (hed__Course_Offering__r.hed__Course__r.ProductRequestID__c IN: childProdRequestIds 
                    OR Program_Offering__r.hed_Program_Plan__r.Product_Request__c IN: childProdRequestIds) 
                    AND ((RecordType.DeveloperName = 'Student' 
                    AND Program_Offering__c = null) 
                    OR (RecordType.DeveloperName = 'Student_Program' 
                    AND hed__Course_Offering__c = null)) 
                    AND Cart_Item__r.Pricebook_Entry_ID__c IN: pbEntryIds
                ]
        );

        for(hed__Course_Enrollment__c courseCon: learnerList){
            LearnerDetails learnerDetails = new LearnerDetails();

            learnerDetails.id = courseCon.Id;
            learnerDetails.status = courseCon.hed__Status__c;
            learnerDetails.contactName = courseCon.hed__Contact__r.Name;
            learnerDetails.productName = courseCon.Course_Name__c;
            learnerDetails.registrationDate = courseCon.CreatedDate;
            if (courseCon.Cart_Item__c != null && courseCon.Cart_Item__r.TotalPrice != null){
                learnerDetails.price = coursecon.Cart_Item__r.TotalPrice;
            }
            else {
                learnerDetails.price = courseCon.Amount__c;
            }

            learnerDetailsList.add(learnerDetails);
        }                                        

        return learnerDetailsList;
    }

    /**
     * @description updates learners
    * @param prodReqId - Record ID from record page
    * @return List of LearnerDetails
    */
    @AuraEnabled
    public static void updateLearners(List<hed__Course_Enrollment__c> learners){
        if(!learners.isEmpty()){
            update learners;
        }
    }

    /**
    * @description Wrapper class that holds data to be displayed
    */
    public class LearnerDetails{
         @AuraEnabled
         public String id;
         @AuraEnabled
         public String status;
         @AuraEnabled
         public String productName;
         @AuraEnabled
         public Datetime registrationDate;
         @AuraEnabled
         public Decimal price;
         @AuraEnabled
         public String contactName;
    }
}