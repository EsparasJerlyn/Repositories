/**
  * @description Batch class to recalculate lead score when lead score config is updated
  *
  * @author Accenture
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 04, 2023     | DEPP-7155              | Created file to handle lead score calculation  |
  */

public with sharing class LeadScoreConfigRecalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Boolean isForContactAndLead = false;
    private Boolean isForMarketingInteraction = false;
    private Boolean isForMarketingSegmentation = false;                
    private Boolean isForProgEnrollment = false;
    private Boolean isForIndivEmail = false;
    private Boolean isForCase = false;   
    
    private Set<Id> contactIdSet = new Set<Id>();
    private Set<Id> leadIdSet = new Set<Id>();

    private Set<Id> leadScoreConfigIds;

    public void recalculateLeadScore(Set<Id> leadScoreConfigIds){
        this.leadScoreConfigIds = leadScoreConfigIds;
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves lead score details based on the citizenship 
    *               and study level of the triggered lead score config record.
    * @param bc - BatchableContext
    * @return query - filtered query of lead score details
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        Set<String> citizenshipStatusSet = new Set<String>();
        Set<String> primaryStudyLevelSet = new Set<String>();

        List<String> fields = new List<String>{'Name', 'Domestic_International__c', 'Study_Level__c', 'Parent_Category__r.Name'};
        List<Lead_Score_Configuration__c> leadScoreConfigList = LeadScoreConfigurationDAO.newInstance().getCategoryLeadScoreConfigsById(leadScoreConfigIds, fields, AccessLevel.SYSTEM_MODE);
        Map<String, Lead_Score_Configuration__c> leadScoreConfigMap = new Map<String, Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c leadScoreConfig : leadScoreConfigList){
            citizenshipStatusSet.add(leadScoreConfig.Domestic_International__c);
            primaryStudyLevelSet.add(leadScoreConfig.Study_Level__c);
            leadScoreConfigMap.put(getUniqueKey(leadScoreConfig), leadScoreConfig);
        }        
        
        isForCase = validateCaseRecords(leadScoreConfigMap);
        isForMarketingInteraction = validateMarketingInteractionRecords(leadScoreConfigMap);
        isForMarketingSegmentation = validateMarketingSegmentationRecords(leadScoreConfigMap);
        isForContactAndLead = validateContactAndLeadRecords(leadScoreConfigMap);
        isForProgEnrollment = validateProgramEnrollmentRecords(leadScoreConfigMap);
        isForIndivEmail = validateIndivEmailRecords(leadScoreConfigMap);

        return LeadScoreDetailsDAO.newInstance().queryLocatorLeadScoreDetailsByCitizenshipAndStudyLevel(citizenshipStatusSet, primaryStudyLevelSet);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Lead_Score_Detail__c
    */
    public void execute(Database.BatchableContext bc, List<Lead_Score_Detail__c> leadScoreDetails){
        try{ 
            
            for(Lead_Score_Detail__c leadScoreDtl : leadScoreDetails){
                if(leadScoreDtl.Contact__c != null){
                    contactIdSet.add(leadScoreDtl.Contact__c);
                }else if(leadScoreDtl.Lead__c != null){
                    leadIdSet.add(leadScoreDtl.Lead__c);
                }
            }

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreConfigRecalculationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    
    private Boolean validateContactAndLeadRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_MKT_CONSENT);
    }

    private Boolean validateCaseRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_ENQUIRIES);
    }

    private Boolean validateIndivEmailRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_EMAIL_INTERACTION);     
    }

    private Boolean validateProgramEnrollmentRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_PROGRAM_ENGAGEMENT); 
    }

    private Boolean validateMarketingInteractionRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return 
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_DOWNLOADED_PDF) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_MATCH_MY_SKILLS) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_EVENT_REG_ATTD) ; 
    }

    private Boolean validateMarketingSegmentationRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return 
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_FUNDING) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_COUNTRY_TIER) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_RESIDENCE) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_DOUBLE_DEG) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_ENG_PATH) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_PREF_INTAKE) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_COURSE_LEVEL) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_BSA) ||
            validateRecord(leadScoreConfigMap, LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_NSA) ; 
    }

    private static String getUniqueKey(Lead_Score_Configuration__c leadScoreConfig){
        return leadScoreConfig.Domestic_International__c + leadScoreConfig.Study_Level__c + leadScoreConfig.Parent_Category__r.Name + leadScoreConfig.Name;
    }

    private Boolean validateRecord(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap, String categoryName){
        return 
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.DOMESTIC + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD + LeadScoreConfigurationDAO.CONFIG_DOMESTIC_UNDERGRAD + categoryName) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.DOMESTIC + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD + LeadScoreConfigurationDAO.CONFIG_DOMESTIC_POSTGRAD + categoryName) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.INTERNATIONAL + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD + LeadScoreConfigurationDAO.CONFIG_INTERNATIONAL_POSTGRAD + categoryName) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.INTERNATIONAL + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD + LeadScoreConfigurationDAO.CONFIG_INTERNATIONAL_UNDERGRAD + categoryName) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.UNDETERMINED + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED + LeadScoreConfigurationDAO.CONFIG_UNDETERMINED_UNDETERMINED + categoryName) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.DOMESTIC + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED + LeadScoreConfigurationDAO.CONFIG_DOMESTIC_UNDETERMINED + categoryName) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.INTERNATIONAL + LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED + LeadScoreConfigurationDAO.CONFIG_INTERNATIONAL_UNDETERMINED + categoryName);
    }

    public void finish(Database.BatchableContext bc) {

        if(isForMarketingInteraction){
            LeadScoreMktgInteractionBatch batch = new LeadScoreMktgInteractionBatch();        
            batch.recalculateLeadScore(contactIdSet, leadIdSet);
        }

        if(isForMarketingSegmentation){
            LeadScoreMktgSegmentationBatch batch = new LeadScoreMktgSegmentationBatch();        
            batch.recalculateLeadScore(contactIdSet, leadIdSet);
        }

        if(isForContactAndLead){
            LeadScoreContactBatch contactBatch = new LeadScoreContactBatch();        
            contactBatch.recalculateLeadScore(contactIdSet);

            LeadScoreLeadBatch leadBatch = new LeadScoreLeadBatch();        
            leadBatch.recalculateLeadScore(leadIdSet);
        }

        if(isForCase){
            LeadScoreCaseBatch batch = new LeadScoreCaseBatch();        
            batch.recalculateLeadScore(contactIdSet, leadIdSet);
        }

        if(isForProgEnrollment){
            LeadScoreProgEnrollmentBatch batch = new LeadScoreProgEnrollmentBatch();        
            batch.recalculateLeadScore(contactIdSet);
        }

        if(isForIndivEmail){
            LeadScoreIndivEmailBatch batch = new LeadScoreIndivEmailBatch();        
            batch.recalculateLeadScore(contactIdSet, leadIdSet);
        }

    }
}