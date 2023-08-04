/**
 * @description trigger for Relationship Manager Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141              | Created file                 |
 */
trigger RelationshipManagerTrigger on Relationship_Manager__c (after insert , after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Relationship_Manager__c'),
        Trigger.operationType
    );
}