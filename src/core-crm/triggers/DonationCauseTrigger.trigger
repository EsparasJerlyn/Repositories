/**
 * @description trigger for object opportunity
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | March 18, 2024        | DEPP-8200              | created file
 */
trigger DonationCauseTrigger on Donation_Cause__c(before insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Donation_Cause__c'),
        Trigger.operationType
    );
}