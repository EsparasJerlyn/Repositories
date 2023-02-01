/**
 * @description Trigger for Product_Specification__c 
 * @see Product Specification
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | January 19, 2023      | DEPP-5087              | Created file                 |
 */
trigger ProductSpecificationTrigger on Product_Specification__c (before insert, before update) {
	TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
          'Product_Specification__c'
        ),
        Trigger.operationType
      );
}