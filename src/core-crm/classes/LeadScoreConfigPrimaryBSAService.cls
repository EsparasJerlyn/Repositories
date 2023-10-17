/**
 * @description Service Class for Primary BSA Lead Score Configuration
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
public with sharing class LeadScoreConfigPrimaryBSAService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigPrimaryBSA leadScoreConfigPrimaryBSA){
        String category = 'Primary BSA';
        Boolean isForPrimaryBSA = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForPrimaryBSA){ 
            leadScoreConfigPrimaryBSA.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigPrimaryBSA.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == 'Is unsure'){
            leadScoreConfigPrimaryBSA.setIsUnsure(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == 'Is not blank'){
            leadScoreConfigPrimaryBSA.setIsNotBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == 'Is blank'){
            leadScoreConfigPrimaryBSA.setIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigPrimaryBSA leadScoreConfigPrimaryBSA){
        
        Map<Id, Integer> primaryBSAMap = new Map<Id, Integer>();

        Integer primaryBSACategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){
            if(String.isNotBlank(marketingSeg.My_Primary_BSA__c) && marketingSeg.My_Primary_BSA__c != 'I am not sure'){ 
                primaryBSACategoryScore = primaryBSACategoryScore + leadScoreConfigPrimaryBSA.getIsNotBlank();
            }
            else if(String.isNotBlank(marketingSeg.My_Primary_BSA__c) && marketingSeg.My_Primary_BSA__c == 'I am not sure'){ 
                primaryBSACategoryScore = primaryBSACategoryScore + leadScoreConfigPrimaryBSA.getIsUnsure();
            }
            else if(String.isBlank(marketingSeg.My_Primary_BSA__c)){ 
                primaryBSACategoryScore = primaryBSACategoryScore + leadScoreConfigPrimaryBSA.getIsBlank();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(primaryBSACategoryScore, leadScoreConfigPrimaryBSA.getMaxScore());
            if(marketingSeg.Contact__c != null){
                primaryBSAMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                primaryBSAMap.put(marketingSeg.Lead__c, score);
            }
        }

        return primaryBSAMap;
    }
    
}