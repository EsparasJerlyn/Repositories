/**
 * @description trigger for object Contextual Role
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | created file
 */
trigger ContextualRoleTrigger on Contextual_Role__c (after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Contextual_Role__c'),
        Trigger.operationType
    );
}