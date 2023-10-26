/**
 * @description Service Class for Interested in Double Degrees Lead Score Configuration
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
public with sharing class LeadScoreConfigIntDoubleDegService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigIntDoubleDeg leadScoreConfigIntDoubleDeg, Boolean isDomestic){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_DOUBLE_DEG;
        Boolean isForDoubleDeg = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForDoubleDeg){ 
            leadScoreConfigIntDoubleDeg.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigIntDoubleDeg.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(!isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_YES){
            leadScoreConfigIntDoubleDeg.setYes(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(!isDomestic && isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_NO){
            leadScoreConfigIntDoubleDeg.setNo(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }        
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigIntDoubleDeg leadScoreConfigIntDoubleDeg, Boolean isDomestic){
        
        Map<Id, Integer> doubleDegMap = new Map<Id, Integer>();

        Integer doubleDegScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(doubleDegMap.containsKey(marketingSeg.Contact__c)){
                doubleDegScore = doubleDegMap.get(marketingSeg.Contact__c);
            }else if(doubleDegMap.containsKey(marketingSeg.Lead__c)){
                doubleDegScore = doubleDegMap.get(marketingSeg.Lead__c);
            }else{
                doubleDegScore = 0;
            }

            if(!isDomestic && marketingSeg.My_Double_Degree__c){ 
                doubleDegScore = doubleDegScore + leadScoreConfigIntDoubleDeg.getYes();
            }
            else if(!isDomestic && !marketingSeg.My_Double_Degree__c){ 
                doubleDegScore = doubleDegScore + leadScoreConfigIntDoubleDeg.getNo();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(doubleDegScore, leadScoreConfigIntDoubleDeg.getMaxScore());
            if(marketingSeg.Contact__c != null){
                doubleDegMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                doubleDegMap.put(marketingSeg.Lead__c, score);
            }
        }

        return doubleDegMap;
    }
}