/**
 * @description Service Class for any involcing Case Priority Configuration Service
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426	            | Created File                  | 
 */
public inherited sharing class CasePriorityConfigurationService {

    public static Boolean matchCountryTier(
        Case item,
        Case_Priority_Configuration__c config,
        Map<String, String> countryTierMap
    ) {
        Boolean trueSoFar = true;
        if (
            config.Country_Tier__c != null &&
            (config.Country_Tier__c !=
            countryTierMap.get(
                item.Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c
            ) &&
            config.Country_Tier__c != countryTierMap.get(item.Contact.Citizenship_Country__c))
        ) {
            trueSoFar = false;
        }
        return trueSoFar;
    }

    public static Boolean matchConfigToCaseBase(Case item, Case_Priority_Configuration__c config) {
        Boolean trueSoFar = config.Case_Record_Type__c != null
            ? CasesDAO.CASE_RECTYPE_MAP.get(config.Case_Record_Type__c) == item.RecordTypeId
            : true;
        if (
            config.Lead_Score__c != null &&
            (config.Lead_Score__c != item.Lead__r.Lead_Score__c &&
            config.Lead_Score__c != item.Contact.Lead_Score__c)
        ) {
            trueSoFar = false;
        }
        if (
            config.Future_Student_Stage__c != null &&
            (config.Future_Student_Stage__c != item.Lead__r.Future_Student_Journey_Status__c &&
            config.Future_Student_Stage__c != item.Contact.Future_Student_Journey_Status__c)
        ) {
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