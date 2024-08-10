/**
 * @description trigger for object Designation
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | March 18, 2024        | DEPP-8200              | created file
 */
trigger DesignationTrigger on Designation__c(before insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Designation__c'),
        Trigger.operationType
    );
}