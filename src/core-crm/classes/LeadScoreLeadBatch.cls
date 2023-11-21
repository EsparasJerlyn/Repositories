
/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for Lead related records.
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 07, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreLeadBatch implements Database.Batchable<sObject>, Database.Stateful{
    private Set<Id> leadIdSet;

    public void recalculateLeadScore(Set<Id> leadIdSet){
        this.leadIdSet = leadIdSet;
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves Lead records associated from the lead score detail
    * @param bc - BatchableContext
    * @return query - filtered query of Lead records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){        
        return LeadsDAO.newInstance().queryLocatorGetLeadsByIds(leadIdSet, LeadsDAO.LEARNER_LEAD_TYPE);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Lead
    */
    public void execute(Database.BatchableContext bc, List<Lead> leadList){
        try{ 
            LeadScoreCalculatorService.ObjectMap objMap = LeadLeadScoreHelper.setObjectMap(new Map<Id, Lead>(leadList));
            if(!leadList.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, leadIdSet, Lead.getSObjectType());
            }  
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreLeadBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}