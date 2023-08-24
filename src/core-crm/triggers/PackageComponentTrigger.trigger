/**
 * @description Trigger for Package Component Object
 * @see PackageComponentTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dyrit               | August 15,2023        | DEPP-6370              | Created file                 |
 */
trigger PackageComponentTrigger on Package_Component__c (before insert,before update) {
    TriggerDispatcher.dispatch(
      TriggerHandlerFactory.getHandlersForSObjectType('Package_Component__c'),
      Trigger.operationType
    );
}