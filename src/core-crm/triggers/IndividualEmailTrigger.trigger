
/**
 * @description Trigger for et4ae5__IndividualEmailResult__c Object
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file                 |
 */
trigger IndividualEmailTrigger on et4ae5__IndividualEmailResult__c (after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('et4ae5__IndividualEmailResult__c'), 
        Trigger.operationType
    );
}