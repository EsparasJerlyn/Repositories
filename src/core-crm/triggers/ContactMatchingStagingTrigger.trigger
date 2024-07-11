/**
 * @description Trigger for Contact Matching Staging
 * @see ContactMatchingStagingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 01, 2024          | DEPP-8676              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger ContactMatchingStagingTrigger on Contact_Matching_Staging__c (before insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType(
            'Contact_Matching_Staging__c'
        ),
        Trigger.operationType
    );

}