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
 */
public with sharing class AssetTriggerHelper{
  private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
  private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;

	public static void validateAsset(Set<Id> assetIds, Map<Id,Asset> assetMap, Set<Id> assetAccounts){
    Set<Id> matchedAccountIds = new Set<Id>();

    //get all assets with matching accounts and are already in release or published stage
    List<Asset> existingAssets = new List<Asset>([
      SELECT Id, AccountId
      FROM Asset
      WHERE AccountId IN: assetAccounts
      AND (Product_Request__r.Product_Request_Status__c = 'Release'
      OR Product_Request__r.Product_Request_Status__c = 'Published')
    ]);

    //store all existing account ids
    for(Asset a: existingAssets){
      matchedAccountIds.add(a.AccountId);
    }

    for(Id assetId: assetIds){
      if( assetMap.containsKey(assetId) && 
          matchedAccountIds.contains(assetMap.get(assetId).AccountId)){
            
            assetMap.get(assetId).addError('Mark_Design_Stage_as_Complete__c', 'There shouldn’t be multiple assets that are Active.');
            
          }
    }

  }

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
        AND IsActive__c = true
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

    if(!productReqToPublish.isEmpty()){
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
        AND IsActive__c = true
      ]){
        ascProd.IsActive__c = false;
        ascProductsToDecomission.put(ascProd.Id,ascProd);
      }

      if(!ascProductsToDecomission.keySet().isEmpty()){
        update ascProductsToDecomission.values();
      }
    }
  }
}