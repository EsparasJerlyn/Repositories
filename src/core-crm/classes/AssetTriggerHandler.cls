/**
 * @description Calls the helper method when triggered
 * @see AssetTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | john.m.tambasen                | August 10, 2022       | DEPP-3480              | Created file                               |
      | alexander.cadalin              | August 12, 2022       | DEPP-3481              | release tab related actions                |
      | eccarius.karl.munoz            | November 15, 2022     | DEPP-4014              | 1.) Removed validateAsset call             |
      |                                |                       |                        | 2.) Added validateExistingPublishedAsset   |
      |                                |                       |                        |     method call from Helper class.         |                                   
      |                                |                       |                        |                                            |
 */
public with sharing class AssetTriggerHandler implements Disableable, BeforeUpdate, AfterUpdate{
  
  /**
   * @description 
   * @param newItems - List of Asset.Trigger.new
   * @param oldItems - List of Asset.Trigger.old
   */
  public void beforeUpdate(
      Map<Id, SObject> newItems,
      Map<Id, SObject> oldItems
  ) {
    
    Map<Id, Asset> newMap = (Map<Id,Asset>)newItems;
    Map<Id, Asset> oldMap = (Map<Id,Asset>)oldItems;

    List<Id> idsToPublish = new List<Id>();
    
    for(Asset a : newMap.values()){
      //if asset is being published
      idsToPublish = getIdsToPublish(a, oldMap);

      //copy end date to publishing enddate 
      //asset product is decomissioned
      if( ( a.End_Date__c != oldMap.get(a.Id).End_Date__c || 
            a.Decommission__c != oldMap.get(a.Id).Decommission__c) && 
            a.End_Date__c <= Date.Today() && a.Decommission__c == true){

              a.Publishing_End_date__c = a.End_Date__c;  
              
      }
    }

    processValidation(idsToPublish, newMap);
  }  

  /**
   * @description after update event for asset
   * @param newItems - List of Asset.Trigger.new
   * @param oldItems - Map of Asset.Trigger.old
   */
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Map<Id,Asset> newMap = (Map<Id,Asset>) newItems;
    Map<Id,Asset> oldMap = (Map<Id,Asset>) oldItems;

    Set<Id> idsToPublish = new Set<Id>();
    Map<Id, Asset> prodReqToAssetMap = new Map<Id, Asset>();
    for(Asset a: newMap.values()){
      idsToPublish = getIdsToPublishAfterUpdate(a, oldMap);
      prodReqToAssetMap = getProdReqToAssetMap(a, oldMap);
    }

    processPublishParentProductRequest(idsToPublish);
    processCompleteParentProductRequest(prodReqToAssetMap);
    
  }

  private static List<Id> getIdsToPublish(Asset a, Map<Id, Asset> oldMap){
    List<Id> idsToPublish = new List<Id>();
    
    if( a.Ready_for_publishing__c != oldMap.get(a.Id).Ready_for_Publishing__c && a.Ready_for_publishing__c == 'Yes'){
        idsToPublish.add(a.Id);
    }
    return idsToPublish;
  }

  private static void processValidation(List<Id> idsToPublish, Map<Id, Asset> newMap){
    if(!idsToPublish.isEmpty()){
      AssetTriggerHelper.validateExistingPublishedAsset(idsToPublish, newMap);
      AssetTriggerHelper.validatePublishing(idsToPublish, newMap);
    }
  }

  private static Set<Id> getIdsToPublishAfterUpdate(Asset a, Map<Id, Asset> oldMap){
    Set<Id> idsToPublish = new Set<Id>();
    if( ( a.Ready_for_Publishing__c != oldMap.get(a.Id).Ready_for_publishing__c || 
            a.Publishing_Start_Date__c != oldMap.get(a.Id).Publishing_Start_Date__c ) && 
            a.Ready_for_publishing__c == 'Yes' && 
            a.Publishing_Start_Date__c <= Date.Today() &&
            ( a.Publishing_End_date__c == null || 
              a.Publishing_End_date__c > Date.today()) &&
              a.Product_Request__c != null){

                idsToPublish.add(a.Product_Request__c); 
    }
    return idsToPublish;
  }

  private static Map<Id, Asset> getProdReqToAssetMap(Asset a, Map<Id, Asset> oldMap){
    Map<Id, Asset> prodReqToAssetMap = new Map<Id, Asset>();
    if( ( a.Decommission__c != oldMap.get(a.Id).Decommission__c || 
        a.End_Date__c != oldMap.get(a.Id).End_Date__c) && 
        a.End_Date__c <= Date.Today() && 
        a.Decommission__c == true && 
        a.Product_Request__c != null){
          prodReqToAssetMap.put(a.Product_Request__c, a);
    }
    return prodReqToAssetMap;
  }

  private static void processPublishParentProductRequest(Set<Id> idsToPublish){
    if(!idsToPublish.isEmpty()){
      AssetTriggerHelper.publishParentProductRequest(idsToPublish);
    }
  }

  private static void processCompleteParentProductRequest(Map<Id, Asset> prodReqToAssetMap){
    if(!prodReqToAssetMap.keySet().isEmpty()){
      AssetTriggerHelper.completeParentProductRequest(prodReqToAssetMap);
    }
  }

  /**
   * @description indicates it the trigger is disabled
   * @return disabled bypass
   */
  public Boolean isDisabled() {
    final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
    return bypass.isDisabled();
  }

}