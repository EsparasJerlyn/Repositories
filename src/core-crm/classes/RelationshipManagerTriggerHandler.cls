/**
* @description TriggerHandler Class for RelationshipManagerTrigger
* @see ..RelationshipManagerTrigger
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141              | Created file                                                                  |

*/
public with sharing class RelationshipManagerTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Relationship_Manager__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new RelationshipManagersDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of Relationship_Manager__c.Trigger.new
     * @param oldItems - List of Relationship_Manager__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new RelationshipManagersDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
