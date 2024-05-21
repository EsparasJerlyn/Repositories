/**
 * @description Qualtrics Survey object trigger handler class
 * @see QualtricsSurveyTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------------------|
      | arsenio.jr.dayrit         | May 21,2024           | DEPP-8821    | Created file                                                          |
*/
public with sharing class QualtricsSurveyTriggerHandler implements Disableable, AfterInsert {

  /**
   * @description afterInsert trigger event
   * @param newItems - List of Qualtric_Survey__c.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    QualtricsSurveyService.updateQualtricsSurveyInfo((List<Qualtrics_Survey__c>) newItems.values());
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