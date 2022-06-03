/**
 * @description Trigger for Program_Offering__c to populate external Id during before insert
 * @see ProgramOfferingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 04, 2022        | DEPP-1687              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger ProgramOfferingTrigger on Program_Offering__c (before insert, after insert, after update) {
    TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType(
      'Program_Offering__c'
    ),
    Trigger.operationType
  );

}