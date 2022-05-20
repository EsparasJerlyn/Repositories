/**
 * @description Trigger for Contact to create related File for Contact Image Rich Text
 * @see ContactTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | April 21, 2022        | DEPP-1211              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger ContactTrigger on Contact(
  before insert,
  before update,
  after insert,
  after update
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Contact'),
    Trigger.operationType
  );
}
