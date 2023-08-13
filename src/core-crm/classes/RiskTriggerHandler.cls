/**
 * @description TriggerHandler Class for RiskTrigger
 * @see ..RiskTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | August 08, 2023       | DEPP-6335              | Created file
 */
public with sharing class RiskTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     *
     * @param newItems - List of Risk__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) { 
        DynamicDatatableEventService.publishPlatformEvent(
            new RisksDAO().getSObjectType(),
            newItems.values(),
            true
        );
    }

    /**
     *
     * @param newItems - List of Risk__c.Trigger.new
     * @param oldItems - List of Risk__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(
            new RisksDAO().getSObjectType(),
            newItems.values(),
            false
        );
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
