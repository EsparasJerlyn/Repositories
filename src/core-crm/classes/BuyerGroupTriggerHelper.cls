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
      | eccarius.karl.munoz            | November 15, 2022     | DEPP-4014              | 1.) Removed validateAsset method.                                  |
      |                                |                       |                        | 2.) Added validateExistingPublishedBuyerGroup method to check      | 
      |                                |                       |                        |     existing Buyer Group record with Published status.             |
      | eccarius.karl.munoz            | November 22, 2022     | DEPP-4014              | Added BuyerGroupPublishingHelper call to fix PMD violations        |
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

    productRequestMap = BuyerGroupPublishingHelper.getProductRequestMap(newBuyerGroup, buyerGroupIds);

    if(!productRequestMap.keySet().isEmpty()){
      associatedProductsMap = BuyerGroupPublishingHelper.getAssociatedProductsMap(productRequestMap);
      childParentRequestMap = BuyerGroupPublishingHelper.getChildParentRequestMap(productRequestMap);
    }

    if(!childParentRequestMap.keySet().isEmpty()){
      buyerGroupToProductMap = BuyerGroupPublishingHelper.getBuyerGroupToProductMap(childParentRequestMap, productRequestMap);
    }
    
    BuyerGroupValidationWrapper buyerGroupValidationWrapper = new BuyerGroupValidationWrapper();
    buyerGroupValidationWrapper.buyerGroupIds = buyerGroupIds;
    buyerGroupValidationWrapper.associatedProductsMap = associatedProductsMap;
    buyerGroupValidationWrapper.buyerGroupToProductMap = buyerGroupToProductMap;
    buyerGroupValidationWrapper.newBuyerGroup = newBuyerGroup;

    validateReadyForPublishing(buyerGroupValidationWrapper);

  }  

  /**
   * @description publishes parent product request
   * @param productRequestIds - set of product request ids to be published
   */
  public static void publishParentProductRequest(Set<Id> productRequestIds) {
    List<Product_Request__c> productReqToPublish = new List<Product_Request__c>();
    Product_Request__c prTemp;

    for(Id prodReqId: productRequestIds){
      prTemp = new Product_Request__c(
        Id = prodReqId, 
        Product_Request_Status__c = PR_PUBLISHED
      );

      productReqToPublish.add(prTemp);
    }

    if(!productReqToPublish.isEmpty() && 
      Schema.sObjectType.Product_Request__c.fields.Product_Request_Status__c.isUpdateable()){
      update productReqToPublish;
    }
  }  

  /**
   * @description completes parent product request
   * @param prodReqToBgMap - Map of product request against the buyergroup
   */
  public static void completeParentProductRequest(Map<Id,BuyerGroup> prodReqToBgMap) {
    List<Product_Request__c> productReqToComplete = new List<Product_Request__c>();
    Product_Request__c prTemp;

    for(Id prodReqId : prodReqToBgMap.keySet()){
      prTemp = new Product_Request__c( 
        Id = prodReqId, 
        Product_Request_Status__c = PR_COMPLETED
      );
      productReqToComplete.add(prTemp);
    }

    processCompletionOfProdReq(productReqToComplete, prodReqToBgMap);    

  }

  /**
   * @description displays validation if there is existing published buyer group
   * @param List<Id> - list of buyer group Ids
   * @param Map<Id,BuyerGroup> - new items
   */
  public static void validateExistingPublishedBuyerGroup(List<Id> buyerGroupIds, Map<Id, BuyerGroup> newBuyerGroup){
    List<BuyerGroup> buyerGroupProdSpecList = new List<BuyerGroup>([
      SELECT Id, Product_Request__r.Product_Specification__c
        FROM BuyerGroup
       WHERE Id IN : buyerGroupIds WITH SECURITY_ENFORCED
    ]);

    Set<Id> prodSpecIds = new Set<Id>();
    for(BuyerGroup buyerGroup : buyerGroupProdSpecList){
      prodSpecIds.add(buyerGroup.Product_Request__r.Product_Specification__c);
    }

    List<BuyerGroup> existingBuyerGroups = new List<BuyerGroup>([
      SELECT Id
        FROM BuyerGroup
       WHERE Product_Request__r.Product_Request_Status__c = 'Published' 
         AND Ready_for_Publishing__c = 'Yes'
         AND Product_Request__r.Product_Specification__c IN : prodSpecIds WITH SECURITY_ENFORCED
    ]);
    
    for(Id buyerGroupId: buyerGroupIds){
      if(!existingBuyerGroups.isEmpty()){
        newBuyerGroup.get(buyerGroupId).addError('Ready_for_publishing__c', 'There should not be more than 1 active Standing offer Arrangement per Product Specification');
      }
    }
  }

  private static void validateReadyForPublishing(BuyerGroupValidationWrapper buyerGroupValidationWrapper){
    for(Id item: buyerGroupValidationWrapper.buyerGroupIds){
      if( buyerGroupValidationWrapper.associatedProductsMap.containsKey(item) || 
          buyerGroupValidationWrapper.buyerGroupToProductMap.containsKey(item)){
          buyerGroupValidationWrapper.newBuyerGroup.get(item).addError('Ready_for_publishing__c', 'All products should be ready for publishing to publish this Product');
      }
    }
  }

  private static void processCompletionOfProdReq(List<Product_Request__c> productReqToComplete, Map<Id,BuyerGroup> prodReqToBgMap){
    if(!productReqToComplete.isEmpty()){
      Map<Id,BuyerGroup> childProdReqToBgMap = new Map<Id,BuyerGroup>();
      Map<Id,Product2> productsToDecomission = new Map<Id,Product2>();
      Set<Id> childCCEProductRequest = new Set<Id>();
      Map<Id,Associated_Products__c> ascProductsToDecomission = new Map<Id,Associated_Products__c>();

      update productReqToComplete;

      ChildProductRequestWrapper childProductRequestWrapper = getChildCCEProductRequest(prodReqToBgMap);
      childCCEProductRequest = childProductRequestWrapper.childCCEProductRequest;
      childProdReqToBgMap = childProductRequestWrapper.childProdReqToBgMap;
      
      ascProductsToDecomission = getAssocProductsToDecom(prodReqToBgMap);
      
      //decommission child products
      List<Product2> prodList = [SELECT Id, Decommission_Product__c, Decommission_Reason__c, End_Date__c,
                                        Course__r.ProductRequestID__c, Program_Plan__r.Product_Request__c
                                   FROM Product2 
                                  WHERE Decommission_Product__c = false 
                                    AND (Course__r.ProductRequestID__c IN:childCCEProductRequest 
                                     OR Program_Plan__r.Product_Request__c IN:childCCEProductRequest) WITH SECURITY_ENFORCED];
      for(Product2 prod : prodList){
          String productReqId = getProdReqId(prod);
          
          prod.End_Date__c = Date.Today();

          if( childProdReqToBgMap.containsKey(productReqId) &&
              childProdReqToBgMap.get(productReqId).Decommission__c == true &&
              childProdReqToBgMap.get(productReqId).Decommission_Reason__c != null){

              prod.Decommission_Product__c = true;
              prod.Decommission_Reason__c = childProdReqToBgMap.get(productReqId).Decommission_Reason__c;

          }

          productsToDecomission.put(prod.Id,prod);
      }

      updateProductsToDecom(productsToDecomission);
      updateAssocProductsToDecom(ascProductsToDecomission);
    }

  }

  private static ChildProductRequestWrapper getChildCCEProductRequest(Map<Id,BuyerGroup> prodReqToBgMap){
    ChildProductRequestWrapper childProductRequestWrapper = new ChildProductRequestWrapper();
    Set<Id> childCCEProductRequest = new Set<Id>();
    Map<Id,BuyerGroup> childProdReqToBgMap = new Map<Id,BuyerGroup>();

    //after decommissioning parent product request
    //get child cce product request
    List<Related_Product_Request__c> relatedProdReqList = [SELECT Id, Program__c, Course__c
                                                             FROM Related_Product_Request__c 
                                                            WHERE Program__c IN: prodReqToBgMap.keySet() WITH SECURITY_ENFORCED];
    
    for(Related_Product_Request__c rpr : relatedProdReqList){
        if(rpr.Course__c != null){
          childCCEProductRequest.add(rpr.Course__c);
          childProdReqToBgMap.put(rpr.Course__c,prodReqToBgMap.get(rpr.Program__c));
        }
    }
    childProductRequestWrapper.childCCEProductRequest = childCCEProductRequest;
    childProductRequestWrapper.childProdReqToBgMap = childProdReqToBgMap;

    return childProductRequestWrapper;    
  }

  private static Map<Id,Associated_Products__c> getAssocProductsToDecom(Map<Id,BuyerGroup> prodReqToBgMap){
    Map<Id,Associated_Products__c> ascProductsToDecomission = new Map<Id,Associated_Products__c>();
    List<Associated_Products__c> assocProdList = [SELECT Id, IsActive__c
                                                    FROM Associated_Products__c
                                                   WHERE Product_Request__c IN: prodReqToBgMap.keySet()
                                                     AND IsActive__c = true WITH SECURITY_ENFORCED];
    
    for(Associated_Products__c ascProd : assocProdList){
        ascProd.IsActive__c = false;
        ascProductsToDecomission.put(ascProd.Id,ascProd);
      }

    return ascProductsToDecomission;
  }

  private static String getProdReqId(Product2 prod){
    String productReqId;
    if(prod.Course__c != null && prod.Course__r.ProductRequestID__c != null){
      productReqId = prod.Course__r.ProductRequestID__c;
    }else{
      productReqId = prod.Program_Plan__r.Product_Request__c;
    }
    return productReqId;
  }

  private static void updateProductsToDecom(Map<Id,Product2> productsToDecomission){
    if(!productsToDecomission.keySet().isEmpty()){
      update productsToDecomission.values();
    }
  }

  private static void updateAssocProductsToDecom(Map<Id,Associated_Products__c> ascProductsToDecomission){
    if(!ascProductsToDecomission.keySet().isEmpty()){
      update ascProductsToDecomission.values();
    }
  }
  
  public class BuyerGroupValidationWrapper{
    public List<Id> buyerGroupIds;
    public Map<Id,Associated_Products__c> associatedProductsMap;
    public Map<Id,Id> buyerGroupToProductMap;
    public Map<Id, BuyerGroup> newBuyerGroup;
  }

  public class ChildProductRequestWrapper{
    public Set<Id> childCCEProductRequest;
    public Map<Id,BuyerGroup> childProdReqToBgMap;
  }
  
}