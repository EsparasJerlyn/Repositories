/**
 * @description Trigger for hed__Course_Enrollment__c to update related hed__Course_Offering__c with correct count of Course Connections
 *              & populates the External Id before insert
 * @see CourseConnectionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | johnbo.pineda@qut.edu.au       | December 03, 2021     | DEPP-789               | Created file                 |
	    | eugene.andrew.abuan			       | March 22, 2022	       | DEPP-1991              | Added before insert		       |
      |                                |                       |                        |                              |
 */
trigger CourseConnectionTrigger on hed__Course_Enrollment__c(
  before insert,
  before update,
  after insert,
  after update,
  after delete
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType(
      'hed__Course_Enrollment__c'
    ),
    Trigger.operationType
  );
}