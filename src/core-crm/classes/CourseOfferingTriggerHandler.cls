/**
 * @description Calls the helper method when triggered to update the External Id
 * @see CourseOfferingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */

public without sharing class CourseOfferingTriggerHandler implements Disableable, BeforeInsert, AfterInsert {

/**
 * @description calls the ExternalIdHelper function to update the External Id
 * @param newItems - List of hed__Course_Offering__c.Trigger.new
 */
  public void beforeInsert(List<SObject> newItems) {
    SetExternalIdHelper.updateExternalId(newItems);
  }

    /**
   * @description performs afterinsert event for hed__Course_Offering object
   * @param newItems - List of hed__Course_Offering__c.Trigger.new
   */
  public void afterInsert(Map<Id,SObject> newItems) {
    SendNewOfferingNotificationHelper.sendCourseOfferingAvailabiltyNotification((List<hed__Course_Offering__c>) newItems.values());
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