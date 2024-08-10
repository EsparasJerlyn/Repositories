/**
* @description TriggerHandler Class for DonationTrigger
* @see ..DonationTriggerHandler
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | nicole.genon                   | April 22, 2024        | DEPP-8498              | Created file                                                                  |

*/
public with sharing class DonationTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Donation__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new DonationsDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of Donation__c.Trigger.new
     * @param oldItems - List of Donation__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new DonationsDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}