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
        String category = 'Downloaded PDF';
        Boolean isForDownloadPDF = validateIfForDownloadPDFCategory(category, leadScoreConfig);
        if(isForDownloadPDF){ 
            leadScoreConfigDownloadPDF.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigDownloadPDF.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(category, leadScoreConfig);
        if(isSubCategory){
            if(leadScoreConfig.Name == 'Course Page PDF'){
                leadScoreConfigDownloadPDF.setCoursePagePDF(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(isDomestic && leadScoreConfig.Name == 'Welcome Guide'){
                leadScoreConfigDownloadPDF.setWelcomeGuide(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }
            else if(!isDomestic && leadScoreConfig.Name == 'Course Guides'){
                leadScoreConfigDownloadPDF.setCourseGuide(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
            }     
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Interaction__c> marketingInteractionMap, LeadScoreConfigDownloadPDF leadScoreConfigDownloadPDF, Boolean isDomestic){
        Map<Id, Integer> downloadPDFMap = new Map<Id, Integer>();
        Integer downloadPDFScore = 0;
        
        for(Marketing_Interaction__c marketingInteraction : marketingInteractionMap.values()){
            Boolean isValid = validateLeadSource(marketingInteraction);
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
        return isValid && marketingInteraction.Lead_Source__c == 'Course Page PDF Download';
    }

    private static Boolean validateWelcomeGuide(Boolean isValid, Marketing_Interaction__c marketingInteraction, Boolean isDomestic){
        return isValid && isDomestic && marketingInteraction.Lead_Source__c == 'Welcome Guide Download';
    }

    private static Boolean validateCourseGuide(Boolean isValid, Marketing_Interaction__c marketingInteraction, Boolean isDomestic){
        return isValid && !isDomestic && marketingInteraction.Lead_Source__c == 'Course Guide Download';
    }

    private static Boolean validateLeadSource(Marketing_Interaction__c marketingInteraction){
        return String.isNotBlank(marketingInteraction.Lead_Source__c);
    }

    private static Boolean validateIfForDownloadPDFCategory(String category, Lead_Score_Configuration__c leadScoreConfig){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(String category, Lead_Score_Configuration__c leadScoreConfig){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
   
}