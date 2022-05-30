/**
 * @description Trigger handler class for LeadTrigger
 * 
 * @see ../triggers/LeadTrigger.trigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | angelika.j.s.galang            | May 19, 2022          | DEPP-1455              | Created file                 |
      |                                |                       |                        |                              |
 */

public without sharing class LeadTriggerHandler implements Disableable, AfterInsert {

/**
   * @description performs afterinsert event for Lead object
   * @param newItems - List of Lead.Trigger.new
   */
  public void afterInsert(Map<Id,SObject> newItems) {
    LeadDuplicatesHelper.detectDuplicates((Map<Id,Lead>) newItems);
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
