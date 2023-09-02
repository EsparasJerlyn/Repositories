public with sharing class OpportunityTriggerHandler implements Disableable, BeforeInsert, AfterInsert, AfterUpdate {
    public void beforeInsert(List<Sobject> newItems) {
        CodeGeneratorService.generateOpportunityCodeForOpportunityRecords(
            (List<Opportunity>) newItems
        );
    }

    /**
     * @param newItems - List of Opportunity.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        DynamicDatatableEventService.publishPlatformEvent(new OpportunitiesDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * @param newItems - List of Opportunity.Trigger.new
     * @param oldItems - List of Opportunity.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new OpportunitiesDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
