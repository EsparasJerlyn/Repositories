/**
 * @description trigger for Donation Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | nicole.genon                   | April 22, 2024        | DEPP-8498              | Created File
 */
trigger DonationTrigger on Donation__c (after insert , after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Donation__c'),
        Trigger.operationType
    );
}