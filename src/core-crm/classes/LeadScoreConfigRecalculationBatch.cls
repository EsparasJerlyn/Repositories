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

@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class LeadScoreConfigRecalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Boolean isForContactAndLead = false;
    private Boolean isForMarketingInteraction = false;
    private Boolean isForMarketingSegmentation = false;                
    private Boolean isForProgEnrollment = false;
    private Boolean isForIndivEmail = false;
    private Boolean isForCase = false;   

    private Set<Id> leadScoreConfigIds;

    public void recalculateLeadScore(Set<Id> leadScoreConfigIds){
        this.leadScoreConfigIds = leadScoreConfigIds;
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves lead score config that was updated from previous day
    * @param bc - BatchableContext
    * @return query - filtered query of lead score config
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        Set<String> citizenshipStatusSet = new Set<String>();
        Set<String> primaryStudyLevelSet = new Set<String>();

        List<String> fields = new List<String>{'Name', 'Domestic_International__c', 'Study_Level__c'};
        List<Lead_Score_Configuration__c> leadScoreConfigList = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigsById(leadScoreConfigIds, fields, AccessLevel.SYSTEM_MODE);
        Map<String, Lead_Score_Configuration__c> leadScoreConfigMap = new Map<String, Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c leadScoreConfig : leadScoreConfigList){
            citizenshipStatusSet.add(leadScoreConfig.Domestic_International__c);
            primaryStudyLevelSet.add(leadScoreConfig.Study_Level__c);
            leadScoreConfigMap.put(leadScoreConfig.Name, leadScoreConfig);
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
            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> leadIdSet = new Set<Id>();
            for(Lead_Score_Detail__c leadScoreDtl : leadScoreDetails){
                if(leadScoreDtl.Contact__c != null){
                    contactIdSet.add(leadScoreDtl.Contact__c);
                }else if(leadScoreDtl.Lead__c != null){
                    leadIdSet.add(leadScoreDtl.Lead__c);
                }
            }
            
            LeadScoreCalculatorService.processMarketingInterActions(contactIdSet, leadIdSet, isForMarketingInteraction);
            LeadScoreCalculatorService.processMarketingSegmentation(contactIdSet, leadIdSet, isForMarketingSegmentation);
            LeadScoreCalculatorService.processContact(contactIdSet, isForContactAndLead);
            LeadScoreCalculatorService.processLead(leadIdSet, isForContactAndLead);
            LeadScoreCalculatorService.processCase(contactIdSet, leadIdSet, isForCase);
            LeadScoreCalculatorService.processProgramEngagement(contactIdSet, isForProgEnrollment);
            LeadScoreCalculatorService.processIndivEmailResults(contactIdSet, leadIdSet, isForIndivEmail);

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreConfigRecalculationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    
    private Boolean validateContactAndLeadRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_MKT_CONSENT);        
    }

    private Boolean validateCaseRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return  leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_ENQUIRIES);
    }

    private Boolean validateIndivEmailRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_EMAIL_INTERACTION);        
    }

    private Boolean validateProgramEnrollmentRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PROGRAM_ENGAGEMENT);        
    }

    private Boolean validateMarketingInteractionRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return 
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_DOWNLOADED_PDF) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_MATCH_MY_SKILLS) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_EVENT_REG_ATTD);
    }

    private Boolean validateMarketingSegmentationRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return 
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_FUNDING) ||            
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_COUNTRY_TIER) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_RESIDENCE) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_DOUBLE_DEG) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_ENG_PATH) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PREF_INTAKE) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_COURSE_LEVEL) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_BSA) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_NSA);
    }

    public void finish(Database.BatchableContext bc) {}
}