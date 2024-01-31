/**
 * @description Service Class for Funding Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                             |    
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                                               |
      | arsenio.jr.dayrit              | October 23, 2023      | DEPP-6929              | Updated getLeadScoreConfig and  calculateLeadScore methods |
      |                                |                       |                        |                                                            |
 */
public with sharing class LeadScoreConfigFundingService {//NOPMD this is a service class. High number of public methods and overall complexity are expected.

    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigFunding leadScoreConfigFunding, Boolean isDomestic){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_FUNDING;
        Boolean isForFundingCategory = validateCategory(leadScoreConfig, category);
        if(isForFundingCategory){ 
            leadScoreConfigFunding.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigFunding.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(leadScoreConfig, category);
        if(isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COMPANY_FUNDED){
            leadScoreConfigFunding.setCompanyFunded(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }else if(!isDomestic && isSubCategory){
                if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_I_FUND_MY_STUDIES_MYSELF){
                    leadScoreConfigFunding.setIWillFundMyself(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_MY_FAMILY_WILL_FUND_MY_STUDIES){
                    leadScoreConfigFunding.setMyFamilyWillFundMyStudy(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_I_ALREADY_HAVE_A_SCHOLARSHIP_LOAN_OR_SPONSORSHIP){
                    leadScoreConfigFunding.setIAlreadyHaveScholarship(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_I_AM_NOT_SURE){
                    leadScoreConfigFunding.setIAmNotSure(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
                else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_I_NEED_A_FULL_SCHOLARSHIP){
                    leadScoreConfigFunding.setINeedFullScholarship(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
                }
        }
        
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigFunding leadScoreConfigFunding, Boolean isDomestic){

        Map<Id, Integer> fundingMap = new Map<Id, Integer>();
        
        Integer fundingCategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(fundingMap.containsKey(marketingSeg.Contact__c)){
                fundingCategoryScore = fundingMap.get(marketingSeg.Contact__c);
            }else if(fundingMap.containsKey(marketingSeg.Lead__c)){
                fundingCategoryScore = fundingMap.get(marketingSeg.Lead__c);
            }else{
                fundingCategoryScore = 0;
            }

            if(!isDomestic && String.isNotBlank(marketingSeg.My_Funding_Source__c)){
                if(marketingSeg.My_Funding_Source__c == MarketingSegmentationsDAO.CONFIG_SUB_CATEGORY_I_FUND_MY_STUDIES_MYSELF){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getIWillFundMyself();
                }
                else if(marketingSeg.My_Funding_Source__c == MarketingSegmentationsDAO.CONFIG_SUB_CATEGORY_MY_FAMILY_WILL_FUND_MY_STUDIES){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getMyFamilyWillFundMyStudy();
                }
                else if(marketingSeg.My_Funding_Source__c == MarketingSegmentationsDAO.CONFIG_SUB_CATEGORY_I_ALREADY_HAVE_A_SCHOLARSHIP_LOAN_OR_SPONSORSHIP){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getIAlreadyHaveScholarship();
                }
                else if(marketingSeg.My_Funding_Source__c == MarketingSegmentationsDAO.CONFIG_SUB_CATEGORY_I_AM_NOT_SURE){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getIAmNotSure();
                }            
                else if(marketingSeg.My_Funding_Source__c == MarketingSegmentationsDAO.CONFIG_SUB_CATEGORY_I_NEED_A_FULL_SCHOLARSHIP){ 
                    fundingCategoryScore = fundingCategoryScore + leadScoreConfigFunding.getINeedFullScholarship();
                }
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