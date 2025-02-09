/**
* @description TriggerHandler Class for FinanceSummaryTrigger
* @see ..FinanceSummaryTriggerHandler
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
|--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
| roy.nino.s.regala              | July 12, 2023         | DEPP-5473              | Created file                                                                  |

*/
public with sharing class FinanceSummaryTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * 
     * @param newItems - List of Finance_Summary__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new FinanceSummariesDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * 
     * @param newItems - List of Finance_Summary__c.Trigger.new
     * @param oldItems - List of Finance_Summary__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new FinanceSummariesDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
