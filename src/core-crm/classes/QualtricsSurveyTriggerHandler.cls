/**
 * @description Qualtrics Survey object trigger handler class
 * @see QualtricsSurveyTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | May 21, 2024          | DEPP-8822    | Created file                                |

*/
public with sharing class QualtricsSurveyTriggerHandler implements Disableable, AfterUpdate {

  /**
   * @description after update event
   * @param newItems - Map of Qualtrics_Survey__c.Trigger.new
   * @param oldItems - Map of Qualtrics_Survey__c.Trigger.old
   */
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

    QualtricsSurveyService.checkInProgressSurveyURL(           
       (List<Qualtrics_Survey__c>) newItems.values(), 
       (Map<Id, Qualtrics_Survey__c>) oldItems
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