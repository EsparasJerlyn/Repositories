/**
 * @description TriggerHandler Class for Marketing_Interaction__c
 * @see MarketingInteractionTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccaius.munoz                  | October 03, 2023      | DEPP-5866              | Created file                 |
      | sebastianne.k.trias            | July 09, 2024         | DEPP-9821              | Removed opt in functionalit  |
 */
public with sharing class MarketingInteractionTriggerHandler implements Disableable, AfterInsert, AfterUpdate{

    /**
    * @description after insert
    * @param newItems - Map<Id, SObject> of MarketingInteraction.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        MarketingInteractionLeadScoreHelper.processLeadScoreCalculation((List<Marketing_Interaction__c>) newItems.values(), null);
    }

    /**
     * @description after update
     * @param newItems - List of MarketingInteraction.Trigger.new
     * @param oldItems - List of MarketingInteraction.Trigger.old
     */
    public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
    ) {
        MarketingInteractionLeadScoreHelper.processLeadScoreCalculation(
            (List<Marketing_Interaction__c>) newItems.values(), 
            (Map<Id, Marketing_Interaction__c>) oldItems
        );
    }

    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}