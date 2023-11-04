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
 */
public with sharing class LeadScoreConfigTriggerHelper {
    
    public static void processLeadScoreCalculation(List<Lead_Score_Configuration__c> newItems, Map<Id, Lead_Score_Configuration__c> oldItems){

        Set<Id> leadScoreConfigIds = new Set<Id>();
        Set<Id> parentCategoryIds = new Set<Id>();
        Map<Id, Lead_Score_Configuration__c> configMap = new Map<Id,Lead_Score_Configuration__c>();
        Set<String> citizenshipStatusSet = new Set<String>();
        Set<String> primaryStudyLevelSet = new Set<String>();

        for(Lead_Score_Configuration__c leadScoreConfig : newItems){
            Boolean isCategoryUpdated = validateIfForCategory(leadScoreConfig, oldItems);
            Boolean isSubCategUpdated = validateIfForSubCategory(leadScoreConfig, oldItems);

            if(isCategoryUpdated){
                configMap.put(leadScoreConfig.Id, leadScoreConfig);
                citizenshipStatusSet.add(leadScoreConfig.Domestic_International__c);
                primaryStudyLevelSet.add(leadScoreConfig.Study_Level__c);
                leadScoreConfigIds.add(leadScoreConfig.Id);
            }

            if(isSubCategUpdated){
                parentCategoryIds.add(leadScoreConfig.Parent_Category__c);
                leadScoreConfigIds.add(leadScoreConfig.Parent_Category__c);
            }
        }     
        
        if(!leadScoreConfigIds.isEmpty()){
            LeadScoreConfigRecalculationBatch batch = new LeadScoreConfigRecalculationBatch();
            batch.recalculateLeadScore(leadScoreConfigIds);
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