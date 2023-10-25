/**
 * @description Trigger for Lead Score Config records
 *
 * @see ../classes/LeadScoreConfigTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 24, 2023      | DEPP-5866              | Created file                 |   
 */
trigger LeadScoreConfigTrigger on Lead_Score_Configuration__c (after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Lead_Score_Configuration__c'),
        Trigger.operationType
      );
}