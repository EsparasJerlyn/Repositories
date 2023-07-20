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
 */
public with sharing class OpportunityOutcomeTriggerHandler implements Disableable, BeforeInsert, AfterInsert {
    public void beforeInsert(List<Sobject> newItems) {
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
    public void afterInsert(Map<Id, Sobject> newItems) {
        OpportunityRelationshipsToOutcome.copyRelationshipsFromOppToOppOutcome(
            (List<Opportunity_Outcome__c>) newItems.values()
        );
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
