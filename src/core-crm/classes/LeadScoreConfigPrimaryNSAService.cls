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
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_NSA;
        Boolean isForPrimaryNSA = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForPrimaryNSA){ 
            leadScoreConfigPrimaryNSA.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigPrimaryNSA.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_UNSURE){
            leadScoreConfigPrimaryNSA.setIsUnsure(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_NOT_BLANK){
            leadScoreConfigPrimaryNSA.setIsNotBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_BLANK_UPPER){
            leadScoreConfigPrimaryNSA.setIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigPrimaryNSA leadScoreConfigPrimaryNSA){
        Map<Id, Integer> primaryNSAMap = new Map<Id, Integer>();

        Integer primaryNSACategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(primaryNSAMap.containsKey(marketingSeg.Contact__c)){
                primaryNSACategoryScore = primaryNSAMap.get(marketingSeg.Contact__c);
            }else if(primaryNSAMap.containsKey(marketingSeg.Lead__c)){
                primaryNSACategoryScore = primaryNSAMap.get(marketingSeg.Lead__c);
            }else{
                primaryNSACategoryScore = 0;
            }

            if(String.isNotBlank(marketingSeg.My_Primary_NSA__c) && marketingSeg.My_Primary_NSA__c != MarketingSegmentationsDAO.PRIMARY_NSA_BSA_IM_NOT_SURE){ 
                primaryNSACategoryScore = primaryNSACategoryScore + leadScoreConfigPrimaryNSA.getIsNotBlank();
            }
            else if(String.isNotBlank(marketingSeg.My_Primary_NSA__c) && marketingSeg.My_Primary_NSA__c == MarketingSegmentationsDAO.PRIMARY_NSA_BSA_IM_NOT_SURE){ 
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