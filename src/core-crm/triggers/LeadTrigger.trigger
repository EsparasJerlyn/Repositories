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
      | alexander.cadalin              | June 22, 2022         | DEPP-3056              | Added before insert, update  |
      |                                | June 24, 2022         | DEPP-3056              | Removed after update         |
 */
trigger LeadTrigger on Lead(
    before insert,
    before update
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Lead'),
    Trigger.operationType
  );
}