/**
 * @description trigger handler for buyergroup
 * @see BuyerGroupTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | roy.nino.s.regala              | July 29, 2022         | DEPP-2498              | Created file                                                       |
 */
public with sharing class BuyerGroupTriggerHandler implements Disableable, BeforeUpdate, AfterUpdate{	

  /**
   * @description before update event for buyergroup
   * @param newItems - List of BuyerGroup.Trigger.new
   * @param oldItems - Map of BuyerGroup.Trigger.old
   */
  public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Map<Id,BuyerGroup> newMap = (Map<Id,BuyerGroup>) newItems;
    Map<Id,BuyerGroup> oldMap = (Map<Id,BuyerGroup>) oldItems;

    List<Id> idsToPublish = new List<Id>();

    for(BuyerGroup bg: newMap.values()){
        if(bg.Ready_for_publishing__c != oldMap.get(bg.Id).Ready_for_Publishing__c && bg.Ready_for_publishing__c == 'Yes'){
            idsToPublish.add(bg.Id);
        }

        //copy end date to publishing enddate 
        //if product is decomissioned
        if( ( bg.End_Date__c != oldMap.get(bg.Id).End_Date__c || 
              bg.Decommission__c != oldMap.get(bg.Id).Decommission__c) && 
              bg.End_Date__c <= Date.Today() && bg.Decommission__c == true){
                bg.Publishing_End_date__c = bg.End_Date__c;  
        }
    }
    
    if(!idsToPublish.isEmpty()){
        BuyerGroupTriggerHelper.validatePublishing(idsToPublish,newMap);
    }
  }

  /**
   * @description after update event for buyergroup
   * @param newItems - List of BuyerGroup.Trigger.new
   * @param oldItems - Map of BuyerGroup.Trigger.old
   */
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Map<Id,BuyerGroup> newMap = (Map<Id,BuyerGroup>) newItems;
    Map<Id,BuyerGroup> oldMap = (Map<Id,BuyerGroup>) oldItems;

    Set<Id> idsToPublish = new Set<Id>();
    Set<Id> idsToComplete = new Set<Id>();
    Map<Id,BuyerGroup> prodReqToBgMap = new Map<Id,BuyerGroup>();
    for(BuyerGroup bg: newMap.values()){

        if( ( bg.Ready_for_Publishing__c != oldMap.get(bg.Id).Ready_for_publishing__c || 
              bg.Publishing_Start_Date__c != oldMap.get(bg.Id).Publishing_Start_Date__c ) && 
              bg.Ready_for_publishing__c == 'Yes' && 
              bg.Publishing_Start_Date__c <= Date.Today() &&
              ( bg.Publishing_End_date__c == null || 
                bg.Publishing_End_date__c > date.today()) &&
                bg.Product_Request__c != null){

                  idsToPublish.add(bg.Product_Request__c); 
        }

        if( ( bg.Decommission__c != oldMap.get(bg.Id).Decommission__c || 
              bg.End_Date__c != oldMap.get(bg.Id).End_Date__c) && 
              bg.End_Date__c <= Date.Today() && 
              bg.Decommission__c == true && 
              bg.Product_Request__c != null){
                prodReqToBgMap.put(bg.Product_Request__c, bg);
              }
    }

    if(!idsToPublish.isEmpty()){
        BuyerGroupTriggerHelper.publishParentProductRequest(idsToPublish);
    }

    if(!prodReqToBgMap.keySet().isEmpty()){
        BuyerGroupTriggerHelper.completeParentProductRequest(prodReqToBgMap);
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