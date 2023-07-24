/**
 * @description Trigger for Affliation Object
 * @see AffiliationTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 13,2023          | DEPP-5799              | Created file                 |
 */
trigger AffiliationTrigger on hed__Affiliation__c (after insert,after update) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('hed__Affiliation__c'),
    Trigger.operationType
  );
}