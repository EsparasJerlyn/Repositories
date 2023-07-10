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

*/
public with sharing class ContextualRoleTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Contextual_Role__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new ContextualRolesDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of Contextual_Role__c.Trigger.new
     * @param oldItems - List of Contextual_Role__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new ContextualRolesDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
