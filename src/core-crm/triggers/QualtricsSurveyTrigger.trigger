/**
 * @description Trigger for Qualtrics Survey Object
 * @see QualtricsSurveyTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | May 21,2024           | DEPP-8821              | Created file                 |
 */

 trigger QualtricsSurveyTrigger on Qualtrics_Survey__c (after insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Qualtrics_Survey__c'),
        Trigger.operationType
    );
}