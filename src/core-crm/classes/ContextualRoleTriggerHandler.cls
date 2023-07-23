/**
* @description TriggerHandler Class for ContextualRoleTrigger
* @see ..ContextualRoleTriggerHandler
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
|--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
| roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | Created file                                                                  |
| mark.j.mahilum                 | July 13, 2023         | DEPP-5799              | Added new method to get the contact Id                                        |
*/
public with sharing class ContextualRoleTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Contextual_Role__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new ContextualRolesDAO().getSObjectType(),newItems.values(),true);
        ContextualRoleTriggerHelper.getContactFromContextualRole((List<Contextual_Role__c>) newItems.values(),null);
    }

    /**
     * 
     * @param newItems - List of Contextual_Role__c.Trigger.new
     * @param oldItems - List of Contextual_Role__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new ContextualRolesDAO().getSObjectType(),newItems.values(),false);
        ContextualRoleTriggerHelper.getContactFromContextualRole((List<Contextual_Role__c>) newItems.values(),(Map<Id, Contextual_Role__c>) oldItems);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
