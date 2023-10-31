/**
 * @description Service Class for Email Interaction Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */

public with sharing class LeadScoreConfigEmailInteractService {

    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEmailInteract leadScoreConfigEmailInteract){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_EMAIL_INTERACTION;
        
        Boolean isForEmailInteraction = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForEmailInteraction){ 
            leadScoreConfigEmailInteract.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigEmailInteract.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_HAS_CLICKED_EMAIL){
            leadScoreConfigEmailInteract.setHasClickedEmail(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap, LeadScoreConfigEmailInteract leadScoreConfigEmailInteract){
        Map<Id, Integer> emailMap = new Map<Id, Integer>();
        Integer indivEmailScore = 0;
        Date today = Date.today();

        for(et4ae5__IndividualEmailResult__c indvEmail : indivEmailMap.values()){

            if(emailMap.containsKey(indvEmail.et4ae5__Contact__c)){
                indivEmailScore = emailMap.get(indvEmail.et4ae5__Contact__c);
            }else if(emailMap.containsKey(indvEmail.et4ae5__Lead__c)){
                indivEmailScore = emailMap.get(indvEmail.et4ae5__Lead__c);
            }else{
                indivEmailScore = 0;
            }

            if(
                validateIndivEmailRecord(indvEmail, today, leadScoreConfigEmailInteract.getTimeLimit())                 
            ){
                indivEmailScore = indivEmailScore + leadScoreConfigEmailInteract.getHasClickedEmail();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(indivEmailScore, leadScoreConfigEmailInteract.getMaxScore());
            if(indvEmail.et4ae5__Contact__c != null){
                
                emailMap.put(indvEmail.et4ae5__Contact__c, score);
            }else if(indvEmail.et4ae5__Lead__c != null){
                
                emailMap.put(indvEmail.et4ae5__Lead__c, score);
            }

        }

        return emailMap;
    }

    private static Boolean validateIndivEmailRecord(et4ae5__IndividualEmailResult__c indvEmail, Date today, Integer timeLimit){
        return 
            indvEmail.et4ae5__DateOpened__c != null &&
            indvEmail.et4ae5__Opened__c && 
            indvEmail.et4ae5__Clicked__c &&
            !indvEmail.Lead_Score_Reset__c &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                indvEmail.et4ae5__DateOpened__c.date(), 
                indvEmail.et4ae5__DateOpened__c.date().addMonths(timeLimit)
            );
    }
}