/**
 * @description TriggerHandler Class for MarketingInteractionTrigger
 * @see ..MarketingInteractionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | w.li                           | June 05, 2022         | DEPP-1058              | Created file                 |
      |                                |                       |                        |                              |
 */
public without sharing class MarketingInteractionTriggerHandler implements Disableable, AfterInsert, AfterUpdate {

    /**
     * @description after insert
     * @param newItems - List of Marketing Interaction.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        LeadScoringManager.rollupScore(newItems, null);
    }

    
    /**
     * @description after update
     * @param newItems - List of Marketing Interaction.Trigger.new
     * @param oldItems - List of Marketing Interaction.Trigger.old
    */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        LeadScoringManager.rollupScore(newItems, oldItems);
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