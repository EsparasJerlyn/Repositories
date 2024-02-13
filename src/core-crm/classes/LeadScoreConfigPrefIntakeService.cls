/**
 * @description Service Class for Preferred Intake Lead Score Configuration
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
public with sharing class LeadScoreConfigPrefIntakeService {//NOPMD this is a service class, high number of public methods and class complexity are expected.
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigPreferredIntake leadScoreConfigPreferredIntake){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_PREF_INTAKE;
        Boolean isFOrPreferredIntake = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isFOrPreferredIntake){ 
            leadScoreConfigPreferredIntake.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigPreferredIntake.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory){
            if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_ROLLING_EACH_YR){
                leadScoreConfigPreferredIntake.setIsThisYear(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_NEXT_YEAR){
                leadScoreConfigPreferredIntake.setIsNextYear(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_NOT_BLANK){
                leadScoreConfigPreferredIntake.setIsNotBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_BLANK_UPPER){
                leadScoreConfigPreferredIntake.setIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
        }
        
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigPreferredIntake leadScoreConfigPreferredIntake){
        Map<Id, Integer> preferredIntakeMap = new Map<Id, Integer>();

        Integer thisYear = Date.today().year();
        Integer nextYear = thisYear + 1;

        Integer preferredIntakeCategoryScore = 0;
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(preferredIntakeMap.containsKey(marketingSeg.Contact__c)){
                preferredIntakeCategoryScore = preferredIntakeMap.get(marketingSeg.Contact__c);
            }else if(preferredIntakeMap.containsKey(marketingSeg.Lead__c)){
                preferredIntakeCategoryScore = preferredIntakeMap.get(marketingSeg.Lead__c);
            }else{
                preferredIntakeCategoryScore = 0;
            }

            if(marketingSeg.My_Expected_Admission_Year__c != null){
                if(marketingSeg.My_Expected_Admission_Year__c == thisYear){ 
                    preferredIntakeCategoryScore = preferredIntakeCategoryScore + leadScoreConfigPreferredIntake.getIsThisYear();
                }
                else if(marketingSeg.My_Expected_Admission_Year__c == nextYear){ 
                    preferredIntakeCategoryScore = preferredIntakeCategoryScore + leadScoreConfigPreferredIntake.getIsNextYear();
                }
                else if(marketingSeg.My_Expected_Admission_Year__c != thisYear && marketingSeg.My_Expected_Admission_Year__c != nextYear){ 
                    preferredIntakeCategoryScore = preferredIntakeCategoryScore + leadScoreConfigPreferredIntake.getIsNotBlank();
                }
            }
            if(marketingSeg.My_Expected_Admission_Year__c == null){ 
                preferredIntakeCategoryScore = preferredIntakeCategoryScore + leadScoreConfigPreferredIntake.getIsBlank();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(preferredIntakeCategoryScore, leadScoreConfigPreferredIntake.getMaxScore());
            if(marketingSeg.Contact__c != null){
                preferredIntakeMap.put(marketingSeg.Contact__c, score);
            }
            else if(marketingSeg.Lead__c != null){
                preferredIntakeMap.put(marketingSeg.Lead__c, score);
            }
        }

        return preferredIntakeMap;
    }
}