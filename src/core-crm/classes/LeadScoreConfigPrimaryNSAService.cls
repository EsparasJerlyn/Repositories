/**
 * @description Service Class for Primary NSA Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigPrimaryNSAService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigPrimaryNSA leadScoreConfigPrimaryNSA){
        String category = 'Primary NSA';
        Boolean isForPrimaryNSA = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForPrimaryNSA){ 
            leadScoreConfigPrimaryNSA.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigPrimaryNSA.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == 'Is unsure'){
            leadScoreConfigPrimaryNSA.setIsUnsure(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == 'Is not blank'){
            leadScoreConfigPrimaryNSA.setIsNotBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == 'Is blank'){
            leadScoreConfigPrimaryNSA.setIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigPrimaryNSA leadScoreConfigPrimaryNSA){
        Map<Id, Integer> primaryNSAMap = new Map<Id, Integer>();

        Integer primaryNSACategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){
            if(String.isNotBlank(marketingSeg.My_Primary_NSA__c) && marketingSeg.My_Primary_NSA__c != 'I am not sure'){ 
                primaryNSACategoryScore = primaryNSACategoryScore + leadScoreConfigPrimaryNSA.getIsNotBlank();
            }
            else if(String.isNotBlank(marketingSeg.My_Primary_NSA__c) && marketingSeg.My_Primary_NSA__c == 'I am not sure'){ 
            primaryNSACategoryScore = primaryNSACategoryScore + leadScoreConfigPrimaryNSA.getIsUnsure();
            }
            else if(String.isBlank(marketingSeg.My_Primary_NSA__c)){ 
                primaryNSACategoryScore = primaryNSACategoryScore + leadScoreConfigPrimaryNSA.getIsBlank();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(primaryNSACategoryScore, leadScoreConfigPrimaryNSA.getMaxScore());
            if(marketingSeg.Contact__c != null){
                primaryNSAMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                primaryNSAMap.put(marketingSeg.Lead__c, score);
            }
        }

        return primaryNSAMap;
    }
}