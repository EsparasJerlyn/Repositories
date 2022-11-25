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

     private static DiscountData discountData;
     private static Product2 product;

     @AuraEnabled(cacheable=true)
     public static DiscountData getDiscount(String discountWrapper) {

          DiscountWrapper parsedDiscountWrapper = new DiscountWrapper();
          Map<Id,Set<Id>> promotionToProductMap = new Map<Id,Set<Id>>();
          

          if(discountWrapper != ''){
               parsedDiscountWrapper = (DiscountWrapper) JSON.deserialize(discountWrapper, DiscountWrapper.class);
          }

          discountData = new DiscountData();
          discountData.promotionId = '';
          discountData.discount = 0;
          //get the product to search
          product = ManageRegistrationSectionHelper.getProduct(parsedDiscountWrapper.offeringId, parsedDiscountWrapper.prescribedProgram);

          //query the promotion
          List<Promotion> promotionList = new  List<Promotion>([
               SELECT 
                    Id,
                    Name,
                    IsActive
               FROM
                    Promotion
               WHERE
                    IsActive = TRUE
                    AND Promotion.Id IN (
                         SELECT PromotionId
                         FROM Coupon
                         WHERE
                         CouponCode = :parsedDiscountWrapper.couponCode
                         AND Status = 'Active'
                         AND StartDateTime < :system.now()
                         AND EndDateTime > :system.now()
                    )
                    AND Promotion.Id IN (
                         SELECT PromotionId
                         FROM PromotionTarget
                         WHERE (TargetType = 'Product' AND TargetId = :product.Id)
                         OR TargetType = 'ProductCategory'
                         OR TargetType = 'Transaction'
                    )
          ]);

          List<Promotion_Product__c> promotionProductsList = [
               SELECT Id, Name, Promotion__c, IsActive__c, Product__c 
               FROM Promotion_Product__c
               WHERE Promotion__c IN: promotionList
          ];

          List<PromotionTarget> promotionTargetList = [
               SELECT Id, Promotion__c, Name, AdjustmentType, AdjustmentPercent, AdjustmentAmount, TargetType, TargetId 
               FROM PromotionTarget
               WHERE PromotionId IN: promotionList
          ];

          for(Promotion_Product__c promProd: promotionProductsList){
               if(!promotionToProductMap.containsKey(promProd.Promotion__c)){
                    promotionToProductMap.put(promProd.Promotion__c, new Set<Id>());
               }
               promotionToProductMap.get(promProd.Promotion__c).add(promProd.Product__c);
          }

          //retrieve the pricebook selected and standard
          Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>(
               [
                    SELECT Id, Pricebook2.Name, UnitPrice
                    FROM PricebookEntry
                    WHERE Id = :parsedDiscountWrapper.selectedPBId OR Id = :parsedDiscountWrapper.standardPBId
               ]
          );

          Double discount = 0;
          Double discountedPrice;
          Double standardPrice = pbEntryMap.get(parsedDiscountWrapper.standardPBId).UnitPrice;
          Double selectedPrice = pbEntryMap.get(parsedDiscountWrapper.selectedPBId).UnitPrice;

          //if no promotion retrieved with the criteria
          if(promotionList.isEmpty()){
               //set to -1 to identify as invalid coupon
               discount = -1;
          }

          discount = calculateDiscount(promotionTargetList,promotionToProductMap,standardPrice);


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

     public static Decimal calculateDiscount(List<PromotionTarget> promotionTargetList, Map<Id,Set<Id>> promotionToProductMap, Double standardPrice){

          Decimal discount = 0;
          
          for(PromotionTarget currentPromotionTarget: promotionTargetList){

               discountData.promotionId = currentPromotionTarget.Promotion__c;

               //check if targetype is per product or total transaction
               if(  currentPromotionTarget.TargetType == 'Transaction' &&
                    currentPromotionTarget.AdjustmentType == 'PercentageDiscount'){
                         //set the discount amount
                         discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);

               //else if for product specific
               }else if(currentPromotionTarget.TargetType == 'Product'){

                    if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal' || currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice'){
                         //set the discount amount
                         discount = (currentPromotionTarget.AdjustmentAmount).setScale(2);

                    } else if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount'){
                         //set the discount amount
                         discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                    } 

                //else if for product category
               }else if(currentPromotionTarget.TargetType == 'ProductCategory'){

                    //check if the product is found in the Promotion_Products__c
                    if(promotionToProductMap.containsKey(currentPromotionTarget.Promotion__c) && promotionToProductMap.get(currentPromotionTarget.Promotion__c).contains(product.Id)){

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

          return discount;
     }

     public class DiscountData {
          @AuraEnabled 
          public Double discount;
          @AuraEnabled 
          public String promotionId;
     }

     public class DiscountWrapper {
          @AuraEnabled 
          public String standardPBId;
          @AuraEnabled 
          public String selectedPBId;
          @AuraEnabled 
          public String offeringId;
          @AuraEnabled 
          public Boolean prescribedProgram;
          @AuraEnabled 
          public String couponCode;
     }
}