/**
 * @description Trigger for Product Request Contact Roles
 * @see ProductRequestContactRoleTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Nov 15, 2022          | DEPP-4099              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger ProductRequestContactRoleTrigger on Product_Request_Contact_Role__c (before insert, before update) {
    TriggerDispatcher.dispatch(
      TriggerHandlerFactory.getHandlersForSObjectType('Product_Request_Contact_Role__c'),
      Trigger.operationType
    );
  }
  