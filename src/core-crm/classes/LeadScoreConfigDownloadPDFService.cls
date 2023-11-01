/**
 * @description Service Class for Download PDF Lead Score Configuration
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
public with sharing class LeadScoreConfigDownloadPDFService {
    
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigDownloadPDF leadScoreConfigDownloadPDF, Boolean isDomestic){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_DOWNLOADED_PDF;
        Boolean isForDownloadPDF = validateIfForDownloadPDFCategory(category, leadScoreConfig);
        if(isForDownloadPDF){ 
            leadScoreConfigDownloadPDF.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigDownloadPDF.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(category, leadScoreConfig);
        if(isSubCategory){
            if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COURSE_PAGE_PDF){
                leadScoreConfigDownloadPDF.setCoursePagePDF(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(isDomestic && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_WELCOME_GUIDE){
                leadScoreConfigDownloadPDF.setWelcomeGuide(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(!isDomestic && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COURSE_GUIDE){
                leadScoreConfigDownloadPDF.setCourseGuide(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }     
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Interaction__c> marketingInteractionMap, LeadScoreConfigDownloadPDF leadScoreConfigDownloadPDF, Boolean isDomestic){
        Map<Id, Integer> downloadPDFMap = new Map<Id, Integer>();
        Integer downloadPDFScore = 0;
        
        for(Marketing_Interaction__c marketingInteraction : marketingInteractionMap.values()){

            Boolean isValid = validateRecord(marketingInteraction, leadScoreConfigDownloadPDF.getTimeLimit());

            if(downloadPDFMap.containsKey(marketingInteraction.Contact__c)){
                downloadPDFScore = downloadPDFMap.get(marketingInteraction.Contact__c);
            }else if(downloadPDFMap.containsKey(marketingInteraction.Lead__c)){
                downloadPDFScore = downloadPDFMap.get(marketingInteraction.Lead__c);
            }else{
                downloadPDFScore = 0;
            }

            if(validateCoursePagePDF(isValid, marketingInteraction)){ 
                downloadPDFScore = downloadPDFScore + leadScoreConfigDownloadPDF.getCoursePagePDF();
            }
            else if(validateWelcomeGuide(isValid, marketingInteraction, isDomestic)){ 
                downloadPDFScore = downloadPDFScore + leadScoreConfigDownloadPDF.getWelcomeGuide();
            }
            else if(validateCourseGuide(isValid, marketingInteraction, isDomestic)){                
                downloadPDFScore = downloadPDFScore + leadScoreConfigDownloadPDF.getCourseGuide();
            }

            Integer score = LeadScoreCalculatorService.validateScore(downloadPDFScore, leadScoreConfigDownloadPDF.getMaxScore());
            
            if(marketingInteraction.Contact__c != null){
                downloadPDFMap.put(marketingInteraction.Contact__c, score);
            }
            else if(marketingInteraction.Lead__c != null){
                downloadPDFMap.put(marketingInteraction.Lead__c, score);
            }
        }

        return downloadPDFMap;
    }

    private static Boolean validateCoursePagePDF(Boolean isValid, Marketing_Interaction__c marketingInteraction){
        return isValid && marketingInteraction.Lead_Source__c == MarketingInteractionsDAO.LEAD_SOURCE_COURSE_PAGE_PDF;
    }

    private static Boolean validateWelcomeGuide(Boolean isValid, Marketing_Interaction__c marketingInteraction, Boolean isDomestic){
        return isValid && isDomestic && marketingInteraction.Lead_Source__c == MarketingInteractionsDAO.LEAD_SOURCE_WELCOME_GUIDE;
    }

    private static Boolean validateCourseGuide(Boolean isValid, Marketing_Interaction__c marketingInteraction, Boolean isDomestic){
        return isValid && !isDomestic && marketingInteraction.Lead_Source__c == MarketingInteractionsDAO.LEAD_SOURCE_COURSE_GUIDE;
    }

    private static Boolean validateRecord(Marketing_Interaction__c marketingInteraction, Integer timeLimit){
        return 
            String.isNotBlank(marketingInteraction.Lead_Source__c) && 
            !marketingInteraction.Lead_Score_Reset__c &&
            marketingInteraction.Interaction_DateTime__c != null &&
            DateService.isDateWithinRangeDefaultFalse(
                Date.today(), 
                marketingInteraction.Interaction_DateTime__c.date(), 
                marketingInteraction.Interaction_DateTime__c.date().addMonths(timeLimit)
            );
    }

    private static Boolean validateIfForDownloadPDFCategory(String category, Lead_Score_Configuration__c leadScoreConfig){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(String category, Lead_Score_Configuration__c leadScoreConfig){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
   
}