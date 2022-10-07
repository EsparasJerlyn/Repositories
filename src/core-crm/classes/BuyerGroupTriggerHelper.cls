/**
 * @description trigger helper for buyergroup
 * @see BuyerGroupTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | roy.nino.s.regala              | July 29, 2022         | DEPP-2498              | Created file                                                       |
 */
public with sharing class BuyerGroupTriggerHelper{

  private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
  private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
  private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;
  /**
   * @description validate before publishing buyerGroup
   * @param buyerGroupIds - List of buyergroups to be published
   * @param newBuyerGroup - Map of BuyerGroup.Trigger.new
   */
  public static void validatePublishing(List<Id> buyerGroupIds, Map<Id, BuyerGroup> newBuyerGroup) {

    //maps product request -> buyer group
    Map<Id, Id> productRequestMap = new Map<Id, Id>(); 
    //maps buyer group -> associated product
    Map<Id,Associated_Products__c> associatedProductsMap = new Map<Id,Associated_Products__c>(); 
    //maps child to parent product requests
    Map<Id,Id> childParentRequestMap = new Map<Id,Id>();
    Map<Id,Id> buyerGroupToProductMap = new Map<Id,Id>();

    for(Id item: buyerGroupIds){
      if(newBuyerGroup.containsKey(item) && newBuyerGroup.get(item).Product_Request__c != null){
        productRequestMap.put(newBuyerGroup.get(item).Product_Request__c,item);
      }
    }

    if(!productRequestMap.keySet().isEmpty()){
      for(Associated_Products__c aProd: [ 
        SELECT Id, Product__r.Available_On_Cart__c, Product_Request__c 
        FROM Associated_Products__c 
        WHERE Product_Request__c 
        IN: productRequestMap.keySet() 
        AND Product__r.Available_On_Cart__c = false
        AND IsActive__c = true
      ]){
      associatedProductsMap.put(productRequestMap.get(aProd.Product_Request__c),aProd);
      }
    }

    if(!productRequestMap.keySet().isEmpty()){
      for(Related_Product_Request__c rProdReq: [
        SELECT Id, Course__c, Program__c
        FROM Related_Product_Request__c
        WHERE Program__c IN: productRequestMap.keySet()
        AND Course__c != null
      ]){
        childParentRequestMap.put(rProdReq.Course__c,rProdReq.Program__c);
      }
    }

    if(!childParentRequestMap.keySet().isEmpty()){
      for(Product2 prod: [
        SELECT Id, Available_On_Cart__c,
        Course__r.ProductRequestID__c,
        Program_Plan__r.Product_Request__c
        FROM Product2
        WHERE (Course__r.ProductRequestID__c IN: childParentRequestMap.keySet() 
        OR Program_Plan__r.Product_Request__c IN: childParentRequestMap.keySet())
        AND Available_On_Cart__c = false
      ]){
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
      }
    }
    
    for(Id item: buyerGroupIds){
      if( associatedProductsMap.containsKey(item) || 
          buyerGroupToProductMap.containsKey(item)){
          
          newBuyerGroup.get(item).addError('Ready_for_publishing__c', 'All products should be ready for publishing to publish this Product');
      }
    }

  }

  /**
   * @description publishes parent product request
   * @param productRequestIds - set of product request ids to be published
   */
  public static void publishParentProductRequest(Set<Id> productRequestIds) {
    List<Product_Request__c> productReqToPublish = new List<Product_Request__c>();
    Product_Request__c prTemp;

    for(Id prodReqId: productRequestIds){
      prTemp = new Product_Request__c(Id = prodReqId, Product_Request_Status__c = PR_PUBLISHED);

      productReqToPublish.add(prTemp);
    }

    if(!productReqToPublish.isEmpty()){
      update productReqToPublish;
    }
  }


  /**
   * @description completes parent product request
   * @param prodReqToBgMap - Map of product request against the buyergroup
   */
  public static void completeParentProductRequest(Map<Id,BuyerGroup> prodReqToBgMap) {
    List<Product_Request__c> productReqToComplete = new List<Product_Request__c>();
    Map<Id,BuyerGroup> childProdReqToBgMap = new Map<Id,BuyerGroup>();
    Map<Id,Product2> productsToDecomission = new Map<Id,Product2>();
    Map<Id,Associated_Products__c> ascProductsToDecomission = new Map<Id,Associated_Products__c>();
    Set<Id> childCCEProductRequest = new Set<Id>();
    List<Id> childCCEProduct = new List<Id>();
    Product_Request__c prTemp;

    for(Id prodReqId: prodReqToBgMap.keySet()){
      prTemp = new Product_Request__c(  Id = prodReqId, Product_Request_Status__c = PR_COMPLETED);
      productReqToComplete.add(prTemp);
    }

    if(!productReqToComplete.isEmpty()){
      update productReqToComplete;

      //after decommissioning parent product request
      //get child cce product request
      for(Related_Product_Request__c rpr: [ 
        SELECT Id, Program__c, Course__c
        FROM Related_Product_Request__c 
        WHERE Program__c IN: prodReqToBgMap.keySet()]){
          if(rpr.Course__c != null){
            childCCEProductRequest.add(rpr.Course__c);
            childProdReqToBgMap.put(rpr.Course__c,prodReqToBgMap.get(rpr.Program__c));
          }
      }

      for(Associated_Products__c ascProd: [
        SELECT Id, IsActive__c
        FROM Associated_Products__c
        WHERE Product_Request__c IN: prodReqToBgMap.keySet()
        AND IsActive__c = true
      ]){
        ascProd.IsActive__c = false;
        ascProductsToDecomission.put(ascProd.Id,ascProd);
      }

      //decommission child products
      for(Product2 prod:[
        SELECT Id, Decommission_Product__c, 
        Decommission_Reason__c, End_Date__c,
        Course__r.ProductRequestID__c,
        Program_Plan__r.Product_Request__c
        FROM Product2 
        WHERE Decommission_Product__c = false 
        AND (Course__r.ProductRequestID__c IN:childCCEProductRequest 
        OR Program_Plan__r.Product_Request__c IN:childCCEProductRequest)]){
          String productReqId = '';

          if(prod.Course__c != null && prod.Course__r.ProductRequestID__c != null){
            productReqId = prod.Course__r.ProductRequestID__c;
          }else{
            productReqId = prod.Program_Plan__r.Product_Request__c;
          }
          
          prod.End_Date__c = Date.Today();

          if( childProdReqToBgMap.containsKey(productReqId) &&
              childProdReqToBgMap.get(productReqId).Decommission__c == true &&
              childProdReqToBgMap.get(productReqId).Decommission_Reason__c != null){

              prod.Decommission_Product__c = true;
              prod.Decommission_Reason__c = childProdReqToBgMap.get(productReqId).Decommission_Reason__c;

          }

          productsToDecomission.put(prod.Id,prod);
      }
      if(!productsToDecomission.keySet().isEmpty()){
        update productsToDecomission.values();
      }
      if(!ascProductsToDecomission.keySet().isEmpty()){
        update ascProductsToDecomission.values();
      }
    }
  }

  



}