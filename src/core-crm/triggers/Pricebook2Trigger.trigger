/**
 * @description Trigger for Pricebook2 to check for name duplicates
 * @see Pricebook2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathy.cornejo 	               | June 3, 2022     	   | DEPP-2664              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger Pricebook2Trigger on Pricebook2 (before insert, before update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Pricebook2'),
        Trigger.operationType
    );
}