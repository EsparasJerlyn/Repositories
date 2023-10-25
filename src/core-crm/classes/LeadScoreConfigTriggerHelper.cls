/**
 * @description Helper class for LeadScoreConfigTriggerHandler
 * @see LeadScoreConfigTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 24, 2023      | DEPP-5866              | Created file                 |   
 */
public with sharing class LeadScoreConfigTriggerHelper {
    
    public static void processLeadScoreCalculation(List<Lead_Score_Configuration__c> newItems, Map<Id, Lead_Score_Configuration__c> oldItems){

        Set<Id> parentCategoryIds = new Set<Id>();
        Map<Id, Lead_Score_Configuration__c> configMap = new Map<Id,Lead_Score_Configuration__c>();
        Set<String> citizenshipStatusSet = new Set<String>();
        Set<String> primaryStudyLevelSet = new Set<String>();

        for(Lead_Score_Configuration__c leadScoreConfig : newItems){
            Boolean isCategoryUpdated = validateIfForCategory(leadScoreConfig, oldItems);
            Boolean isSubCategUpdated = validateIfForSubCategory(leadScoreConfig, oldItems);

            if(isCategoryUpdated){
                configMap.put(leadScoreConfig.Id, leadScoreConfig);
                citizenshipStatusSet.add(leadScoreConfig.Domestic_International__c);
                primaryStudyLevelSet.add(leadScoreConfig.Study_Level__c);
            }

            if(isSubCategUpdated){
                parentCategoryIds.add(leadScoreConfig.Parent_Category__c);
            }
        }        

        List<String> fields = new List<String>{'Name', 'Domestic_International__c', 'Study_Level__c'};
        List<Lead_Score_Configuration__c> parentConfigs = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigsById(parentCategoryIds, fields, AccessLevel.SYSTEM_MODE);
        for(Lead_Score_Configuration__c parentConfig : parentConfigs){
            citizenshipStatusSet.add(parentConfig.Domestic_International__c);
            primaryStudyLevelSet.add(parentConfig.Study_Level__c);
            
            if(!configMap.containsKey(parentConfig.Id)){
                configMap.put(parentConfig.Id, parentConfig);
            }
        }

        processRecalculation(configMap, citizenshipStatusSet, primaryStudyLevelSet);        
        
    }

    private static void processRecalculation(Map<Id, Lead_Score_Configuration__c> configMap, Set<String> citizenshipStatusSet, Set<String> primaryStudyLevelSet){
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

        for(Lead_Score_Configuration__c config : configMap.values()){
            Boolean isForMktgInteraction = config.Name == 'Event Registration and Attendance' || config.Name == 'Downloaded PDF' || config.Name == 'Match My Skills';
            Boolean isForCase = config.Name == 'Enquiries';
            Boolean isForMktgSegmentation = 
                config.Name == 'Funding' ||
                config.Name == 'Primary BSA' || 
                config.Name == 'Primary NSA' ||
                config.Name == 'Country Tier' ||
                config.Name == 'Residency' ||
                config.Name == 'Interested in Double Degrees' ||
                config.Name == 'Interested in English Pathway Programs' ||
                config.Name == 'Preferred Intake' ||
                config.Name == 'Course Level';
            Boolean isForContactAndLead = config.Name == 'Marketing consent';
            Boolean isForProgEnrollment = config.Name == 'Program Engagement';
            
            processMarketingInterActions(contactIdSet, leadIdSet, isForMktgInteraction);
            processMarketingSegmentation(contactIdSet, isForMktgSegmentation);
            processContact(contactIdSet, isForContactAndLead);
            processLead(leadIdSet, isForContactAndLead);
            processCase(contactIdSet, leadIdSet, isForCase);
            processProgramEngagement(contactIdSet, isForProgEnrollment);

        }
    }

    public static void processMarketingSegmentation(Set<Id> contactIdSet, Boolean isForMktgSegmentation){
        if(isForMktgSegmentation){
            Map<Id,Marketing_Segmentation__c> marketingSegmentationMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, new Set<Id>());
            LeadScoreCalculatorService.ObjectMap objMap = MarketingSegmentationLeadScoreHelper.setObjectMap(contactIdSet, marketingSegmentationMap);
            if(!marketingSegmentationMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, marketingSegmentationMap.keySet(), Marketing_Segmentation__c.getSObjectType());
            }
        }
        
    }

    private static void processContact(Set<Id> contactIdSet, Boolean isForContactAndLead){
        if(isForContactAndLead){
            Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
            LeadScoreCalculatorService.ObjectMap objMap = ContactLeadScoreHelper.setObjectMap(contactMap);
            if(!contactMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactMap.keySet(), Contact.getSObjectType());
            }   
        }
    }

    private static void processLead(Set<Id> leadIdSet, Boolean isForContactAndLead){
        if(isForContactAndLead){
            Map<Id,Lead> leadMap = new Map<Id,Lead>(LeadsDAO.newInstance().getLeadsByIdSetAndType(leadIdSet, LeadsDAO.LEARNER_LEAD_TYPE, AccessLevel.SYSTEM_MODE));
            LeadScoreCalculatorService.ObjectMap objMap = LeadLeadScoreHelper.setObjectMap(leadMap);
            if(!leadMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, leadMap.keySet(), Lead.getSObjectType());
            }    
        }
    }

    private static void processProgramEngagement(Set<Id> contactIdSet, Boolean isForProgEnrollment){    
        if(isForProgEnrollment){
            Map<Id,hed__Program_Enrollment__c> progEngMap = ProgEnrollLeadScoreHelper.setProgramEnrollmentMap(contactIdSet);
            LeadScoreCalculatorService.ObjectMap objMap = ProgEnrollLeadScoreHelper.setObjectMap(contactIdSet, progEngMap);
            if(!progEngMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactIdSet, hed__Program_Enrollment__c.getSObjectType());
            } 
        }
    }

    private static void processCase(Set<Id> contactIdSet, Set<Id> leadIdSet, Boolean isForCase){    
        if(isForCase){
            Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
            Map<Id,Case> caseMap = CaseLeadScoreHelper.setCaseMap(contactLeadIds);
            LeadScoreCalculatorService.ObjectMap objMap = CaseLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, caseMap);
            if(!caseMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Case.getSObjectType());
            }
        }
    }

    private static void processMarketingInterActions(Set<Id> contactIdSet, Set<Id> leadIdSet, Boolean isForMktgInteraction){ 
        if(isForMktgInteraction){
            Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
            Map<Id,Marketing_Interaction__c> mktIntMap = MarketingInteractionLeadScoreHelper.setMarketingInteractionMap(contactLeadIds);
            LeadScoreCalculatorService.ObjectMap objMap = MarketingInteractionLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, mktIntMap);
            if(!mktIntMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
            }   
        }
    }

    private static Boolean validateIfForSubCategory(Lead_Score_Configuration__c leadScoreConfig, Map<Id, Lead_Score_Configuration__c> oldItems){
        Boolean isSubCategUpdated = 
            leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && 
            leadScoreConfig.Score_Allocation__c != oldItems.get(leadScoreConfig.Id).Score_Allocation__c;
        return isSubCategUpdated;
    }

    private static Boolean validateIfForCategory(Lead_Score_Configuration__c leadScoreConfig, Map<Id, Lead_Score_Configuration__c> oldItems){
        Boolean isCategoryUpdated = 
                leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY && 
                (
                    leadScoreConfig.Max_Score__c != oldItems.get(leadScoreConfig.Id).Max_Score__c ||
                    leadScoreConfig.Time_Limit_Months__c != oldItems.get(leadScoreConfig.Id).Time_Limit_Months__c
                );
        return isCategoryUpdated;
    }

}