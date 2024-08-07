/**
 * @description Trigger for Qualtrics Survey Object
 * @see QualtricsSurveyTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 21, 2024          | DEPP-8822              | Created File                 |
 */

 trigger QualtricsSurveyTrigger on Qualtrics_Survey__c (after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Qualtrics_Survey__c'),
        Trigger.operationType
    );
}