/**
 * @description hed__Address__c object trigger handler class
 * @see AddressTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | May 29, 2024          | DEPP-8955              | Created file                 |
 */
public with sharing class AddressTriggerHandler implements Disableable,  AfterInsert, AfterUpdate {
    
    /**
    * @description afterInsert trigger event
    * @param newItems - List of hed__Address__c.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        AddressTriggerHelper.validateAddress((List<hed__Address__c>) newItems.values());
    }
    
   /**
    * @description performs afterUpdate event for hed__Address__c object
    * @param newItems - Map of hed__Address__c.Trigger.newMap
    * @param oldItems - Map of hed__Address__c.Trigger.oldMap
    */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        AddressTriggerHelper.processValidateAddress((List<hed__Address__c>) newItems.values(),(Map<Id, hed__Address__c>) oldItems);
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