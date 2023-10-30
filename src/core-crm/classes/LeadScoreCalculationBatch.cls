/**
  * @description Batch class to compute Lead Score for contact/lead
  * @see ..
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | October 07, 2023      | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for Lead and Contact                           |
  */
public with sharing class LeadScoreCalculationBatch implements Database.Batchable<sObject>{
    
    /**
    * @description Retrieves lead score detail with contact or lead
    * @param bc - BatchableContext
    * @return query - filtered query of lead score details
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsWithContactOrLead();
    }
    
    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Lead_Score_Detail__c
    */
    public void execute(Database.BatchableContext bc, List<Lead_Score_Detail__c> leadScoreDetails){
        try{ 
            Set<Id> contactLeadIds = new Set<Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> leadIdSet = new Set<Id>();
            for(Lead_Score_Detail__c leadScoreDtl : leadScoreDetails){
                if(leadScoreDtl.Contact__c != null){
                    contactLeadIds.add(leadScoreDtl.Contact__c);
                    contactIdSet.add(leadScoreDtl.Contact__c);
                }
                else if(leadScoreDtl.Lead__c != null){
                    contactLeadIds.add(leadScoreDtl.Lead__c);
                    leadIdSet.add(leadScoreDtl.Lead__c);
                }
            }            

            /**
             * Recalculate for Event Registration and Attendance and Downloaded PDF Categories
             */
            processMarketingInterActions(contactIdSet, leadIdSet);

            /**
             * Recalculate for Enquiries Category
             */
            processCase(contactIdSet, leadIdSet);
            
           /**
            * Recalculate for Email Interaction
            */
            processEmailInteractions(contactIdSet, leadIdSet);

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreCalculationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    private static void processCase(Set<Id> contactIdSet, Set<Id> leadIdSet){    
        Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Map<Id,Case> caseMap = CaseLeadScoreHelper.setCaseMap(contactLeadIds);
        LeadScoreCalculatorService.ObjectMap objMap = CaseLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, caseMap);
        if(!caseMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Case.getSObjectType());
        }
    }

    private static void processMarketingInterActions(Set<Id> contactIdSet, Set<Id> leadIdSet){        
        Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Map<Id,Marketing_Interaction__c> mktIntMap = MarketingInteractionLeadScoreHelper.setMarketingInteractionMap(contactLeadIds);
        LeadScoreCalculatorService.ObjectMap objMap = MarketingInteractionLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, mktIntMap);
        if(!mktIntMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
        }
    }

    private static void processEmailInteractions(Set<Id> contactIdSet, Set<Id> leadIdSet){        
        Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap = IndividualEmailLeadScoreHelper.getIndividualEmailResultRecords(contactLeadIds);
        LeadScoreCalculatorService.ObjectMap objMap = IndividualEmailLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, indivEmailMap);
        if(!indivEmailMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, et4ae5__IndividualEmailResult__c.getSObjectType());
        }
    }

    public void finish(Database.BatchableContext bc) {} //NOPMD
}


