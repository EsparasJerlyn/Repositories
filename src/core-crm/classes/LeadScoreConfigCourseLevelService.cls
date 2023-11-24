/**
 * @description Service Class for Course Level Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      | arsenio.jr.dayrit              | November 13, 2023     | DEPP-7210              | Updated getLeadScore Method  |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigCourseLevelService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigCourseLevel leadScoreConfigCourseLevel){
        String category = 'Course Level';
        Boolean isForCourseLevel = validateIfForCourseLevel(leadScoreConfig, category);
        if(isForCourseLevel){ 
            leadScoreConfigCourseLevel.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigCourseLevel.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(leadScoreConfig, category);
        if(isSubCategory){
            if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_POSTGRAD){
                leadScoreConfigCourseLevel.setStudyLevelPostGrad(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_HIGHER_DEGREE){
                leadScoreConfigCourseLevel.setStudyLevelHigherDeg(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_SHORT_COURSES){
                leadScoreConfigCourseLevel.setStudyLevelShortCoursePD(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_EXCHANGE_AND_STUDY){
                leadScoreConfigCourseLevel.setStudyLevelExchange(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_BLANK_UPPER){
                leadScoreConfigCourseLevel.setStudyLevelIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_UNDERGRAD){
                leadScoreConfigCourseLevel.setStudyLevelUnderGrad(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigCourseLevel leadScoreConfigCourseLevel){
  
        Map<Id, Integer> courseLevelMap = new Map<Id, Integer>();

        Integer courseLevelScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(courseLevelMap.containsKey(marketingSeg.Contact__c)){
                courseLevelScore = courseLevelMap.get(marketingSeg.Contact__c);
            }else if(courseLevelMap.containsKey(marketingSeg.Lead__c)){
                courseLevelScore = courseLevelMap.get(marketingSeg.Lead__c);
            }else{
                courseLevelScore = 0;
            }

            if(String.isNotBlank(marketingSeg.My_Primary_Study_Level__c)){
                courseLevelScore = getLeadScore(marketingSeg, courseLevelScore, leadScoreConfigCourseLevel);
            }else{
                courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelIsBlank();   
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(courseLevelScore, leadScoreConfigCourseLevel.getMaxScore());
            if(marketingSeg.Contact__c != null){
                courseLevelMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                courseLevelMap.put(marketingSeg.Lead__c, score);
            }
        }

        return courseLevelMap;
    }

    private static Integer getLeadScore(Marketing_Segmentation__c marketingSeg, Integer courseLevelScore, LeadScoreConfigCourseLevel leadScoreConfigCourseLevel){
        if(marketingSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.STUDY_LEVEL_UNDERGRAD){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelUnderGrad();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.STUDY_LEVEL_POSTGRAD){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelPostGrad();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.STUDY_LEVEL_HIGHER_DEGREE){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelHigherDeg();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.STUDY_LEVEL_SHORT_COURSES){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelShortCoursePD();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.STUDY_LEVEL_EXCHANGE_AND_STUDY){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelExchange();
        }

        return courseLevelScore;
    }

    private static Boolean validateIfForCourseLevel(Lead_Score_Configuration__c leadScoreConfig, String category) {
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }
    
    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category) {
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
}