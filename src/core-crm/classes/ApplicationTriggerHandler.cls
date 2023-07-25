/**
 * @description Application object trigger handler class
 * @see ApplicationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | June 19,2023          | DEPP-5846    | Created file                                |
*/
 public with sharing class ApplicationTriggerHandler implements Disableable,  AfterInsert, AfterUpdate {
    public static Boolean isRunning = false;

  /**
   * @description afterInsert trigger event
   * @param newItems - List of hed__Application__c.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
      
      if(!isRunning ){
          isRunning = true; 
          ApplicationService.executeMatchingRule((List<hed__Application__c>) newItems.values(), null);
          ApplicationTriggerHelper.getContactOnApplication((List<hed__Application__c>) newItems.values(),null);
      }
  }

    /**
     * @description performs beforeUpdate event for hed__Application__c object
     * @param newItems - Map of hed__Application__c.Trigger.newMap
     * @param oldItems - Map of hed__Application__c.Trigger.oldMap
     */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        if(!isRunning ){
            isRunning = true;
            ApplicationService.executeMatchingRule((List<hed__Application__c>) newItems.values(), (Map<Id, hed__Application__c>) oldItems);
            ApplicationTriggerHelper.getContactOnApplication((List<hed__Application__c>) newItems.values(),(Map<Id, hed__Application__c>) oldItems);
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