
/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for Marketing Segmentation related records.
  *
  * @author Accenture
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 06, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

  public with sharing class LeadScoreMktgSegmentationBatch implements Database.Batchable<sObject>, Database.Stateful{
      
    private Set<Id> contactLeadIds = new Set<Id>();
    private Set<Id> contactIdSet;
    private Set<Id> leadIdSet;

    public void recalculateLeadScore(Set<Id> contactIdSet, Set<Id> leadIdSet) {
        this.contactIdSet = contactIdSet;
        this.leadIdSet = leadIdSet;
        this.contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves Marketing_Segmentation__c records associated from the contact/lead
    * @param bc - BatchableContext
    * @return query - filtered query of Marketing_Segmentation__c records
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        return MarketingSegmentationsDAO.newInstance().queryLocatorGetMarketingSegmentationsByContactOrLeadIds(contactLeadIds);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Marketing_Segmentation__c
    */
    public void execute(Database.BatchableContext bc, List<Marketing_Segmentation__c> marketingSegmentationList){
        try{ 
            Map<Id,Marketing_Segmentation__c> marketingSegmentationMap = new Map<Id,Marketing_Segmentation__c>();

            for(Marketing_Segmentation__c mktgSeg: marketingSegmentationList){
                if(mktgSeg.Contact__c != null){
                    marketingSegmentationMap.put(mktgSeg.Contact__c, mktgSeg);
                }else if(mktgSeg.Lead__c != null){
                    marketingSegmentationMap.put(mktgSeg.Lead__c, mktgSeg);
                }
            }

            LeadScoreCalculatorService.ObjectMap objMap = MarketingSegmentationLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, marketingSegmentationMap);
            if(!marketingSegmentationMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Marketing_Segmentation__c.getSObjectType());
            }
        } catch(Exception e) {
            Logger.error('Exception caught in method execute in Apex class LeadScoreMktgSegmentationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}