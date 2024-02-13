/**
 * @description Affiliation object trigger handler class
 * @see AffiliationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum		           | July 13, 2023     	   | DEPP-5799              | Created file                 |
 */

public with sharing class AffiliationTriggerHandler implements Disableable,  AfterInsert, AfterUpdate {

   /**
    * @description afterInsert trigger event
    * @param newItems - List of hed__Affiliation__c.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        AffiliationTriggerHelper.getContactFromAffiliation((List<hed__Affiliation__c>) newItems.values(),null);
    }

   /**
    * @description performs beforeUpdate event for hed__Affiliation__c object
    * @param newItems - Map of hed__Affiliation__c.Trigger.newMap
    * @param oldItems - Map of hed__Affiliation__c.Trigger.oldMap
    */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        AffiliationTriggerHelper.getContactFromAffiliation((List<hed__Affiliation__c>) newItems.values(),(Map<Id, hed__Affiliation__c>) oldItems);
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