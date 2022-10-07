/**
 * @description Trigger for Associated Products (SOA) to be Inserted to the Category
 * @see AssociatedProductsTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 16, 2022       | DEPP-2665              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger AssociatedProductsTrigger on Associated_Products__c	 (after insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
            'Associated_Products__c'
        ),
        Trigger.operationType
    );

}
