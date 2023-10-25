/**
 * @description Lead_Score_Configuration__c object trigger handler class
 * @see LeadScoreConfigTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 24, 2023      | DEPP-5866              | Created file                 |   
 */
public with sharing class LeadScoreConfigTriggerHandler implements Disableable, AfterUpdate{
   
    /**
     * @description after update
     * @param newItems - Lead_Score_Configuration__c.Trigger.new
     * @param oldItems - Lead_Score_Configuration__c.Trigger.old
     */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        LeadScoreConfigTriggerHelper.processLeadScoreCalculation(
            (List<Lead_Score_Configuration__c>) newItems.values(), 
            (Map<Id, Lead_Score_Configuration__c>) oldItems
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