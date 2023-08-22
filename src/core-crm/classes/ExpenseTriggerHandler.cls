/**
* @description TriggerHandler Class for ExpenseTrigger
* @see ..ExpenseTrigger
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | carl.alvin.cabiles             | August 21, 2023       | DEPP-6410              | Created file                                                                  |

*/
public with sharing class ExpenseTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Expense__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new ExpensesDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of Expense__c.Trigger.new
     * @param oldItems - List of Expense__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new ExpensesDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}