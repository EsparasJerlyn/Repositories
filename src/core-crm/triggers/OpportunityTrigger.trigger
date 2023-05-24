/**
 * @description trigger for object opportunity
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 12, 2023          | DEPP-5594              | created file
 */
trigger OpportunityTrigger on Opportunity (before insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Opportunity'),
        Trigger.operationType
    );
}