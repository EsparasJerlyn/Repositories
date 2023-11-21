/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for Marketing Interaction related records.
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 06, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreMktgInteractionBatch implements Database.Batchable<sObject>, Database.Stateful{

    private Set<Id> contactLeadIds = new Set<Id>();
    private Set<Id> contactIdSet;
    private Set<Id> leadIdSet;

    public void recalculateLeadScore(Set<Id> contactIdSet, Set<Id> leadIdSet){
        this.contactIdSet = contactIdSet;
        this.leadIdSet = leadIdSet;
        this.contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves Marketing Interaction records associated from the contact/lead
    * @param bc - BatchableContext
    * @return query - filtered query of Marketing Interaction records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){        
        return MarketingInteractionsDAO.newInstance().queryLocatorGetMarketingInteractionsByContactOrLeadIds(contactLeadIds);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Marketing_Interaction__c
    */
    public void execute(Database.BatchableContext bc, List<Marketing_Interaction__c> mktgInteractionList){
        try{ 
            LeadScoreCalculatorService.ObjectMap objMap = MarketingInteractionLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, new Map<Id, Marketing_Interaction__c>(mktgInteractionList));
            if(!mktgInteractionList.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
            }  
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreMktgInteractionBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

}