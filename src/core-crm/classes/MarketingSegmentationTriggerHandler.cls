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
public without sharing class MarketingSegmentationTriggerHandler implements Disableable, AfterInsert, AfterUpdate, BeforeUpdate {
    public static Boolean isAfterRunning = false;
    public static Boolean isBeforeRunning = false;
    /**
     * @description after insert
     * @param newItems - List of MarketingSegmentation.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        MarketingSegmentationTriggerHelper.updateRelatedRecords(newItems);
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
        if(!isAfterRunning){
            isAfterRunning = true;
            MarketingSegmentationTriggerHelper.updateRelatedRecords(newItems, oldItems);
        }
    }

    /**
     * @description before update
     * @param newItems - List of MarketingSegmentation.Trigger.new
     * @param oldItems - List of MarketingSegmentation.Trigger.old
     */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        if(!isBeforeRunning){
            isBeforeRunning = true;
            MarketingSegmentationLeadScoreHelper.processLeadScoreCalculation(
                (List<Marketing_Segmentation__c>) newItems.values(), 
                (Map<Id, Marketing_Segmentation__c>) oldItems
            );
        }
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