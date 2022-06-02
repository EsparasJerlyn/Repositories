/**
 * @description Trigger for Product_Request__c 
 * @see Product Request
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 06, 2022         | DEPP-2859              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger ProductRequestTrigger on Product_Request__c (after update) {
    TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType(
      'Product_Request__c'
    ),
    Trigger.operationType
  );

}