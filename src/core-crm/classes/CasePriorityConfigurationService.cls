/**
 * @description Service Class for any involcing Case Priority Configuration Service
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426	            | Created File                  | 
 *    | eccarius.munoz                 | February 15, 2024     | DEPP-7714	            | Added Tier Subcategory check  | 
 *    |                                |                       |        	            | in matchCountryTier method    | 
 *    | eccarius.munoz                 | February 19, 2024     | DEPP-7867	            | Added Lead Source categ check |
 *    |                                |                       |        	            | in matchConfigToCaseBase      | 
 *    | gabriel.p.ventayen             | April 22, 2024        | DEPP-8544	            | add case type checks          |
 *    |                                |                       |        	            | to matchConfigCaseBase        | 
 */
public inherited sharing class CasePriorityConfigurationService {

    public static Boolean matchCountryTier(
        Case item,
        Case_Priority_Configuration__c config,
        Map<String, International_Tier__c> countryTierMap
    ) {
        Boolean trueSoFar = true;

        Boolean isTierCategNotMatch = 
            config.Country_Tier__c != null &&
            config.Country_Tier__c != countryTierMap.get(item.Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c)?.Tier_Category__c &&
            config.Country_Tier__c != countryTierMap.get(item.Contact.Citizenship_Country__c)?.Tier_Category__c;

        Boolean isTierSubCategNotMatch = 
            config.Country_Tier_Subcategory__c != null &&
            config.Country_Tier_Subcategory__c != countryTierMap.get(item.Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c)?.Tier_Subcategory__c &&
            config.Country_Tier_Subcategory__c != countryTierMap.get(item.Contact.Citizenship_Country__c)?.Tier_Subcategory__c;

        if (isTierCategNotMatch || isTierSubCategNotMatch) {
            trueSoFar = false;
        }

        return trueSoFar;
    }

    public static Boolean matchConfigToCaseBase(Case item, Case_Priority_Configuration__c config) {
        Boolean trueSoFar = config.Case_Record_Type__c != null
            ? CasesDAO.CASE_RECTYPE_MAP.get(config.Case_Record_Type__c) == item.RecordTypeId
            : true;

        Boolean isCaseTypeValid = 
            config.Case_Type__c != null &&
            config.Case_Type__c != item.Case_Type__c;

        if (isCaseTypeValid) {
            trueSoFar = false;
        }

        Boolean isLeadScoreValid = 
            config.Lead_Score__c != null &&
            config.Lead_Score__c != item.Lead__r.Lead_Score__c &&
            config.Lead_Score__c != item.Contact.Lead_Score__c;

        if (isLeadScoreValid) {
            trueSoFar = false;
        }

        Boolean isFutureStudStageValid = 
            config.Future_Student_Stage__c != null &&
            config.Future_Student_Stage__c != item.Lead__r.Future_Student_Journey_Status__c &&
            config.Future_Student_Stage__c != item.Contact.Future_Student_Journey_Status__c;

        if (isFutureStudStageValid) {
            trueSoFar = false;
        }

        Boolean isLeadScoreCategoryValid = 
            config.Lead_Source_Category__c != null &&
            config.Lead_Source_Category__c != item.Lead__r.Lead_Source_Category__c &&
            config.Lead_Source_Category__c != item.Contact.Lead_Source_Category__c;
        if (isLeadScoreCategoryValid) {
            trueSoFar = false;
        }

        Boolean isApplicantOnshoreValid = 
            config.Applicant_Onshore__c != null &&
            config.Applicant_Onshore__c != item.Contact.Applicant_Onshore__c;
        if (isApplicantOnshoreValid) {
            trueSoFar = false;
        }
        
        return trueSoFar;
    }

    public static Boolean matchCategoryAndSubCategory(
        Case item,
        Case_Priority_Configuration__c config
    ) {
        Boolean trueSoFar = (config.Enquiry_Category__c != null
            ? config.Enquiry_Category__c.split(';').contains(item.Category__c)
            : true && config.Enquiry_Sub_Category__c != null
                  ? config.Enquiry_Sub_Category__c.split(';').contains(item.Sub_Category__c)
                  : true);
        return trueSoFar;
    }
    
}