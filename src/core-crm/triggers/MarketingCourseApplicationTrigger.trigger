/**
 * @description Trigger for Marketing_Course_Application__c
 * @see MarketingCourseApplicationTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | w.li                           | June 05, 2022         | DEPP-1058              | Created file                 |
      |                                |                       |                        |                              |
 */
trigger MarketingCourseApplicationTrigger on Marketing_Course_Application__c(
  after insert,
  after update
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Marketing_Course_Application__c'),
    Trigger.operationType
  );
}