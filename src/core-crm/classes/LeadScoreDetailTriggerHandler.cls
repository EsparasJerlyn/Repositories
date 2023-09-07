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
public with sharing class LeadScoreDetailTriggerHandler implements Disableable,  AfterInsert {
    public static Boolean isRunning = false;
    
    /**
     * @description afterInsert trigger event
     * @param newItems - List of Lead_Score_Detail__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems){
        if(!isRunning ){
            isRunning = true; 
            LeadScoreDetailTriggerHelper.linkLeadScoreDetailToContact( (Map<Id,Lead_Score_Detail__c>) newItems);
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
