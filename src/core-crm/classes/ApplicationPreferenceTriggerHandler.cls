/**
 * @description Application_Preference__c object trigger handler class
 * @see ApplicationPreferenceTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | August 11, 2023       | DEPP-6252              | Created file                                     |
 */
public with sharing class ApplicationPreferenceTriggerHandler implements Disableable,  AfterInsert, AfterUpdate {

    private static boolean isRunning = false;
    
    /**
     * @description afterInsert trigger event
     * @param newItems - List of Application_Preference__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems){
        if(!isRunning){
            isRunning = true;
            ApplicationPreferenceTriggerHelper.setCurrentPreference((List<Application_Preference__c>) newItems.values(), null);
            isRunning = false;
        }
    }

    /**
     * @description performs afterUpdate event for Application_Preference__c object
     * @param newItems - Map of Application_Preference__c.Trigger.newMap
     * @param oldItems - Map of Application_Preference__c.Trigger.oldMap
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        if(!isRunning){
            isRunning = true;
            ApplicationPreferenceTriggerHelper.setCurrentPreference((List<Application_Preference__c>) newItems.values(), (Map<Id,Application_Preference__c>) oldItems);
            isRunning = false;
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
