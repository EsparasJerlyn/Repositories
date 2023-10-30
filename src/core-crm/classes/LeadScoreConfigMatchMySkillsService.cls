/**
 * @description Service Class for Match My Skills Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 03, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigMatchMySkillsService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigMatchMySkills leadScoreConfigMatchMySkills){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_MATCH_MY_SKILLS;
        Boolean isForMatchMySkills = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForMatchMySkills){ 
            leadScoreConfigMatchMySkills.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigMatchMySkills.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_MATCH_MY_SKILLS_COMP){
            leadScoreConfigMatchMySkills.setCompleted(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Interaction__c> marketingInteractionMap, LeadScoreConfigMatchMySkills leadScoreConfigMatchMySkills){
        Map<Id, Integer> matchMySkillsMap = new Map<Id, Integer>();
        
        Integer matchMySkillScore = 0;
        for(Marketing_Interaction__c marketingInteraction : marketingInteractionMap.values()){

            if(matchMySkillsMap.containsKey(marketingInteraction.Contact__c)){
                matchMySkillScore = matchMySkillsMap.get(marketingInteraction.Contact__c);
            }else if(matchMySkillsMap.containsKey(marketingInteraction.Lead__c)){
                matchMySkillScore = matchMySkillsMap.get(marketingInteraction.Lead__c);
            }else{
                matchMySkillScore = 0;
            }

            if(
                marketingInteraction.Lead_Source__c == MarketingInteractionsDAO.LEAD_SOURCE_MMS &&
                String.isNotBlank(marketingInteraction.Match_My_Skill_Completion__c) && 
                marketingInteraction.Match_My_Skill_Completion__c.toUppercase() == MarketingInteractionsDAO.MATCH_MY_SKILL_COMPLETION_UPPER
            ){ 
                matchMySkillScore = matchMySkillScore + leadScoreConfigMatchMySkills.getCompleted();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(matchMySkillScore, leadScoreConfigMatchMySkills.getMaxScore());
            if(marketingInteraction.Contact__c != null){
                matchMySkillsMap.put(marketingInteraction.Contact__c, score);
            }
            else if(marketingInteraction.Lead__c != null){
                matchMySkillsMap.put(marketingInteraction.Lead__c, score);
            }
        }

        return matchMySkillsMap;
    }
}