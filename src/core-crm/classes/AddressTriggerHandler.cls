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
public with sharing class AddressTriggerHandler implements Disableable,  AfterInsert {
    
    /**
    * @description afterInsert trigger event
    * @param newItems - List of hed__Address__c.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        AddressTriggerHelper.validateAddress((List<hed__Address__c>) newItems.values());
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