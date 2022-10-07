/**
 * @description Trigger for Asset 
 * @see AssetTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.m.tambasen                | August 10, 2022       | DEPP-3480              | Created file                 |
      | alexander.cadalin              | Aug. 12, 2022         | DEPP-3481              | + after update               |
 */
trigger AssetTrigger on Asset (before update, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
            'Asset'
        ),
        Trigger.operationType
    );

}