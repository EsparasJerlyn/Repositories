/**
 * @description Trigger for Lead Score Detail records
 *
 * @see ../classes/LeadScoreDetailTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | Sept 07, 2023         | DEPP-5965              | Created file                 |   
 */
trigger LeadScoreDetailTrigger on Lead_Score_Detail__c (after insert, before insert, before update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Lead_Score_Detail__c'),
        Trigger.operationType
      );
}