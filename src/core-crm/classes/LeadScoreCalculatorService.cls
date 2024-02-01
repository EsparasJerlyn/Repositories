/**
 * @description Helper class for Lead Score Calculation 
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 23, 2023    | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public inherited sharing class LeadScoreCalculatorService {

    public static final String STUDY_LEVEL_CITIZENSHIP_DOM_UG = 'Domestic Undergrad';
    public static final String STUDY_LEVEL_CITIZENSHIP_DOM_PG = 'Domestic Postgrad';
    public static final String STUDY_LEVEL_CITIZENSHIP_DOM_UD = 'Domestic Undetermined';
    public static final String STUDY_LEVEL_CITIZENSHIP_INT_UG = 'International Undergrad';
    public static final String STUDY_LEVEL_CITIZENSHIP_INT_PG = 'International Postgrad';
    public static final String STUDY_LEVEL_CITIZENSHIP_INT_UD = 'International Undetermined';   
    public static final String STUDY_LEVEL_CITIZENSHIP_UD = 'Undetermined Undetermined';  

    /**
     * Calculation process that includes:
     * 1. Sets the parameters needed for calculation per study level and citizenship
     * 2. Update/Insert Lead Score Details
     */
    public static void calculateLeadScore(ObjectMap objectMap, Set<Id> contactLeadIds, SObjectType sObjectType) {

        try {
            List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

            LeadScoreConfigService.LeadScoreConfigStudyLevelParam leadScoreConfig = LeadScoreConfigService.getLeadScoreConfig();
            LeadScoreStudyLevelCommand leadScoreStudyLevelCommand;

            //Process Domestic Undergrad
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.domesticUnderGradMap, 
                    leadScoreConfig.leadScoreConfigDomUnderGradList, 
                    contactLeadIds                  
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_DOM_UG
            ));

            //Process Domestic Postgrad
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.domesticPostGradMap, 
                    leadScoreConfig.leadScoreConfigDomPostGradList, 
                    contactLeadIds                 
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_DOM_PG
            ));
            
            //Process Domestic Undetermined
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.domesticUndeterminedMap, 
                    leadScoreConfig.leadScoreConfigDomUndeterminedList, 
                    contactLeadIds                 
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_DOM_UD
            ));

            //Process International Undergrad
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.internationalUnderGradMap, 
                    leadScoreConfig.leadScoreConfigIntUnderGradList, 
                    contactLeadIds             
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_INT_UG
            ));

            //Process International Postgrad
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.internationalPostGradMap, 
                    leadScoreConfig.leadScoreConfigIntPostGradList, 
                    contactLeadIds                
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_INT_PG
            ));
            
            //Process International Undetermined
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.internationalUndeterminedMap, 
                    leadScoreConfig.leadScoreConfigIntUndeterminedList, 
                    contactLeadIds               
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_INT_UD
            ));

            //Process Undetermined Undetermined
            leadScoreDetailList.addAll(calculateLeadScorePerStudyLevelAndCitizenship(
                new LeadScoreCalculatorParams(
                    sObjectType,
                    objectMap.undeterminedUndeterminedMap, 
                    leadScoreConfig.leadScoreConfigUndUndeterminedList, 
                    contactLeadIds               
                ),
                leadScoreStudyLevelCommand,
                LeadScoreCalculatorService.STUDY_LEVEL_CITIZENSHIP_UD
            ));

            //upserts lead score details
            if(!leadScoreDetailList.isEmpty()){
                LeadScoreDetailsDAO.newInstance().updateRecords(leadScoreDetailList, false, AccessLevel.SYSTEM_MODE);
            }

        }catch(Exception e){
            Logger.error('Exception caught during lead score calculation for ' + sObjectType + '.').setExceptionDetails(e);
        }finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * Executes Lead Score calculation
     * Calls the command class to process records based on studylevel and citizenship status
     */
    private static List<Lead_Score_Detail__c> calculateLeadScorePerStudyLevelAndCitizenship(
        LeadScoreCalculatorParams leadScoreCalculatorParams,
        LeadScoreStudyLevelCommand leadScoreStudyLevelCommand,
        String studyLevelAndCitizenship
    ){
        List<Lead_Score_Detail__c> leadScoreDetails = new List<Lead_Score_Detail__c>();
        if(!leadScoreCalculatorParams.sObjectMap.isEmpty()){
            switch on studyLevelAndCitizenship {
                when 'Domestic Undergrad'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScoreUndergradDomCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
                when 'Domestic Postgrad'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScorePostgradDomCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
                when 'Domestic Undetermined'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScoreUndeterminedDomCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
                when 'International Undergrad'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScoreUndergradIntCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
                when 'International Postgrad'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScorePostgradIntCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
                when 'International Undetermined'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScoreUndeterminedIntCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
                when 'Undetermined Undetermined'{
                    leadScoreStudyLevelCommand = new LeadScoreStudyLevelCommand(new LeadScoreUndeterminedUndCmd());
                    leadScoreDetails.addAll(leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams));
                }
            }
        }
        return leadScoreDetails;
    }

    /**
     * Retrieves marketing segmentation records by contac/lead Id
     */
    public static Map<Id,Marketing_Segmentation__c> getMarketingSegmentation(Set<Id> contactIdSet, Set<Id> leadIdSet){
        List<Marketing_Segmentation__c> marketingSegList = new List<Marketing_Segmentation__c>();

        if(!contactIdSet.isEmpty() || !leadIdSet.isEmpty()){
            marketingSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(contactIdSet, leadIdSet, AccessLevel.SYSTEM_MODE);
        }

        Map<Id,Marketing_Segmentation__c> marketingSegMap = new Map<Id,Marketing_Segmentation__c>();
        for(Marketing_Segmentation__c mktSeg : marketingSegList){
            if(mktSeg.Contact__c!=null){
                marketingSegMap.put(mktSeg.Contact__c, mktSeg);
            }else if(mktSeg.Lead__c!=null){
                marketingSegMap.put(mktSeg.Lead__c, mktSeg);
            }
        }
        return marketingSegMap;
    }

    /**
     * Retrieves existing lead score details
     */
    public static Map<Id, Lead_Score_Detail__c> getExistingLeadScoreDetails(Set<Id> contactLeadIdSet){
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap = new Map<Id, Lead_Score_Detail__c>();
        List<Lead_Score_Detail__c> leadScoreDetailsList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(contactLeadIdSet, AccessLevel.SYSTEM_MODE);
        for(Lead_Score_Detail__c detail: leadScoreDetailsList){
            if(detail.Contact__c != null){
                existingLeadScoreDetailMap.put(detail.Contact__c, detail);
            }
            if(detail.Lead__c != null){
                existingLeadScoreDetailMap.put(detail.Lead__c, detail);
            }
        }
        return existingLeadScoreDetailMap;
    }

    /**
     * Get lead score by category
     */
    public static Integer getLeadScoreByCategory(Id contactLeadId, Map<Id, Integer> categoryMap){
        return categoryMap.get(contactLeadId) != null ? categoryMap.get(contactLeadId) : 0;
    }

    /**
     * Validates score if greater than max score.
     */
    public static Integer validateScore(Integer score, Integer maxScore){
        if(score > maxScore){
            return maxScore;
        }
        return score;
    }

    /**
     * Sets the contact and lead Ids
     */
    public static Set<Id> mergeContactAndLeadIdsIntoOneSet(Set<Id> contactIdSet, Set<Id> leadIdSet){
        Set<Id> contactLeadIds = new Set<Id>();
        contactLeadIds.addAll(contactIdSet);
        contactLeadIds.addAll(leadIdSet);
        return contactLeadIds;
    }

    /**
     * Process recalculation for Case
     */
    public static void processCase(Set<Id> contactIdSet, Set<Id> leadIdSet, Boolean isForCase){    
        if(isForCase){
            Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
            Map<Id,Case> caseMap = CaseLeadScoreHelper.setCaseMap(contactLeadIds);
            LeadScoreCalculatorService.ObjectMap objMap = CaseLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, caseMap);
            if(!caseMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Case.getSObjectType());
            }
        }
    }

    /**
     * Process recalculation for Marketing Interaction
     */
    public static void processMarketingInterActions(Set<Id> contactIdSet, Set<Id> leadIdSet, Boolean isForMktgInteraction){ 
        if(isForMktgInteraction){
            Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
            Map<Id,Marketing_Interaction__c> mktIntMap = MarketingInteractionLeadScoreHelper.setMarketingInteractionMap(contactLeadIds);
            LeadScoreCalculatorService.ObjectMap objMap = MarketingInteractionLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, mktIntMap);
            if(!mktIntMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
            }   
        }
    }

    /**
     * Process recalculation for Individual Email Result
     */
    public static void processIndivEmailResults(Set<Id> contactIdSet, Set<Id> leadIdSet, Boolean isForIndivEmailEmail){ 
        if(isForIndivEmailEmail){
            Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
            Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap = IndividualEmailLeadScoreHelper.getIndividualEmailResultRecords(contactLeadIds);
            LeadScoreCalculatorService.ObjectMap objMap = IndividualEmailLeadScoreHelper.setObjectMap(contactIdSet, leadIdSet, indivEmailMap);
            if(!indivEmailMap.isEmpty()){
                LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, et4ae5__IndividualEmailResult__c.getSObjectType());
            }   
        }
    }

    public static void addErrorLogs(Id recordId){
        String logMessage = 'Lead Score Detail does not exist for this record: ' + recordId;
        Logger.error(logMessage).setRecord(recordId);
    }

    public static void saveLogs() {        
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }  
    
    public class LeadScoreCalculatorParams{
        public SObjectType sObjectType;
        public Map<Id,SObject> sObjectMap;
        public List<Lead_Score_Configuration__c> leadScoreConfigList;
        public Map<Id,Contact> contactMap;
        public Map<Id,Lead> leadMap;
        public Set<Id> contactLeadIdSet;

        public LeadScoreCalculatorParams(
            SObjectType sObjectType,
            Map<Id,SObject> sObjectMap,
            List<Lead_Score_Configuration__c> leadScoreConfigList,
            Set<Id> contactLeadIdSet
        ){
            this.sObjectType = sObjectType;
            this.sObjectMap = sObjectMap;
            this.leadScoreConfigList = leadScoreConfigList;
            this.contactLeadIdSet = contactLeadIdSet;
        }
    }

    public class ObjectMap{
        public Map<Id,SObject> domesticUnderGradMap;
        public Map<Id,SObject> domesticPostGradMap;
        public Map<Id,SObject> domesticUndeterminedMap;
        public Map<Id,SObject> internationalUnderGradMap;
        public Map<Id,SObject> internationalPostGradMap;
        public Map<Id,SObject> internationalUndeterminedMap;
        public Map<Id,SObject> undeterminedUndeterminedMap;
    }

}

