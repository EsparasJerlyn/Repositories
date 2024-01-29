/**
 * @description Service Class for Event Registration Lead Score Configuration
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
public with sharing class LeadScoreConfigEventRegService {//NOPMD this is a service class. high number of public methods and overall complexity are expected.
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEventRegistration leadScoreConfigEventRegistration){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_EVENT_REG_ATTD;
        Boolean isForEventReg = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForEventReg){ 
            leadScoreConfigEventRegistration.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigEventRegistration.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_OPEN_DAY_REG){
            leadScoreConfigEventRegistration.setEventRegOpenDayReg(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_OTHER_EVENT_REG){
            leadScoreConfigEventRegistration.setEventRegOtherEventReg(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_OTHER_EVENT_ATTD){
            leadScoreConfigEventRegistration.setEventRegOtherEventAttendance(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Interaction__c> marketingInteractionMap, LeadScoreConfigEventRegistration leadScoreConfigEventRegistration){
        
        Map<Id, Integer> eventRegMap = new Map<Id, Integer>();
        Date today = Date.today();
        
        Integer eventRegistrationCategoryScore = 0;
        for(Marketing_Interaction__c marketingInteraction : marketingInteractionMap.values()){

            if(eventRegMap.containsKey(marketingInteraction.Contact__c)){
                eventRegistrationCategoryScore = eventRegMap.get(marketingInteraction.Contact__c);
            }else if(eventRegMap.containsKey(marketingInteraction.Lead__c)){
                eventRegistrationCategoryScore = eventRegMap.get(marketingInteraction.Lead__c);
            }else{
                eventRegistrationCategoryScore = 0;
            }

            if(validateOpenDay(marketingInteraction, today, leadScoreConfigEventRegistration.getTimeLimit())){
                Integer openDayScore = leadScoreConfigEventRegistration.getEventRegOpenDayReg() != null ? Integer.valueOf(leadScoreConfigEventRegistration.getEventRegOpenDayReg()) : 0;
                eventRegistrationCategoryScore = eventRegistrationCategoryScore + openDayScore;
            }
            if(validateOtherEvent(marketingInteraction, today, leadScoreConfigEventRegistration.getTimeLimit())){
                eventRegistrationCategoryScore = eventRegistrationCategoryScore + leadScoreConfigEventRegistration.getEventRegOtherEventReg();
            }
            if(validateHasOtherEventAttendance(marketingInteraction, today, leadScoreConfigEventRegistration.getTimeLimit())){
                eventRegistrationCategoryScore = eventRegistrationCategoryScore + leadScoreConfigEventRegistration.getEventRegOtherEventAttendance();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(eventRegistrationCategoryScore, leadScoreConfigEventRegistration.getMaxScore());
            if(marketingInteraction.Contact__c != null){
                eventRegMap.put(marketingInteraction.Contact__c, score);
            }
            else if(marketingInteraction.Lead__c != null){
                eventRegMap.put(marketingInteraction.Lead__c, score);
            }
        }
        return eventRegMap;
    }

    private static Boolean validateOpenDay(Marketing_Interaction__c marketingInteraction, Date today, Integer timeLimit){
        return 
            !marketingInteraction.Lead_Score_Reset__c &&
            String.isNotBlank(marketingInteraction.Event_Type__c) && 
            marketingInteraction.Event_Type__c == MarketingInteractionsDAO.EVENT_TYPE_OPEN_DAY &&
            marketingInteraction.Event_Date__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                marketingInteraction.Event_Date__c, 
                marketingInteraction.Event_Date__c.addMonths(timeLimit)
            );
    }

    private static Boolean validateOtherEvent(Marketing_Interaction__c marketingInteraction, Date today, Integer timeLimit){
        return 
            !marketingInteraction.Lead_Score_Reset__c &&
            String.isNotBlank(marketingInteraction.Lead_Source_Category__c) && 
            marketingInteraction.Lead_Source_Category__c == MarketingInteractionsDAO.LEAD_SOURCE_CATEGORY_EVENT &&
            marketingInteraction.Event_Type__c != MarketingInteractionsDAO.EVENT_TYPE_OPEN_DAY &&
            marketingInteraction.Interaction_DateTime__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                marketingInteraction.Interaction_DateTime__c.date(), 
                marketingInteraction.Interaction_DateTime__c.date().addMonths(timeLimit)
            );
    }

    private static Boolean validateHasOtherEventAttendance(Marketing_Interaction__c marketingInteraction, Date today, Integer timeLimit){
        return 
            !marketingInteraction.Lead_Score_Reset__c &&
            marketingInteraction.Has_Attended__c && 
            marketingInteraction.Event_Date__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                marketingInteraction.Event_Date__c, 
                marketingInteraction.Event_Date__c.addMonths(timeLimit)
            );
    }
}