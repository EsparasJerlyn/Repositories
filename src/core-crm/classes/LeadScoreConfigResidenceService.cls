/**
 * @description Service Class for Residence Lead Score Configuration
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
public with sharing class LeadScoreConfigResidenceService {
    
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigResidence leadScoreConfigResidence, Boolean isDomestic){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_RESIDENCE;
        Boolean isForResidency = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForResidency){ 
            leadScoreConfigResidence.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigResidence.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(!isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_AU_ONSHORE){
            leadScoreConfigResidence.setAustraliaOnshore(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(!isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_NON_AU_OFFSHORE){
            leadScoreConfigResidence.setNonAustraliaOffShore(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }        
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigResidence leadScoreConfigResidence, Boolean isDomestic){
        
        Map<Id, Integer> residenceMap = new Map<Id, Integer>();

        Integer residenceCategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(residenceMap.containsKey(marketingSeg.Contact__c)){
                residenceCategoryScore = residenceMap.get(marketingSeg.Contact__c);
            }else if(residenceMap.containsKey(marketingSeg.Lead__c)){
                residenceCategoryScore = residenceMap.get(marketingSeg.Lead__c);
            }else{
                residenceCategoryScore = 0;
            }

            if(!isDomestic && String.isNotBlank(marketingSeg.My_Country_Of_Residency__c)){
                residenceCategoryScore = residenceCategoryScore + leadScoreConfigResidence.getNonAustraliaOffShore();
                if(marketingSeg.My_Country_Of_Residency__c == MarketingSegmentationsDAO.COUNTRY_AU){ 
                    residenceCategoryScore = residenceCategoryScore + leadScoreConfigResidence.getAustraliaOnshore();
                }
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(residenceCategoryScore, leadScoreConfigResidence.getMaxScore());
            if(marketingSeg.Contact__c != null){
                residenceMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                residenceMap.put(marketingSeg.Lead__c, score);
            }
        }

        return residenceMap;
    }
}