/**
 * @description 
 * @see ProgramOfferingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 18, 2022        | DEPP-1687              | Created file                 |
 */

public without sharing class ProgramOfferingTriggerHandler implements Disableable, BeforeInsert, AfterInsert, AfterUpdate {
    public void beforeInsert(List<SObject> newItems) {
        SetOfferingName.setName(newItems); 
    }

       /**
   * @description performs afterinsert event for Program_Offering__c object
   * @param newItems - List of Program_Offering__c.Trigger.new
   */
  public void afterInsert(Map<Id,SObject> newItems) {
    Map<Id,Program_Offering__c> newItemsMap = (Map<Id,Program_Offering__c>)newItems;
    //only create 1:1 since email will be sent once per offering and createddate is identical
    Map<Id,Program_Offering__c> programToOfferinMap = new Map<Id,Program_Offering__c>();

    for(Id offeringId: newItems.keySet()){
      //check if offering is updated to be available for registration
      if( newItemsMap.get(offeringId).IsActive__c == true && 
          newItemsMap.get(offeringId).Available_Seats__c > 0 &&
          newItemsMap.get(offeringId).Registration_Start_Date__c <= Date.today() &&
          newItemsMap.get(offeringId).hed_Program_Plan__c != null &&
          ( newItemsMap.get(offeringId).Registration_End_Date__c > Date.today() || 
            newItemsMap.get(offeringId).Registration_End_Date__c == null )
        ){
          programToOfferinMap.put(newItemsMap.get(offeringId).hed_Program_Plan__c,newItemsMap.get(offeringId));
         }
    }
    if(!programToOfferinMap.keySet().isEmpty()){
      SendNewOfferingNotificationHelper.sendProgramOfferingAvailabiltyNotification(programToOfferinMap);
    }
  }

        /**
     * @description performs afterinsert event for Program_Offering__c object
     * @param newItems - List of Program_Offering__c.Trigger.new
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      //only create 1:1 since email will be sent once per offering and createddate is identical
      Map<Id,Program_Offering__c> programToOfferinMap = new Map<Id,Program_Offering__c>();

      Map<Id,Program_Offering__c> newItemsMap = (Map<Id,Program_Offering__c>)newItems;
      Map<Id,Program_Offering__c> oldItemsMap = (Map<Id,Program_Offering__c>)oldItems;

      for(Id offeringId: newItems.keySet()){
        //check if offering is updated to be available for registration
        if(((oldItemsMap.get(offeringId).Available_Seats__c != newItemsMap.get(offeringId).Available_Seats__c 
            && oldItemsMap.get(offeringId).Available_Seats__c == 0) ||
            (oldItemsMap.get(offeringId).Registration_Start_Date__c != newItemsMap.get(offeringId).Registration_Start_Date__c && 
            oldItemsMap.get(offeringId).Registration_Start_Date__c > date.Today() )||
            oldItemsMap.get(offeringId).IsActive__c != newItemsMap.get(offeringId).IsActive__c) && 
            newItemsMap.get(offeringId).IsActive__c == true && 
            newItemsMap.get(offeringId).Available_Seats__c > 0 &&
            newItemsMap.get(offeringId).Registration_Start_Date__c <= Date.today() &&
            newItemsMap.get(offeringId).hed_Program_Plan__c != null &&
            ( newItemsMap.get(offeringId).Registration_End_Date__c > Date.today() || 
              newItemsMap.get(offeringId).Registration_End_Date__c == null)
          ){
              programToOfferinMap.put(newItemsMap.get(offeringId).hed_Program_Plan__c,newItemsMap.get(offeringId));
          }
      }
      if(!programToOfferinMap.keySet().isEmpty()){
        SendNewOfferingNotificationHelper.sendProgramOfferingAvailabiltyNotification(programToOfferinMap);
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