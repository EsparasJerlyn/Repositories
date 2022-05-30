/**
 * @description Trigger for Lead records
 *
 * @see ../classes/LeadTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | angelika.j.s.galang            | May 19, 2022          | DEPP-1455              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger LeadTrigger on Lead(after insert) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Lead'),
    Trigger.operationType
  );
}