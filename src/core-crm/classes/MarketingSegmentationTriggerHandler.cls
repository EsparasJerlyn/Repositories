/**
 * @description TriggerHandler Class for MarketingSegmentationTrigger
 * @see ..MarketingSegmentationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | w.li                           | June 05, 2022         | DEPP-1058              | Created file                                                |
      |                                |                       |                        |                                                             |
      | roy.nino.s.regala              | Jan 11, 2024          | DEPP-7142              | Added Lead Score Calc on insert, removed is running logic   |
 */
public without sharing class MarketingSegmentationTriggerHandler implements Disableable, AfterInsert, AfterUpdate {
    /**
     * @description after insert
     * @param newItems - List of MarketingSegmentation.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        MarketingSegmentationTriggerHelper.updateRelatedRecords(newItems);
        MarketingSegmentationLeadScoreHelper.processLeadScoreCalculation(
            (List<Marketing_Segmentation__c>) newItems.values(), 
            null
        );
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
        MarketingSegmentationTriggerHelper.updateRelatedRecords(newItems, oldItems);
        MarketingSegmentationLeadScoreHelper.processLeadScoreCalculation(
            (List<Marketing_Segmentation__c>) newItems.values(), 
            (Map<Id, Marketing_Segmentation__c>) oldItems
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