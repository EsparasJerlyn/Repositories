/**
* @description TriggerHandler Class for DocumentTrigger
* @see ..DocumentTriggerHandler
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                                                                  |

*/
public with sharing class DocumentTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Document__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new DocumentsDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of Document__c.Trigger.new
     * @param oldItems - List of Document__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new DocumentsDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}