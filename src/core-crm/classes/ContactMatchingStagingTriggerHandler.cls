/**
 * @description Calls the helper method when triggered 
 * @see ContactMatchingStagingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 01, 2024          | DEPP-8676              | created file                 |
 */

public with sharing class ContactMatchingStagingTriggerHandler implements Disableable, BeforeInsert{

  /**
   * @description before insert event
   * @param newItems - List of Contact Matching Staging trigger.new
   */
  public void beforeInsert(List<SObject> newItems) {
    ContactMatchingStagingTriggerHelper.executeContactMatchingBatch(newItems);
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