/**
 * @description Trigger for Marketing_Interaction__c
 * @see MarketingInteractionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccaius.munoz                  | October 03, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger MarketingInteractionTrigger on Marketing_Interaction__c (before insert, after insert, after update) {

    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Marketing_Interaction__c'),
        Trigger.operationType
    );

}