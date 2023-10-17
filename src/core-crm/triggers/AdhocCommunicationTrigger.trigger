/**
 * @description Trigger for Adhoc Communication Object
 * @see AffiliationTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | October 10, 2023      | DEPP-6612              | Created file                 |
 */

 trigger AdhocCommunicationTrigger on Adhoc_Communication__c (before insert, before update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Adhoc_Communication__c'),
        Trigger.operationType
    );
}