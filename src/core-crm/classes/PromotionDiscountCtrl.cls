/**
 * @description helper class for promotion and discount calculations
 * @see ../lwc/manageRegistrationSection
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      | roy.nino.s.regala         | November 23, 2022     | DEPP-4721            | Created file                 |
*/

public without sharing class PromotionDiscountCtrl{

      /**
      * @description fetches the discount data
      * @param selectedPBId - current selected pricebook
      * @param standardPBId - standard pricebook of the product
      * @param offeringId - offering ID
      * @param prescribedProgram - prescribed program or not
      * @param couponCode - coupon enetered
      * @return discount - applicable discount
      */
     @AuraEnabled(cacheable=true)
     public static DiscountData getDiscount(String selectedPBId, String standardPBId, String offeringId, Boolean prescribedProgram, String couponCode) {
          
          DiscountData discountData = new DiscountData();
          discountData.promotionId = '';
          discountData.discount = 0;
          //get the product to search
          Product2 product = getProduct(offeringId, prescribedProgram);

          //query the promotion
          List<Promotion> promotionList = [
               SELECT 
                    Id,
                    Name,
                    IsActive,
                    (SELECT Id, Name, CouponCode FROM PromotionCoupons),
                    (SELECT Id, Name, AdjustmentType, AdjustmentPercent, AdjustmentAmount, TargetType, TargetId FROM PromotionTargets),
                    (SELECT Id, Name, Promotion__c, IsActive__c, Product__c FROM Promotion_Products__r WHERE IsActive__c = true)
               FROM
                    Promotion
               WHERE
                    IsActive = TRUE
                    AND Promotion.Id IN (
                         SELECT PromotionId
                         FROM Coupon
                         WHERE
                         CouponCode = :couponCode
                         AND Status = 'Active'
                         AND StartDateTime < :system.now()
                         AND EndDateTime > :system.now()
                    )
                    AND Promotion.Id IN (
                         SELECT PromotionId
                         FROM PromotionTarget
                         WHERE (TargetType = 'Product' AND TargetId = :product.Id)
                         OR (TargetType = 'ProductCategory')
                         OR TargetType = 'Transaction'
                    )
          ];

          //retrieve the pricebook selected and standard
          Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>(
               [
                    SELECT Id, Pricebook2.Name, UnitPrice
                    FROM PricebookEntry
                    WHERE Id = :selectedPBId OR Id = :standardPBId
               ]
          );

          Double discount = 0;
          Double discountedPrice;
          Double standardPrice = pbEntryMap.get(standardPBId).UnitPrice;
          Double selectedPrice = pbEntryMap.get(selectedPBId).UnitPrice;

          //if no promotion retrieved with the criteria
          if(promotionList.size() == 0){
               //set to -1 to identify as invalid coupon
               discount = -1;
          }

          //loop on all the options
          for (Promotion currentPromotion : promotionList) {
               discountData.promotionId = currentPromotion.Id;

               //loop in the PromotionTarget for in case of multiple promotions
               for (PromotionTarget currentPromotionTarget : currentPromotion.PromotionTargets){

                    //check if targetype is per product or total transaction
                    if(currentPromotionTarget.TargetType == 'Transaction'){

                         if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
                              //set the discount amount
                              discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                         }
               
                    //else if for product specific
                    } else if(currentPromotionTarget.TargetType == 'Product'){

                         if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal' || currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice'){
                              //set the discount amount
                              discount = (currentPromotionTarget.AdjustmentAmount).setScale(2);

                         } else if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount'){
                              //set the discount amount
                              discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                         } 

                     //else if for product category
                    } else if(currentPromotionTarget.TargetType == 'ProductCategory'){

                         //create a set of product Ids that are present in the Promotion_Products__r
                         Set<String> productPromotionIds = new Set<String>();
                         for (Promotion_Product__c currentPromotionProduct : currentPromotion.Promotion_Products__r) {
                              productPromotionIds.add(currentPromotionProduct.Product__c);
                         }

                         //check if the product is found in the Promotion_Products__c
                         if(productPromotionIds.contains(product.Id)){

                              if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal' || currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice'){
                                   //set the discount amount
                                   discount = (currentPromotionTarget.AdjustmentAmount).setScale(2);
     
                              } else if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount'){
                                   //set the discount amount
                                   discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                              } 

                         //else not found
                         }else{
                              //set to -1 to identify as invalid coupon
                              discount = -1;
                         }
                    }
               }
          }

          //set the maximum discount to the standard price only
          if(discount > standardPrice){
               discount = standardPrice;
          }

          //set the discounted price
          discountedPrice =  standardPrice - discount;

          //check if selected price is still less than standard - discount
          if(discount != -1 && selectedPrice <= discountedPrice){
               //-2 to identify that the selected pricebook is still less 
               discount = -2;
          }

          discountData.discount = discount;
          return discountData;
     }

     /**
     * Retrieves Product based on offering id
     * @param <Id> offeringId
     * @return Id
     */
    public static Product2 getProduct(Id offeringId, Boolean isPrescribedProgram){
     Product2 response = new Product2();

     Id filter;
     Id prodId;

     List<Product2> productList = new List<Product2>();

     if(!isPrescribedProgram){

          List<hed__Course_Offering__c> courseOfferingList = [
               SELECT Id, hed__Course__c 
               FROM hed__Course_Offering__c 
               WHERE Id =: offeringId 
               WITH SECURITY_ENFORCED
               LIMIT 1];

          for(hed__Course_Offering__c courseOffering : courseOfferingList){
               filter = courseOffering.hed__Course__c;
          }
          productList = [
               SELECT Id, Name, Product_Category__c 
               FROM Product2
               WHERE Course__c =: filter
               WITH SECURITY_ENFORCED];
     }else{
          List<Program_Offering__c> programOfferingList = [
               SELECT Id, hed_Program_Plan__c 
               FROM Program_Offering__c 
               WHERE Id =: offeringId
               WITH SECURITY_ENFORCED
               LIMIT 1];
          for(Program_Offering__c programOffering : programOfferingList){
               filter = programOffering.hed_Program_Plan__c;
          }
          productList = [
               SELECT Id, Name, Product_Category__c 
               FROM Product2 
               WHERE Program_Plan__c  =: filter
               WITH SECURITY_ENFORCED];
     }

     for(Product2 prod : productList){
          response = prod;
     }

     return response;
}

     private class DiscountData {
          @AuraEnabled 
          public Double discount;
          @AuraEnabled 
          public String promotionId;
     }
}