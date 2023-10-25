/**
 * @description Service Class for Marketing Consent Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigMktgConsentService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigMktgConsent leadScoreConfigMktgConsent){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_MKT_CONSENT;
        Boolean isForMktgConsent = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        if(isForMktgConsent){ 
            leadScoreConfigMktgConsent.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigMktgConsent.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_YES){
            leadScoreConfigMktgConsent.setYes(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_IS_BLANK){
            leadScoreConfigMktgConsent.setIsBlank(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScoreForContact(Map<Id,Contact> contactMap, LeadScoreConfigMktgConsent leadScoreConfigMktgConsent){
        Map<Id, Integer> mktConsentMap = new Map<Id, Integer>();

        Integer mktConsentScore = 0;
        for(Contact contact : contactMap.values()){

            if(mktConsentMap.containsKey(contact.Id)){
                mktConsentScore = mktConsentMap.get(contact.Id);
            }else{
                mktConsentScore = 0;
            }

            if(contact.Email_Opt_In_DateTime__c != null){
                mktConsentScore = mktConsentScore + leadScoreConfigMktgConsent.getYes();
            }else{
                mktConsentScore = mktConsentScore + leadScoreConfigMktgConsent.getIsBlank();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(mktConsentScore, leadScoreConfigMktgConsent.getMaxScore());
            mktConsentMap.put(contact.Id, score);
        }

        return mktConsentMap;
    }

    public static Map<Id, Integer> calculateLeadScoreForLead(Map<Id,Lead> leadMap, LeadScoreConfigMktgConsent leadScoreConfigMktgConsent){
        Map<Id, Integer> mktConsentMap = new Map<Id, Integer>();

        Integer mktConsentScore = 0;
        for(Lead lead : leadMap.values()){

            if(mktConsentMap.containsKey(lead.Id)){
                mktConsentScore = mktConsentMap.get(lead.Id);
            }else{
                mktConsentScore = 0;
            }

            if(lead.Email_Opt_In_DateTime__c != null){
                mktConsentScore = mktConsentScore + leadScoreConfigMktgConsent.getYes();
            }else{
                mktConsentScore = mktConsentScore + leadScoreConfigMktgConsent.getIsBlank();
            }
            
            Integer score = LeadScoreCalculatorService.validateScore(mktConsentScore, leadScoreConfigMktgConsent.getMaxScore());
            mktConsentMap.put(lead.Id, score);
        }

        return mktConsentMap;
    }
}