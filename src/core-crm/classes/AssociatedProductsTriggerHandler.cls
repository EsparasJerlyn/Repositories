/**
 * @description TriggerHandler Class for AssociatedProductsTrigger
 * @see ..AssociatedProductsTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 17, 2022       | DEPP-2665              | Created File                 |
 */

public without sharing class AssociatedProductsTriggerHandler implements Disableable, AfterInsert {

    /**
     * @description method that uses that
     * @param newItems - List of Associated_Products__c.Trigger.new
     */
    public void afterInsert( Map<Id, SObject> newItems){
        Map<Id,Associated_Products__c> newMap = (Map<Id,Associated_Products__c>) newItems;
        AssociatedProductsTriggerHelper.includeProductToStore(newMap);
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
