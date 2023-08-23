/**
 * @description trigger for IP Management Relationship Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 08, 2023       | DEPP-6331              | Created File
 */
trigger IPManagementRelationshipTrigger on IP_Management_Relationship__c (after insert , after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('IP_Management_Relationship__c'),
        Trigger.operationType
    );
}