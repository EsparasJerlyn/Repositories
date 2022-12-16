/**
 * @description TriggerHandler Class for MarketingSegmentationTrigger
 * @see ..MarketingSegmentationTriggerHandler
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
public without sharing class MarketingSegmentationTriggerHandler implements Disableable, AfterInsert, AfterUpdate {

    
    /**
     * @description after insert
     * @param newItems - List of MarketingSegmentation.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        LeadScoringManager.rollupScore(newItems, null);
        MarketingSegmentationTriggerHelper.setSegmentationAsParent(newItems, null);
    }

    
  /**
   * @description after update
   * @param newItems - List of MarketingSegmentation.Trigger.new
   * @param oldItems - List of MarketingSegmentation.Trigger.old
   */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        LeadScoringManager.rollupScore(newItems, oldItems);
        MarketingSegmentationTriggerHelper.setSegmentationAsParent(newItems, oldItems);

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