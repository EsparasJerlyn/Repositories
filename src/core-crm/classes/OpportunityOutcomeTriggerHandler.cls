/**
 * @description trigger handler class for object opportunity outcome
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 12, 2023          | DEPP-5594              | created file
 */
public with sharing class OpportunityOutcomeTriggerHandler implements Disableable, BeforeInsert {
    public void beforeInsert(List<Sobject> newItems) {
        OpportunityOutcomeCodeCtrl.generateOpportunityOutcomeCode((List<Opportunity_Outcome__c>)newItems);
        OpportunityOutcomeProjectNameCtrl.generateProjectName((List<Opportunity_Outcome__c>)newItems);
    }
    
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}