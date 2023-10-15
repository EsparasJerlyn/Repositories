/**
 * @description Service Class for Funding Lead Score Configuration
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
public with sharing class LeadScoreConfigFundingService {    

    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigFunding leadScoreConfigFunding, Boolean isDomestic){
        String category = 'Funding';
        Boolean isForFundingCategory = validateCategory(leadScoreConfig, category);
        if(isForFundingCategory){ 
            leadScoreConfigFunding.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigFunding.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(leadScoreConfig, category);
        if(isDomestic && isSubCategory && leadScoreConfig.Name == 'Company Funded'){
            leadScoreConfigFunding.setCompanyFunded(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }else if(!isDomestic && isSubCategory){
                if(leadScoreConfig.Name == 'I will fund my studies myself'){
                    leadScoreConfigFunding.setIWillFundMyself(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == 'My family will fund my studies'){
                    leadScoreConfigFunding.setMyFamilyWillFundMyStudy(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == 'I already have a scholarship, loan or sponsorship'){
                    leadScoreConfigFunding.setIAlreadyHaveScholarship(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == 'I am not sure'){
                    leadScoreConfigFunding.setIAmNotSure(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == 'I need a full scholarship'){
                    leadScoreConfigFunding.setINeedFullScholarship(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
        }
        
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigFunding leadScoreConfigFunding, Boolean isDomestic){
        
        Map<Id, Integer> fundingMap = new Map<Id, Integer>();

        Integer fundingCategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){
            if(!isDomestic && String.isNotBlank(marketingSeg.My_Funding_Source__c)){
                if(marketingSeg.My_Funding_Source__c == 'I will fund my studies myself'){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getIWillFundMyself();
                }
                else if(marketingSeg.My_Funding_Source__c == 'My family will fund my studies'){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getMyFamilyWillFundMyStudy();
                }
                else if(marketingSeg.My_Funding_Source__c == 'I already have a scholarship, loan or sponsorship'){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getIAlreadyHaveScholarship();
                }
                else if(marketingSeg.My_Funding_Source__c == 'I am not sure'){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getIAmNotSure();
                }            
                else if(marketingSeg.My_Funding_Source__c == 'I need a full scholarship'){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getINeedFullScholarship();
                }
            }else if(isDomestic && String.isBlank(marketingSeg.My_Funding_Source__c)){ 
                fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getCompanyFunded();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(fundingCategoryScore, leadScoreConfigFunding.getMaxScore());
            if(marketingSeg.Contact__c != null){
                fundingMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                fundingMap.put(marketingSeg.Lead__c, score);
            }
        }

        return fundingMap;
    }

    private static Boolean validateCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
  
}