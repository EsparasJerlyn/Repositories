/**
 * @description Helper class for LeadScoreConfigTriggerHandler
 * @see LeadScoreConfigTriggerHandler
 *
 * @author Accenture 
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 24, 2023      | DEPP-5866              | Created file                 |   
      | eccarius.munoz                 | November 05, 2023     | DEPP-7155              | Transferred recalc to batch  |   
 */
public with sharing class LeadScoreConfigTriggerHelper {
    
    public static void processLeadScoreCalculation(List<Lead_Score_Configuration__c> newItems, Map<Id, Lead_Score_Configuration__c> oldItems){

        Set<Id> leadScoreConfigIds = new Set<Id>();
        for(Lead_Score_Configuration__c leadScoreConfig : newItems){
            Boolean isCategoryUpdated = validateIfForCategory(leadScoreConfig, oldItems);
            Boolean isSubCategUpdated = validateIfForSubCategory(leadScoreConfig, oldItems);

            if(isCategoryUpdated){
                leadScoreConfigIds.add(leadScoreConfig.Id);
            }

            if(isSubCategUpdated){
                leadScoreConfigIds.add(leadScoreConfig.Parent_Category__c);
            }
        }     
        
        if(!leadScoreConfigIds.isEmpty()){
            List<AsyncApexJob> asyncJob = [
                SELECT Id, Status, ApexClassID
                  FROM AsyncApexJob
                 WHERE ApexClass.Name = 'LeadScoreConfigRecalculationBatch'
                   AND Status = 'Processing' WITH SYSTEM_MODE
            ];
            if(asyncJob.isEmpty()){
                LeadScoreConfigRecalculationBatch batch = new LeadScoreConfigRecalculationBatch();
                batch.recalculateLeadScore(leadScoreConfigIds);
            }
        }   
    }

    private static Boolean validateIfForSubCategory(Lead_Score_Configuration__c leadScoreConfig, Map<Id, Lead_Score_Configuration__c> oldItems){
        Boolean isSubCategUpdated = 
            leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && 
            leadScoreConfig.Score_Allocation__c != oldItems.get(leadScoreConfig.Id).Score_Allocation__c;
        return isSubCategUpdated;
    }

    private static Boolean validateIfForCategory(Lead_Score_Configuration__c leadScoreConfig, Map<Id, Lead_Score_Configuration__c> oldItems){
        Boolean isCategoryUpdated = 
                leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY && 
                (
                    leadScoreConfig.Max_Score__c != oldItems.get(leadScoreConfig.Id).Max_Score__c ||
                    leadScoreConfig.Time_Limit_Months__c != oldItems.get(leadScoreConfig.Id).Time_Limit_Months__c
                );
        return isCategoryUpdated;
    }

}