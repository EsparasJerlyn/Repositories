
/**
 * @description Trigger handler class for et4ae5__IndividualEmailResult__c Object
 * 
 * @see IndividualEmailTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 18, 2023      | DEPP-5866              | Created file                 |
 */
public with sharing class IndividualEmailTriggerHandler implements Disableable, AfterInsert, AfterUpdate {

    /**
     * @description beforeInsert trigger event
     * @param newItems - List of et4ae5__IndividualEmailResult__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) { 
        IndividualEmailLeadScoreHelper.processLeadScoreCalculation((List<et4ae5__IndividualEmailResult__c>) newItems.values(), null);
    }

    /**
     * @description after update
     * @param newItems - Map of et4ae5__IndividualEmailResult__c.Trigger.new
     * @param oldItems - Map of et4ae5__IndividualEmailResult__c.Trigger.old
     */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ){
        IndividualEmailLeadScoreHelper.processLeadScoreCalculation(
            (List<et4ae5__IndividualEmailResult__c>) newItems.values(), 
            (Map<Id, et4ae5__IndividualEmailResult__c>) oldItems
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