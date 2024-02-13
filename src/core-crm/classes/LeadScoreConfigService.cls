/**
 * @description Service class for Lead Score Config
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 25, 2023    | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigService {//NOPMD this is a service class. high number of public methods and overall complexity is expected.

    public static LeadScoreConfigStudyLevelParam getLeadScoreConfig(){

        LeadScoreConfigStudyLevelParam leadScoreConfigParam = new LeadScoreConfigStudyLevelParam();
        List<Lead_Score_Configuration__c> leadScoreConfigDomUnderGradList = new List<Lead_Score_Configuration__c>();
        List<Lead_Score_Configuration__c> leadScoreConfigDomPostGradList = new List<Lead_Score_Configuration__c>();
        List<Lead_Score_Configuration__c> leadScoreConfigDomUndeterminedList = new List<Lead_Score_Configuration__c>();
        List<Lead_Score_Configuration__c> leadScoreConfigIntUnderGradList = new List<Lead_Score_Configuration__c>();
        List<Lead_Score_Configuration__c> leadScoreConfigIntPostGradList = new List<Lead_Score_Configuration__c>();
        List<Lead_Score_Configuration__c> leadScoreConfigIntUndeterminedList = new List<Lead_Score_Configuration__c>();
        List<Lead_Score_Configuration__c> leadScoreConfigUndUndeterminedList = new List<Lead_Score_Configuration__c>();

        List<Lead_Score_Configuration__c> leadScoreConfigList = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByRecordTypeIds(
            AccessLevel.SYSTEM_MODE, 
            LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
        );
        for(Lead_Score_Configuration__c leadScoreConfig : leadScoreConfigList){
            Boolean isValidRecType = leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY || leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY;
            Boolean isDomestic = isValidRecType && leadScoreConfig.Domestic_International__c == LeadScoreConfigurationDAO.DOMESTIC;
            Boolean isInternational = isValidRecType && leadScoreConfig.Domestic_International__c == LeadScoreConfigurationDAO.INTERNATIONAL;
            Boolean isUnderGrad = leadScoreConfig.Study_Level__c == LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
            Boolean isPostGrad = leadScoreConfig.Study_Level__c == LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
            Boolean isUndetermined = leadScoreConfig.Study_Level__c == LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED;
            Boolean hasNoCitizenship = isValidRecType && leadScoreConfig.Domestic_International__c == LeadScoreConfigurationDAO.UNDETERMINED;
            if(isDomestic){
                if(isUnderGrad){
                    leadScoreConfigDomUnderGradList.add(leadScoreConfig);
                }
                else if(isPostGrad){
                    leadScoreConfigDomPostGradList.add(leadScoreConfig);
                }
                else if(isUndetermined){
                    leadScoreConfigDomUndeterminedList.add(leadScoreConfig);
                }
            }
            else if(isInternational){
                if(isUnderGrad){
                    leadScoreConfigIntUnderGradList.add(leadScoreConfig);
                }
                else if(isPostGrad){
                    leadScoreConfigIntPostGradList.add(leadScoreConfig);
                }
                else if(isUndetermined){
                    leadScoreConfigIntUndeterminedList.add(leadScoreConfig);
                }
            }else if(hasNoCitizenship && isUndetermined){
                leadScoreConfigUndUndeterminedList.add(leadScoreConfig);
            }
            
        }

        leadScoreConfigParam.leadScoreConfigDomUnderGradList = leadScoreConfigDomUnderGradList;
        leadScoreConfigParam.leadScoreConfigDomPostGradList = leadScoreConfigDomPostGradList;
        leadScoreConfigParam.leadScoreConfigDomUndeterminedList = leadScoreConfigDomUndeterminedList;
        leadScoreConfigParam.leadScoreConfigIntUnderGradList =leadScoreConfigIntUnderGradList;
        leadScoreConfigParam.leadScoreConfigIntPostGradList = leadScoreConfigIntPostGradList;
        leadScoreConfigParam.leadScoreConfigIntUndeterminedList = leadScoreConfigIntUndeterminedList;
        leadScoreConfigParam.leadScoreConfigUndUndeterminedList = leadScoreConfigUndUndeterminedList;

        return leadScoreConfigParam;
    }

    //wrapper class for lead score config per study level and citizenship status
    public class LeadScoreConfigStudyLevelParam{
        public List<Lead_Score_Configuration__c> leadScoreConfigDomUnderGradList;
        public List<Lead_Score_Configuration__c> leadScoreConfigDomPostGradList;
        public List<Lead_Score_Configuration__c> leadScoreConfigDomUndeterminedList;
        public List<Lead_Score_Configuration__c> leadScoreConfigIntUnderGradList;
        public List<Lead_Score_Configuration__c> leadScoreConfigIntPostGradList;
        public List<Lead_Score_Configuration__c> leadScoreConfigIntUndeterminedList;
        public List<Lead_Score_Configuration__c> leadScoreConfigUndUndeterminedList;
    }

    //Wrapper class for specific lead score config category
    public class LeadScoreConfigReference{
        public LeadScoreConfigEventRegistration leadScoreEventRegistration = new LeadScoreConfigEventRegistration();
        public LeadScoreConfigDownloadPDF leadScoreDownloadPDF = new LeadScoreConfigDownloadPDF();
        public LeadScoreConfigFunding leadScoreFunding = new LeadScoreConfigFunding();
        public LeadScoreConfigPrimaryBSA leadScorePrimaryBSA = new LeadScoreConfigPrimaryBSA();
        public LeadScoreConfigPrimaryNSA leadScorePrimaryNSA = new LeadScoreConfigPrimaryNSA();
        public LeadScoreConfigPreferredIntake leadScorePrefIntake = new LeadScoreConfigPreferredIntake();
        public LeadScoreConfigCourseLevel leadScoreCourseLevel = new LeadScoreConfigCourseLevel();
        public LeadScoreConfigEnquiries leadScoreEnquiries = new LeadScoreConfigEnquiries();
        public LeadScoreConfigMatchMySkills leadScoreMatchMySkills  = new LeadScoreConfigMatchMySkills();
        public LeadScoreConfigResidence leadScoreResidence = new LeadScoreConfigResidence();
        public LeadScoreConfigCountryTier leadScoreCountryTier = new LeadScoreConfigCountryTier();
        public LeadScoreConfigIntDoubleDeg leadScoreIntDoubleDeg = new LeadScoreConfigIntDoubleDeg();
        public LeadScoreConfigIntEngPathway leadScoreIntEngPath = new LeadScoreConfigIntEngPathway();
        public LeadScoreConfigMktgConsent leadScoreMktConsent = new LeadScoreConfigMktgConsent();
        public LeadScoreConfigProgEngagment leadScoreProgEng = new LeadScoreConfigProgEngagment();
        public LeadScoreConfigEmailInteract leadScoreEmailInteraction = new LeadScoreConfigEmailInteract();
    }
    
}