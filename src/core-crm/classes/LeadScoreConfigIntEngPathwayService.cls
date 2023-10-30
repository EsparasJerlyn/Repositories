/**
 * @description Service Class for Interested in English Pathway Programs Lead Score Configuration
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
public with sharing class LeadScoreConfigIntEngPathwayService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigIntEngPathway leadScoreConfigIntEngPathway, Boolean isDomestic){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_ENG_PATH;
        Boolean isForEngPath = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForEngPath){ 
            leadScoreConfigIntEngPathway.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigIntEngPathway.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(!isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_YES){
            leadScoreConfigIntEngPathway.setYes(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(!isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_NO){
            leadScoreConfigIntEngPathway.setNo(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }        
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigIntEngPathway leadScoreConfigIntEngPathway, Boolean isDomestic){
        
        Map<Id, Integer> engPathMap = new Map<Id, Integer>();

        Integer engPathScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(engPathMap.containsKey(marketingSeg.Contact__c)){
                engPathScore = engPathMap.get(marketingSeg.Contact__c);
            }else if(engPathMap.containsKey(marketingSeg.Lead__c)){
                engPathScore = engPathMap.get(marketingSeg.Lead__c);
            }else{
                engPathScore = 0;
            }

            if(!isDomestic && marketingSeg.My_Interested_English_Pathways__c){ 
                engPathScore = engPathScore + leadScoreConfigIntEngPathway.getYes();
            }
            else if(!isDomestic && !marketingSeg.My_Interested_English_Pathways__c){ 
                engPathScore = engPathScore + leadScoreConfigIntEngPathway.getNo();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(engPathScore, leadScoreConfigIntEngPathway.getMaxScore());
            if(marketingSeg.Contact__c != null){
                engPathMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                engPathMap.put(marketingSeg.Lead__c, score);
            }
        }

        return engPathMap;
    }
}