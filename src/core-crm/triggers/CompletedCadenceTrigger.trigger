/**
 * @description Trigger for Completed Cadence
 * @see CompletedCadenceTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 23, 2024          | DEPP-8255              | Created file                 |
      |                                |                       |                        |                              |
 */

trigger CompletedCadenceTrigger on Completed_Cadence__c (before update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Completed_Cadence__c'),
        Trigger.operationType
    );
}