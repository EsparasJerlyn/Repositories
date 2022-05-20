/**
 * @description Trigger for hed__Course_Offerring__c to populate external Id during before insert
 * @see CourseOfferingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger CourseOfferingTrigger on hed__Course_Offering__c (before insert, after insert) {
    TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType(
      'hed__Course_Offering__c'
    ),
    Trigger.operationType
  );

}