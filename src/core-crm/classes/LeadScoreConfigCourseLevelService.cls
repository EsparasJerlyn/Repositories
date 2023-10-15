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
            if(leadScoreConfig.Name == 'Postgraduate'){
                leadScoreConfigCourseLevel.setStudyLevelPostGrad(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == 'Higher Degree Research'){
                leadScoreConfigCourseLevel.setStudyLevelHigherDeg(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == 'Short courses and Professional Development'){
                leadScoreConfigCourseLevel.setStudyLevelShortCoursePD(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == 'Exchange and Study Abroad (1 or 2 Semesters Only)'){
                leadScoreConfigCourseLevel.setStudyLevelExchange(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == 'Is blank'){
                leadScoreConfigCourseLevel.setStudyLevelIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == 'Undergraduate'){
                leadScoreConfigCourseLevel.setStudyLevelUnderGrad(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigCourseLevel leadScoreConfigCourseLevel){
        
        Map<Id, Integer> courseLevelMap = new Map<Id, Integer>();

        Integer courseLevelScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){
            if(String.isNotBlank(marketingSeg.My_Primary_Study_Level__c)){
                getLeadScore(marketingSeg, courseLevelScore, leadScoreConfigCourseLevel);
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

    private static void getLeadScore(Marketing_Segmentation__c marketingSeg, Integer courseLevelScore, LeadScoreConfigCourseLevel leadScoreConfigCourseLevel){
        if(marketingSeg.My_Primary_Study_Level__c == 'Undergraduate'){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelUnderGrad();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == 'Postgraduate'){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelPostGrad();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == 'Higher Degree Research'){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelHigherDeg();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == 'Short Courses and Professional Development'){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelShortCoursePD();
        }
        else if(marketingSeg.My_Primary_Study_Level__c == 'Exchange and Study Abroad (1 or 2 Semesters Only)'){ 
            courseLevelScore = courseLevelScore + leadScoreConfigCourseLevel.getStudyLevelExchange();
        }
    }

    private static Boolean validateIfForCourseLevel(Lead_Score_Configuration__c leadScoreConfig, String category) {
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }
    
    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category) {
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
}