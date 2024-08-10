/**
* @description TriggerHandler Class for PlanActivityTrigger
* @see ..PlanActivityTriggerHandler
*
* @author Accenture
*
* @history
*
*   | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
*   |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
*   | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                                                                  |
*   |
*/
public with sharing class PlanActivityTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Plan_Activity__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new PlanActivitiesDAO().getSObjectType(),newItems.values(),true);
    }
    /**
     * 
     * @param newItems - List of Plan_Activity__c.Trigger.new
     * @param oldItems - List of Plan_Activity__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new PlanActivitiesDAO().getSObjectType(),newItems.values(),false);
    }
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}