/**
 * @description Adhoc Communication object trigger handler class
 * @see AdhocCommunicationTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan	           | October 10, 2023      | DEPP-6612              | Created file                 |
 */

 public with sharing class AdhocCommunicationTriggerHandler implements Disableable,  BeforeInsert, BeforeUpdate {
    public static Boolean isRunning = false;

   /**
    * @description before trigger event
    * @param newItems - List of Adhoc_Communication__c.Trigger.new
    */
    public void beforeInsert(List<SObject> newItems) {
        if(!isRunning ){
            isRunning = true;
            AdhocCommunicationTriggerHelper.getAdhocCommunicationToSendEmail((List<Adhoc_Communication__c>) newItems,null);
        }
    }

   /**
    * @description performs beforeupdate event for Adhoc_Communication__c object
    * @param newItems - Map of Adhoc_Communication__c.Trigger.newMap
    * @param oldItems - Map of Adhoc_Communication__c.Trigger.oldMap
    */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        if(!isRunning ){
            isRunning = true;
            AdhocCommunicationTriggerHelper.getAdhocCommunicationToSendEmail((List<Adhoc_Communication__c>) newItems.values(),(Map<Id, Adhoc_Communication__c>) oldItems);
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
