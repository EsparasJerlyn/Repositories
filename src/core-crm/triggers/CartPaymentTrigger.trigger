/**
 * @description Trigger for CartPayment to populate external Id during before insert
 * @see CartPaymentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 24, 2022         | DEPP-3252              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger CartPaymentTrigger on Cart_Payment__c (after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
            'Cart_Payment__c'
        ),
        Trigger.operationType
    );

}