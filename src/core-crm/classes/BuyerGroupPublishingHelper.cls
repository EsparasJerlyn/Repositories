/**
 * @description Helper class for Publishing of Buyer Group from BuyerGroupTriggerHandler
 * @see BuyerGroupTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | eccarius.munoz                 | November 22, 2022     | DEPP-4014              | Created File                                                       |
 */
public with sharing class BuyerGroupPublishingHelper {

    public static void validateExistingPublishedBuyerGroup(List<Id> idsToPublish, Map<Id,BuyerGroup> newMap){
        if(!idsToPublish.isEmpty()){
            BuyerGroupTriggerHelper.validateExistingPublishedBuyerGroup(idsToPublish, newMap);
            BuyerGroupTriggerHelper.validatePublishing(idsToPublish,newMap);
        }
    }

    public static void publishParentProductRequest(Set<Id> idsToPublish){
        if(!idsToPublish.isEmpty()){
            BuyerGroupTriggerHelper.publishParentProductRequest(idsToPublish);
        }
    }
    
    public static void completeParentProductRequest(Map<Id,BuyerGroup> prodReqToBgMap){
        if(!prodReqToBgMap.keySet().isEmpty()){
            BuyerGroupTriggerHelper.completeParentProductRequest(prodReqToBgMap);
        }
    }

    public static Set<Id> getProductRequestToPublish(BuyerGroup bg, Map<Id,BuyerGroup> oldMap){
        Set<Id> response = new Set<Id>();

        if( ( bg.Ready_for_Publishing__c != oldMap.get(bg.Id).Ready_for_publishing__c || 
              bg.Publishing_Start_Date__c != oldMap.get(bg.Id).Publishing_Start_Date__c ) && 
              bg.Ready_for_publishing__c == 'Yes' && 
              bg.Publishing_Start_Date__c <= Date.Today() &&
              ( bg.Publishing_End_date__c == null || 
                bg.Publishing_End_date__c > date.today()) &&
                bg.Product_Request__c != null){

                    response.add(bg.Product_Request__c); 
        }

        return response;
    }

    public static Map<Id,BuyerGroup> getProdReqToBgMap(BuyerGroup bg, Map<Id,BuyerGroup> oldMap){
        Map<Id,BuyerGroup> response = new Map<Id,BuyerGroup>();
        if( ( bg.Decommission__c != oldMap.get(bg.Id).Decommission__c || 
                bg.End_Date__c != oldMap.get(bg.Id).End_Date__c) && 
                bg.End_Date__c <= Date.Today() && 
                bg.Decommission__c == true && 
                bg.Product_Request__c != null){
                    response.put(bg.Product_Request__c, bg);
        }

        return response;
    }

    public static Map<Id, Id> getProductRequestMap(Map<Id, BuyerGroup> newBuyerGroup, List<Id> buyerGroupIds){
        Map<Id, Id> productRequestMap = new Map<Id, Id>();
        for(Id item: buyerGroupIds){
            if(newBuyerGroup.containsKey(item) && newBuyerGroup.get(item).Product_Request__c != null){
                productRequestMap.put(newBuyerGroup.get(item).Product_Request__c,item);
            }
        }

        return productRequestMap;
    }

    public static Map<Id,Associated_Products__c> getAssociatedProductsMap(Map<Id, Id> productRequestMap){
        Map<Id,Associated_Products__c> associatedProductsMap = new Map<Id,Associated_Products__c>();
        List<Associated_Products__c> assocProdList = [
            SELECT Id, Product__r.Available_On_Cart__c, Product_Request__c 
              FROM Associated_Products__c 
             WHERE Product_Request__c IN: productRequestMap.keySet() 
               AND Product__r.Available_On_Cart__c = false
               AND IsActive__c = true WITH SECURITY_ENFORCED
        ];

        for(Associated_Products__c aProd : assocProdList){
            associatedProductsMap.put(productRequestMap.get(aProd.Product_Request__c),aProd);
        }

        return associatedProductsMap;
    }

    public static Map<Id,Id> getChildParentRequestMap(Map<Id, Id> productRequestMap){
        Map<Id,Id> childParentRequestMap = new Map<Id,Id>();
        List<Related_Product_Request__c> relatedProductReqList = [
            SELECT Id, Course__c, Program__c
              FROM Related_Product_Request__c
             WHERE Program__c IN: productRequestMap.keySet()
               AND Course__c != null WITH SECURITY_ENFORCED
        ];
        for(Related_Product_Request__c rProdReq : relatedProductReqList){
            childParentRequestMap.put(rProdReq.Course__c,rProdReq.Program__c);
        }

        return childParentRequestMap;
    }

    public static Map<Id,Id> getBuyerGroupToProductMap(Map<Id, Id> childParentRequestMap, Map<Id, Id> productRequestMap){
        Map<Id,Id> buyerGroupToProductMap = new Map<Id,Id>();
        List<Product2> productList = [
            SELECT Id, Available_On_Cart__c, Course__r.ProductRequestID__c, Program_Plan__r.Product_Request__c
              FROM Product2
             WHERE (Course__r.ProductRequestID__c IN: childParentRequestMap.keySet() 
                OR Program_Plan__r.Product_Request__c IN: childParentRequestMap.keySet())
               AND Available_On_Cart__c = false WITH SECURITY_ENFORCED
        ];
        for(Product2 prod : productList){
            buyerGroupToProductMap = buyerGrpToProduct(prod, childParentRequestMap, productRequestMap);
        }

        return buyerGroupToProductMap;
    }

    private static Map<Id,Id> buyerGrpToProduct(Product2 prod, Map<Id, Id> childParentRequestMap, Map<Id, Id> productRequestMap){
        Map<Id,Id> buyerGroupToProductMap = new Map<Id,Id>();
        if( prod.Course__c != null &&
            prod.Course__r.ProductRequestID__c != null &&
            childParentRequestMap.containsKey(prod.Course__r.ProductRequestID__c) &&
            productRequestMap.containsKey(childParentRequestMap.get(prod.Course__r.ProductRequestID__c))){

            buyerGroupToProductMap.put(productRequestMap.get(childParentRequestMap.get(prod.Course__r.ProductRequestID__c)), prod.Id);

        }else if( prod.Program_Plan__c != null &&
                prod.Program_Plan__r.Product_Request__c != null &&
                childParentRequestMap.containsKey(prod.Program_Plan__r.Product_Request__c) &&
                productRequestMap.containsKey(childParentRequestMap.get(prod.Program_Plan__r.Product_Request__c))){
                
                buyerGroupToProductMap.put(productRequestMap.get(childParentRequestMap.get(prod.Program_Plan__r.Product_Request__c)), prod.Id);  
        } 

        return buyerGroupToProductMap;
    }
}
