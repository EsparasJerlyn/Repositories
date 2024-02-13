/**
 * @description Lead_Score_Detail__c object trigger handler class
 * @see LeadScoreDetailTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | Sept 07, 2023         | DEPP-5965              | Created file                                     |
 */
public with sharing class LeadScoreDetailTriggerHandler implements Disableable,  AfterInsert, BeforeInsert, BeforeUpdate {
    
    /**
     * @description beforeInsert trigger event
     * @param newItems - List of Lead_Score_Detail__c.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems){
        LeadScoreDetailTriggerHelper.calculateTotalLeadScore((List<Lead_Score_Detail__c>) newItems,null);
    }

    /**
     * @description afterInsert trigger event
     * @param newItems - List of Lead_Score_Detail__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems){
        LeadScoreDetailTriggerHelper.linkLeadScoreDetailToContact( (Map<Id,Lead_Score_Detail__c>) newItems);
    }

    /**
     * @description performs beforeUpdate event for hed__Application__c object
     * @param newItems - Map of hed__Application__c.Trigger.newMap
     * @param oldItems - Map of hed__Application__c.Trigger.oldMap
     */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        LeadScoreDetailTriggerHelper.calculateTotalLeadScore((List<Lead_Score_Detail__c>) newItems.values(), (Map<Id, Lead_Score_Detail__c>) oldItems);
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
