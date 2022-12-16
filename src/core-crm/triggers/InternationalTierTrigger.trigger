/**
 * @description Trigger for International_Tier__c 
 * @see Product Request
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | November 09, 2022     | DEPP-4448              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger InternationalTierTrigger on International_Tier__c (before insert, after insert, after update, before update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
          'International_Tier__c'
        ),
        Trigger.operationType
      );
}