/**
* @description TriggerHandler Class for IP Management Relationnship Trigger
* @see ..IPManagementRelationshipTrigger
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | eugene.andrew.abuan            | August 08, 2023       | DEPP-6331              | Created file                                                                  |

*/
public with sharing class IPManagementRelationshipTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of IP_Management_Relationship__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new IPManagementRelationshipsDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of IP_Management_Relationship__c.Trigger.new
     * @param oldItems - List of IP_Management_Relationship__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new IPManagementRelationshipsDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
