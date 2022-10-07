/**
 * @description Trigger for Buyer Group to publish
 * @see BuyerGroupTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 29, 2022         | DEPP-2498              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger BuyerGroupTrigger on BuyerGroup (before update, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
            'BuyerGroup'
        ),
        Trigger.operationType
    );

}