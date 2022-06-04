/**
 * @description Calls the helper method when triggered to update the External Id
 * @see CourseOfferingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */

public without sharing class CourseOfferingTriggerHandler implements Disableable, BeforeInsert, AfterInsert ,AfterUpdate{

/**
 * @description calls the ExternalIdHelper function to update the External Id
 * @param newItems - List of hed__Course_Offering__c.Trigger.new
 */
  public void beforeInsert(List<SObject> newItems) {
    SetExternalIdHelper.updateExternalId(newItems);
        SetOfferingName.setName(newItems); 
  }

    /**
   * @description performs afterinsert event for hed__Course_Offering object
   * @param newItems - List of hed__Course_Offering__c.Trigger.new
   */
  public void afterInsert(Map<Id,SObject> newItems) {
    Map<Id,hed__Course_Offering__c> newItemsMap = (Map<Id,hed__Course_Offering__c>)newItems;
    //only create 1:1 since email will be sent once per offering and createddate is identical
    Map<Id,hed__Course_Offering__c> courseToOfferinMap = new Map<Id,hed__Course_Offering__c>();

    for(Id offeringId: newItems.keySet()){
      //check if offering is updated to be available for registration
      if( newItemsMap.get(offeringId).IsActive__c == true && 
          newItemsMap.get(offeringId).Available_Seats__c > 0 &&
          newItemsMap.get(offeringId).Registration_Start_Date__c <= Date.today() &&
          newItemsMap.get(offeringId).hed__Course__c != null &&
          ( newItemsMap.get(offeringId).Registration_End_Date__c > Date.today() || 
            newItemsMap.get(offeringId).Registration_End_Date__c == null )
        ){
          courseToOfferinMap.put(newItemsMap.get(offeringId).hed__Course__c,newItemsMap.get(offeringId));
         }
    }
    if(!courseToOfferinMap.keySet().isEmpty()){
      SendNewOfferingNotificationHelper.sendCourseOfferingAvailabiltyNotification(courseToOfferinMap);
    }
  }

  /**
   * @description performs afterinsert event for hed__Course_Offering object
   * @param newItems - List of hed__Course_Offering__c.Trigger.new
   */
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    //only create 1:1 since email will be sent once per offering and createddate is identical
    Map<Id,hed__Course_Offering__c> courseToOfferinMap = new Map<Id,hed__Course_Offering__c>();

    Map<Id,hed__Course_Offering__c> newItemsMap = (Map<Id,hed__Course_Offering__c>)newItems;
    Map<Id,hed__Course_Offering__c> oldItemsMap = (Map<Id,hed__Course_Offering__c>)oldItems;

    for(Id offeringId: newItems.keySet()){
      //check if offering is updated to be available for registration
      if(((oldItemsMap.get(offeringId).Available_Seats__c != newItemsMap.get(offeringId).Available_Seats__c 
          && oldItemsMap.get(offeringId).Available_Seats__c == 0) ||
          (oldItemsMap.get(offeringId).Registration_Start_Date__c != newItemsMap.get(offeringId).Registration_Start_Date__c &&
          oldItemsMap.get(offeringId).Registration_Start_Date__c > Date.today()) ||
          oldItemsMap.get(offeringId).IsActive__c != newItemsMap.get(offeringId).IsActive__c) && 
          newItemsMap.get(offeringId).IsActive__c == true && 
          newItemsMap.get(offeringId).Available_Seats__c > 0 &&
          newItemsMap.get(offeringId).Registration_Start_Date__c <= Date.today() &&
          newItemsMap.get(offeringId).hed__Course__c != null &&
          ( newItemsMap.get(offeringId).Registration_End_Date__c > Date.today() || 
            newItemsMap.get(offeringId).Registration_End_Date__c == null)
        ){
           courseToOfferinMap.put(newItemsMap.get(offeringId).hed__Course__c,newItemsMap.get(offeringId));
        }
    }
    if(!courseToOfferinMap.keySet().isEmpty()){
      SendNewOfferingNotificationHelper.sendCourseOfferingAvailabiltyNotification(courseToOfferinMap);
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