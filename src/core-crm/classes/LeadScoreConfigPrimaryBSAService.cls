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
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_BSA;
        Boolean isForPrimaryBSA = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForPrimaryBSA){ 
            leadScoreConfigPrimaryBSA.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigPrimaryBSA.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_UNSURE){
            leadScoreConfigPrimaryBSA.setIsUnsure(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_NOT_BLANK){
            leadScoreConfigPrimaryBSA.setIsNotBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_BLANK_UPPER){
            leadScoreConfigPrimaryBSA.setIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigPrimaryBSA leadScoreConfigPrimaryBSA){
        
        Map<Id, Integer> primaryBSAMap = new Map<Id, Integer>();

        Integer primaryBSACategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(primaryBSAMap.containsKey(marketingSeg.Contact__c)){
                primaryBSACategoryScore = primaryBSAMap.get(marketingSeg.Contact__c);
            }else if(primaryBSAMap.containsKey(marketingSeg.Lead__c)){
                primaryBSACategoryScore = primaryBSAMap.get(marketingSeg.Lead__c);
            }else{
                primaryBSACategoryScore = 0;
            }

            if(String.isNotBlank(marketingSeg.My_Primary_BSA__c) && marketingSeg.My_Primary_BSA__c != MarketingSegmentationsDAO.PRIMARY_NSA_BSA_IM_NOT_SURE){ 
                primaryBSACategoryScore = primaryBSACategoryScore + leadScoreConfigPrimaryBSA.getIsNotBlank();
            }
            else if(String.isNotBlank(marketingSeg.My_Primary_BSA__c) && marketingSeg.My_Primary_BSA__c == MarketingSegmentationsDAO.PRIMARY_NSA_BSA_IM_NOT_SURE){ 
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