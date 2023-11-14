
/**
  * @description Chained Batch job from LeadScoreConfigRecalculationBatch to recalculate lead score for hed__Program_Enrollment__c related records.
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 07, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreProgEnrollmentBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private Set<Id> contactIdSet;

    public void recalculateLeadScore(Set<Id> contactIdSet){
        this.contactIdSet = contactIdSet;
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves hed__Program_Enrollment__c records associated from the contact
    * @param bc - BatchableContext
    * @return query - filtered query of hed__Program_Enrollment__c records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){        
        return ProgramEnrollmentsDAO.newInstance().queryLocatorGetAllProgramEnrollmentsByContactId(contactIdSet);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of hed__Program_Enrollment__c
    */
    public void execute(Database.BatchableContext bc, List<hed__Program_Enrollment__c> progEnrollmentList){
        try{ 
            LeadScoreCalculatorService.ObjectMap objMap = ProgEnrollLeadScoreHelper.setObjectMap(contactIdSet, new Map<Id, hed__Program_Enrollment__c>(progEnrollmentList));
            if(!progEnrollmentList.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactIdSet, hed__Program_Enrollment__c.getSObjectType());
            }  
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreProgEnrollmentBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}