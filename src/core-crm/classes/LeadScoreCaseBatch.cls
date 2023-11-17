
/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for Case related records.
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 07, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreCaseBatch implements Database.Batchable<sObject>, Database.Stateful{

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
    * @description Retrieves Case records associated from the contact/lead
    * @param bc - BatchableContext
    * @return query - filtered query of Case records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){        
        return CasesDAO.newInstance().queryLocatorGetCasesByContactOrLeadIds(contactLeadIds);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Case
    */
    public void execute(Database.BatchableContext bc, List<Case> caseList){
        try{ 
            LeadScoreCalculatorService.ObjectMap objMap = CaseLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, new Map<Id, Case>(caseList));
            if(!caseList.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Case.getSObjectType());
            }  
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreCaseBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}