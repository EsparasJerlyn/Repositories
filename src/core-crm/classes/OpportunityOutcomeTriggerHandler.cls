/**
 * @description trigger handler class for object opportunity outcome
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                             |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
 *    | alexander.cadalin              | May 12, 2023          | DEPP-5594              | Created file                                               |
 *    | kenneth.f.alsay                | Jul 13, 2023          | DEPP-5457,5468         | Added afterInsert, CopyOpportunityRelationshipsToOutcome   |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Renamed class to OpportunityRelationshipsToOutcome         |
 *    | ryan.j.a.dela.cruz             | July 26, 2023         | DEPP-6208              | Added publishPlatformEvent for table auto refresh          |
 */
public with sharing class OpportunityOutcomeTriggerHandler implements Disableable, BeforeInsert, AfterInsert, AfterUpdate {
    /**
     * @param newItems - List of Opportunity.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        CodeGeneratorService.generateCodeForOpportunityOutcomeRecords(
            (List<Opportunity_Outcome__c>) newItems
        );
        OpportunityOutcomeProjectNameCtrl.generateProjectName(
            (List<Opportunity_Outcome__c>) newItems
        );
        OpportunityRelationshipsToOutcome.updateOpportunityOutcome(
            (List<Opportunity_Outcome__c>) newItems
        );
    }

    /**
     * @param newItems - List of Opportunity.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        OpportunityRelationshipsToOutcome.copyRelationshipsFromOppToOppOutcome(
            (List<Opportunity_Outcome__c>) newItems.values()
        );
        DynamicDatatableEventService.publishPlatformEvent(new OpportunityOutcomesDAO().getSObjectType(),newItems.values(),true);
    }

    /**
     * @param newItems - List of Opportunity.Trigger.new
     * @param oldItems - List of Opportunity.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        DynamicDatatableEventService.publishPlatformEvent(new OpportunityOutcomesDAO().getSObjectType(),newItems.values(),false);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
