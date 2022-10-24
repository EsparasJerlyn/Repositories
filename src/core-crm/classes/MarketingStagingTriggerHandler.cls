/**
 * @description TriggerHandler Class for MarketingStagingTrigger
 * @see ..MarketingStagingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 23, 2022          | DEPP-2103              | Created file                 |
      | roy.nino.s.regala              | June 28, 2022         | DEPP-3070              | moved logic                  |
 */

public without sharing class MarketingStagingTriggerHandler implements Disableable, AfterInsert {
   
    
    
  /**
   * @description 
   * @param newItems - List of MarketingStaging.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {

    MarketingStagingTriggerHelper.marketingStagingMatching(newItems);

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