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
public with sharing class LeadScoreConfigEventRegService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEventRegistration leadScoreConfigEventRegistration){
        String category = 'Event Registration and Attendance';
        Boolean isForEventReg = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForEventReg){ 
            leadScoreConfigEventRegistration.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigEventRegistration.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == 'Open Day Registration'){
            leadScoreConfigEventRegistration.setEventRegOpenDayReg(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == 'Other Event Registration'){
            leadScoreConfigEventRegistration.setEventRegOtherEventReg(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(isSubCategory && leadScoreConfig.Name == 'Other Event Attendance'){
            leadScoreConfigEventRegistration.setEventRegOtherEventAttendance(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Interaction__c> marketingInteractionMap, LeadScoreConfigEventRegistration leadScoreConfigEventRegistration){
        
        Map<Id, Integer> eventRegMap = new Map<Id, Integer>();
        Date today = Date.today();
        
        Integer eventRegistrationCategoryScore = 0;
        for(Marketing_Interaction__c marketingInteraction : marketingInteractionMap.values()){
            if(validateOpenDay(marketingInteraction, today, leadScoreConfigEventRegistration.getTimeLimit())){
                Integer openDayScore = leadScoreConfigEventRegistration.getEventRegOpenDayReg() != null ? Integer.valueOf(leadScoreConfigEventRegistration.getEventRegOpenDayReg()) : 0;
                eventRegistrationCategoryScore = eventRegistrationCategoryScore + openDayScore;
            }
            else if(validateOtherEvent(marketingInteraction, today, leadScoreConfigEventRegistration.getTimeLimit())){
                eventRegistrationCategoryScore = eventRegistrationCategoryScore + leadScoreConfigEventRegistration.getEventRegOtherEventReg();
            }
            else if(validateHasOtherEventAttendance(marketingInteraction, today, leadScoreConfigEventRegistration.getTimeLimit())){
                eventRegistrationCategoryScore = eventRegistrationCategoryScore + leadScoreConfigEventRegistration.getEventRegOtherEventAttendance();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(eventRegistrationCategoryScore, leadScoreConfigEventRegistration.getMaxScore());
            if(marketingInteraction.Contact__c != null){
                eventRegMap.put(marketingInteraction.Contact__c, score);
            }
            if(marketingInteraction.Lead__c != null){
                eventRegMap.put(marketingInteraction.Lead__c, score);
            }
        }
        return eventRegMap;
    }

    private static Boolean validateOpenDay(Marketing_Interaction__c marketingInteraction, Date today, Integer timeLimit){

        if( 
            String.isNotBlank(marketingInteraction.Event_Type__c) && 
            marketingInteraction.Event_Type__c == 'Open day' &&
            marketingInteraction.Event_Date__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                marketingInteraction.Event_Date__c, 
                marketingInteraction.Event_Date__c.addMonths(timeLimit)
            )
        ){
            return true;
        }
        return false;
    }

    private static Boolean validateOtherEvent(Marketing_Interaction__c marketingInteraction, Date today, Integer timeLimit){
        if(
            String.isNotBlank(marketingInteraction.Lead_Source_Category__c) && 
            marketingInteraction.Lead_Source_Category__c == 'Event' &&
            marketingInteraction.Interaction_DateTime__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                marketingInteraction.Interaction_DateTime__c.date(), 
                marketingInteraction.Interaction_DateTime__c.date().addMonths(timeLimit)
            )
        ){
            return true;
        }
        return false;
    }

    private static Boolean validateHasOtherEventAttendance(Marketing_Interaction__c marketingInteraction, Date today, Integer timeLimit){
        if(
            marketingInteraction.Has_Attended__c && 
            marketingInteraction.Event_Date__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                today, 
                marketingInteraction.Event_Date__c, 
                marketingInteraction.Event_Date__c.addMonths(timeLimit)
            )
        ){ 
            return true;
        }
        return false;
    }
}