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
public with sharing class LeadScoreConfigRecalculationBatch implements Database.Batchable<sObject> {

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
        return LeadScoreConfigurationDAO.newInstance().queryLocatorLeadScoreConfigByIds(leadScoreConfigIds);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreConfigList - List of Lead_Score_Configuration__c
    */
    public void execute(Database.BatchableContext bc, List<Lead_Score_Configuration__c> leadScoreConfigList){
        try{ 
            Set<String> citizenshipStatusSet = new Set<String>();
            Set<String> primaryStudyLevelSet = new Set<String>();

            Boolean isForContactAndLead = false;
            Boolean isForMarketingInteraction = false;
            Boolean isForMarketingSegmentation = false;                
            Boolean isForProgEnrollment = false;
            Boolean isForIndivEmail = false;
            Boolean isForCase = false;          
            
            Map<String, Lead_Score_Configuration__c> leadScoreConfigMap = new Map<String, Lead_Score_Configuration__c>();
            for(Lead_Score_Configuration__c config : leadScoreConfigList){
                citizenshipStatusSet.add(config.Domestic_International__c);
                primaryStudyLevelSet.add(config.Study_Level__c);
                leadScoreConfigMap.put(config.Name, config);
            }  

            isForCase = validateCaseRecords(leadScoreConfigMap);
            isForMarketingInteraction = validateMarketingInteractionRecords(leadScoreConfigMap);
            isForMarketingSegmentation = validateMarketingSegmentationRecords(leadScoreConfigMap);
            isForContactAndLead = validateContactAndLeadRecords(leadScoreConfigMap);
            isForProgEnrollment = validateProgramEnrollmentRecords(leadScoreConfigMap);
            isForIndivEmail = validateIndivEmailRecords(leadScoreConfigMap);

            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> leadIdSet = new Set<Id>();
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByCitizenshipAndStudyLevel(citizenshipStatusSet, primaryStudyLevelSet, AccessLevel.SYSTEM_MODE);
            for(Lead_Score_Detail__c leadScoreDtl : leadScoreDetails){
                if(leadScoreDtl.Contact__c != null){
                    contactIdSet.add(leadScoreDtl.Contact__c);
                }else if(leadScoreDtl.Lead__c != null){
                    leadIdSet.add(leadScoreDtl.Lead__c);
                }
            }
            
            LeadScoreCalculatorService.processMarketingInterActions(contactIdSet, leadIdSet, isForMarketingInteraction);
            LeadScoreCalculatorService.processMarketingSegmentation(contactIdSet, isForMarketingSegmentation);
            LeadScoreCalculatorService.processContact(contactIdSet, isForContactAndLead);
            LeadScoreCalculatorService.processLead(leadIdSet, isForContactAndLead);
            LeadScoreCalculatorService.processCase(contactIdSet, leadIdSet, isForCase);
            LeadScoreCalculatorService.processProgramEngagement(contactIdSet, isForProgEnrollment);
            LeadScoreCalculatorService.processIndivEmailResults(contactIdSet, leadIdSet, isForIndivEmail);

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreConfigBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    
    private static Boolean validateContactAndLeadRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_MKT_CONSENT);        
    }

    private static Boolean validateCaseRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return  leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_ENQUIRIES);
    }

    private static Boolean validateIndivEmailRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_EMAIL_INTERACTION);        
    }

    private static Boolean validateProgramEnrollmentRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PROGRAM_ENGAGEMENT);        
    }

    private static Boolean validateMarketingInteractionRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return 
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_EVENT_REG_ATTD) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_DOWNLOADED_PDF) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_MATCH_MY_SKILLS);
        
    }

    private static Boolean validateMarketingSegmentationRecords(Map<String, Lead_Score_Configuration__c> leadScoreConfigMap){
        return 
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_FUNDING) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_BSA) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PRIMARY_NSA) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_COUNTRY_TIER) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_RESIDENCE) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_DOUBLE_DEG) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_INT_ENG_PATH) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_PREF_INTAKE) ||
            leadScoreConfigMap.containsKey(LeadScoreConfigurationDAO.CONFIG_CATEGORY_COURSE_LEVEL);
        
    }

    public void finish(Database.BatchableContext bc) {} //NOPMD
}