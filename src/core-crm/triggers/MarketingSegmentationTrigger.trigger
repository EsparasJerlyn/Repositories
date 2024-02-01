/**
 * @description Trigger for Marketing_Segmentation__c
 * @see MarketingSegmentationTrigger
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
trigger MarketingSegmentationTrigger on Marketing_Segmentation__c(
  after insert,
  after update
) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Marketing_Segmentation__c'),
    Trigger.operationType
  );
}