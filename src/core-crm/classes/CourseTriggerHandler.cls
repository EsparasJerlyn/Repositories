/**
 * @description Calls the helper method when triggered to update the External Id
 * @see CourseTrigger
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

public without sharing class CourseTriggerHandler implements Disableable, BeforeInsert {
	
/**
 * @description calls the ExternalIdHelper function to update the External Id
 * @param newItems - List of Course.Trigger.new
 */
  public void beforeInsert(List<SObject> newItems) {
    SetExternalIdHelper.updateExternalId(newItems);
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