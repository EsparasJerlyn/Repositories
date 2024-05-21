/**
 * @description trigger for object Student Sanction
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 16, 2024        | DEPP-7983              | Created file
 */
trigger StudentSanctionTrigger on Student_Sanction__c(before insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Student_Sanction__c'),
        Trigger.operationType
    );
}
