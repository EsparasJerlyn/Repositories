/**
  * @description helper class to compute Lead Score for Lead 
  * @see ..LeadTriggerHandler
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | October 06, 2023      | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for Lead                                       |
  *    | mark.j.mahilum                 | May 06, 2024          | DEPP-7987              | Updated logic to check for all async call      |
  */
public with sharing class LeadLeadScoreHelper {
    private static Map<Id,Lead> domesticUnderGradMap = new Map<Id,Lead>();
    private static Map<Id,Lead> domesticPostGradMap = new Map<Id,Lead>();
    private static Map<Id,Lead> domesticUndeterminedMap = new Map<Id,Lead>();
    private static Map<Id,Lead> internationalUnderGradMap = new Map<Id,Lead>();
    private static Map<Id,Lead> internationalPostGradMap = new Map<Id,Lead>();
    private static Map<Id,Lead> internationalUndeterminedMap = new Map<Id,Lead>();
    private static Map<Id,Lead> undeterminedUndeterminedMap = new Map<Id,Lead>();

    /**
     * Filter records to be processed
     */
    public static void processLeadScoreCalculation(List<Lead> newItems, Map<Id, Lead> oldItems) {
        Boolean isForInsert = oldItems == null;
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        for(Lead lead : newItems){
            Boolean isValid = !lead.IsConverted;
            Boolean isForUpdate = !isForInsert && (
                lead.Email_Opt_In_DateTime__c != oldItems.get(lead.Id).Email_Opt_In_DateTime__c ||
                (oldItems.get(lead.Id).Marketing_Segmentation__c != lead.Marketing_Segmentation__c && lead.Email_Opt_In_DateTime__c != null));
            if(isValid && ((isForInsert && lead.Email_Opt_In_DateTime__c != null)|| isForUpdate)){
              leadMap.put(lead.Id, lead);
            }
        }
        
        if(!leadMap.isEmpty()) {

            Boolean isAsync = System.isBatch() || System.isFuture() || System.isScheduled() || System.isQueueable();
            
            if(isAsync) {
                executeCalculation(leadMap);
            } else {
                QueueableCall executeQueueable = new QueueableCall(leadMap);
                System.enqueueJob(executeQueueable);   
            }
        }
    }      

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Lead lead, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isUnderGrad = marketingSegMap.containsKey(lead.Id) && marketingSegMap.get(lead.Id).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isDomesticLead = isUnderGrad && validateDomesticLead(lead, marketingSegMap);
        Boolean isInternationalLead = isUnderGrad && validateInternationalLead(lead, marketingSegMap);
        if(isDomesticLead){
            domesticUnderGradMap.put(lead.Id, lead);
        }
        else if(isInternationalLead){
            internationalUnderGradMap.put(lead.Id, lead);
        }
    }

    private static Boolean validateDomesticLead(Lead lead, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
                marketingSegMap.get(lead.Id).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || 
                marketingSegMap.get(lead.Id).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ;
    }

    private static Boolean validateInternationalLead(Lead lead, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(lead.Id).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    /**
     * Maps Postgrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(Lead lead, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isPostGrad = marketingSegMap.containsKey(lead.Id) && marketingSegMap.get(lead.Id).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isDomesticLead = isPostGrad && validateDomesticLead(lead, marketingSegMap);
        Boolean isInternationalLead = isPostGrad && validateInternationalLead(lead, marketingSegMap);
        if(isDomesticLead){
            domesticPostGradMap.put(lead.Id, lead);
        }
        if(isInternationalLead){
            internationalPostGradMap.put(lead.Id, lead);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(Lead lead, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isUndetermined = marketingSegMap.containsKey(lead.Id) && String.isBlank(marketingSegMap.get(lead.Id).My_Primary_Study_Level__c) || 
            (
                marketingSegMap.get(lead.Id).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
                marketingSegMap.get(lead.Id).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD
            );
        Boolean isDomesticLead = isUndetermined && validateDomesticLead(lead, marketingSegMap);
        Boolean isInternationalLead = isUndetermined && validateInternationalLead(lead, marketingSegMap);
        Boolean hasNoCitizenship = isUndetermined && marketingSegMap.get(lead.Id).My_Citizenship_Status__c == null;

        if(isDomesticLead){
            domesticUndeterminedMap.put(lead.Id, lead);
        }
        else if(isInternationalLead){
            internationalUndeterminedMap.put(lead.Id, lead);
        }
        else if(hasNoCitizenship){
            undeterminedUndeterminedMap.put(lead.Id, lead);
        }
    }   

     /**
     * Queueable class to execute calculation of lead score for lead.
     */
    private class QueueableCall implements Queueable {
        private Map<Id,Lead> leadMap;
        
        public QueueableCall(Map<Id,Lead> leadMap) {
            this.leadMap = leadMap;
        }

        public void execute(QueueableContext context) {
            executeCalculation(leadMap);
        }
    }

    /**
     * Process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(Map<Id,Lead> leadMap){
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(leadMap);
        if(!leadMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, leadMap.keySet(), Lead.getSObjectType());
        }
    }

    /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Map<Id,Lead> leadMap){

        //Sort records per study level and citizenship status
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(new Set<Id>(), leadMap.keySet());
        for(Lead lead : leadMap.values()){
            mapUnderGradStudyLevel(lead, marketingSegMap);
            mapPostGradStudyLevel(lead, marketingSegMap);
            mapUndeterminedStudyLevel(lead, marketingSegMap);
        }

        LeadScoreCalculatorService.ObjectMap objectMap = new LeadScoreCalculatorService.ObjectMap();
        objectMap.domesticUnderGradMap = domesticUnderGradMap;
        objectMap.domesticPostGradMap = domesticPostGradMap;
        objectMap.domesticUndeterminedMap = domesticUndeterminedMap;
        objectMap.internationalUnderGradMap = internationalUnderGradMap;
        objectMap.internationalPostGradMap = internationalPostGradMap;
        objectMap.internationalUndeterminedMap = internationalUndeterminedMap;
        objectMap.undeterminedUndeterminedMap = undeterminedUndeterminedMap;
        return objectMap;
    }
    
}