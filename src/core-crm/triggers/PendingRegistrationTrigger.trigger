/**
 * @description Trigger for Pending_Registration__c to update related hed__Course_Offering__c with correct count of Pending Registrations
 * @see PendingRegistrationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | johnbo.pineda@qut.edu.au       | December 20, 2021     | DEPP-1150              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger PendingRegistrationTrigger on Pending_Registration__c(
  after insert,
  after update,
  after delete
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Pending_Registration__c'),
    Trigger.operationType
  );
}
