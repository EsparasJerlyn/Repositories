/**
 * @description Trigger for Program Enrollment Object
 * @see ProgramEnrollmentTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 10,2023          | DEPP-5799              | Created file                 |
 */
trigger ProgramEnrollmentTrigger on hed__Program_Enrollment__c (after insert,after update) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('hed__Program_Enrollment__c'),
    Trigger.operationType
  );
}