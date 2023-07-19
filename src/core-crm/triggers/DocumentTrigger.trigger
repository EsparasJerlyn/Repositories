/**
 * @description trigger for Document Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created File
 */
trigger DocumentTrigger on Document__c (after insert , after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Document__c'),
        Trigger.operationType
    );
}