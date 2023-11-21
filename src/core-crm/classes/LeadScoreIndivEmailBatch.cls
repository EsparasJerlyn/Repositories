
/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for Indiv Email Result related records.
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 07, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreIndivEmailBatch implements Database.Batchable<sObject>, Database.Stateful{

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
    * @description Retrieves et4ae5__IndividualEmailResult__c records associated from the contact/lead
    * @param bc - BatchableContext
    * @return query - filtered query of et4ae5__IndividualEmailResult__c records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){        
        return IndividualEmailResultsDAO.newInstance().queryLocatorGetIndivEmailResultsByContactOrLeadIds(contactLeadIds);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of et4ae5__IndividualEmailResult__c
    */
    public void execute(Database.BatchableContext bc, List<et4ae5__IndividualEmailResult__c> indivEmailResultList){
        try{ 
            LeadScoreCalculatorService.ObjectMap objMap = IndividualEmailLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, new Map<Id, et4ae5__IndividualEmailResult__c>(indivEmailResultList));
            if(!indivEmailResultList.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, et4ae5__IndividualEmailResult__c.getSObjectType());
            }  
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreIndivEmailBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}