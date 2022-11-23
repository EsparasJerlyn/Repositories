/**
 * @description Calls the helper method when triggered
 * @see AssetTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | john.m.tambasen                | August 10, 2022       | DEPP-3480              | Created file                                                       |
      | eccarius.karl.munoz            | November 15, 2022     | DEPP-4014              | 1.) Removed validateAsset method.                                  |
      |                                |                       |                        | 2.) Added validateExistingPublishedAsset method to check           | 
      |                                |                       |                        |     existing Asset record with Published status.                   |
      |                                |                       |                        |                                                                    |
 */
public with sharing class AssetTriggerHelper{
  private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
  private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;

  /**
   * @description validate before publishing assets
   * @param assetIds - List of assets to be published
   * @param newAssets - Map of Asset.Trigger.new
   */
  public static void validatePublishing(List<Id> assetIds, Map<Id, Asset> newAssets) {

    //maps product request -> asset
    Map<Id, Id> productRequestMap = new Map<Id, Id>(); 
    //maps asset -> associated product
    Map<Id,Associated_Products__c> associatedProductsMap = new Map<Id,Associated_Products__c>();

    for(Id item: assetIds){
      if(newAssets.containsKey(item) && newAssets.get(item).Product_Request__c != null){
        productRequestMap.put(newAssets.get(item).Product_Request__c,item);
      }
    }

    if(!productRequestMap.keySet().isEmpty()){
      for(Associated_Products__c aProd: [ 
        SELECT Id, Product__r.Available_On_Cart__c, Product_Request__c 
        FROM Associated_Products__c 
        WHERE Product_Request__c 
        IN: productRequestMap.keySet() 
        AND Product__r.Available_On_Cart__c = false
        AND IsActive__c = true WITH SECURITY_ENFORCED
      ]){
        associatedProductsMap.put(productRequestMap.get(aProd.Product_Request__c),aProd);
      }
    }
    
    for(Id item: assetIds){
      if(associatedProductsMap.containsKey(item)){
        newAssets.get(item).addError('Ready_for_publishing__c', 'All products should be ready for publishing to publish this Product');
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

    if(!productReqToPublish.isEmpty() && 
      Schema.sObjectType.Product_Request__c.fields.Product_Request_Status__c.isUpdateable()){
      update productReqToPublish;
    }
  }
  /**
   * @description completes parent product request
   * @param prodReqToAssetMap - Map of product request against the asset
   */
  public static void completeParentProductRequest(Map<Id,Asset> prodReqToAssetMap) {
    List<Product_Request__c> productReqToComplete = new List<Product_Request__c>();
    Map<Id,Associated_Products__c> ascProductsToDecomission = new Map<Id,Associated_Products__c>();
    Product_Request__c prTemp;

    for(Id prodReqId: prodReqToAssetMap.keySet()){
      prTemp = new Product_Request__c(Id = prodReqId, Product_Request_Status__c = PR_COMPLETED);
      productReqToComplete.add(prTemp);
    }

    if(!productReqToComplete.isEmpty()){
      update productReqToComplete;

      for(Associated_Products__c ascProd: [
        SELECT Id, IsActive__c
        FROM Associated_Products__c
        WHERE Product_Request__c IN: prodReqToAssetMap.keySet()
        AND IsActive__c = true WITH SECURITY_ENFORCED
      ]){
        ascProd.IsActive__c = false;
        ascProductsToDecomission.put(ascProd.Id,ascProd);
      }

      if(!ascProductsToDecomission.keySet().isEmpty()){
        update ascProductsToDecomission.values();
      }
    }
  }

  /**
   * @description displays validation if there is existing published asset
   * @param List<Id> - list of asset Ids
   * @param Map<Id,Asset> - new items
   */
  public static void validateExistingPublishedAsset(List<Id> assetIds, Map<Id,Asset> newAssets){

    List<Asset> assetProdSpecList = new List<Asset>([
      SELECT Id, Product_Request__r.Product_Specification__c, Product_Request__c
        FROM Asset
       WHERE Id IN : assetIds WITH SECURITY_ENFORCED
    ]);

    Set<Id> prodSpecIds = new Set<Id>();
    for(Asset asset : assetProdSpecList){
      prodSpecIds.add(asset.Product_Request__r.Product_Specification__c);
    }

    List<Asset> existingAssets = new List<Asset>([
      SELECT Id, Product_Request__r.Product_Specification__c
        FROM Asset
       WHERE Product_Request__r.Product_Request_Status__c = 'Published' 
         AND Ready_for_Publishing__c = 'Yes'
         AND Product_Request__r.Product_Specification__c IN : prodSpecIds WITH SECURITY_ENFORCED
    ]);

    for(Id assetId: assetIds){
      if(!existingAssets.isEmpty()){
        newAssets.get(assetId).addError('Ready_for_publishing__c', 'There should not be more than 1 active Corporate Bundle per Product Specification');
      }
    }
  }

}