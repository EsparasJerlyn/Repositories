/**
  * @description helper class to compute Lead Score for MarketingSegmentation 
  * @see ..MarketingSegmentationTriggerHelper
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | September 25, 2023    | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for marketing segmentation                     |
  *    | roy.nino.s.regala              | Jan 11, 2024          | DEPP-7142              | Updated checker on what segmentation to process|
  */
  public with sharing class MarketingSegmentationLeadScoreHelper {    

    private static Map<Id,Marketing_Segmentation__c> domesticUnderGradMap = new Map<Id,Marketing_Segmentation__c>();
    private static Map<Id,Marketing_Segmentation__c> domesticPostGradMap = new Map<Id,Marketing_Segmentation__c>();
    private static Map<Id,Marketing_Segmentation__c> domesticUndeterminedMap = new Map<Id,Marketing_Segmentation__c>();
    private static Map<Id,Marketing_Segmentation__c> internationalUnderGradMap = new Map<Id,Marketing_Segmentation__c>();
    private static Map<Id,Marketing_Segmentation__c> internationalPostGradMap = new Map<Id,Marketing_Segmentation__c>();
    private static Map<Id,Marketing_Segmentation__c> internationalUndeterminedMap = new Map<Id,Marketing_Segmentation__c>();
    private static Map<Id,Marketing_Segmentation__c> undeterminedUndeterminedMap = new Map<Id,Marketing_Segmentation__c>();

    /**
     * Filter records to be processed
     */
    public static void processLeadScoreCalculation(List<Marketing_Segmentation__c> newItems, Map<Id, Marketing_Segmentation__c> oldItems) {

        Map<Id,Marketing_Segmentation__c> marketingSegmentationMap = new Map<Id,Marketing_Segmentation__c>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();
        for(Marketing_Segmentation__c mktgSeg : newItems){

            boolean isInserted =  oldItems == null && ObjectFieldService.isOneOfTheFieldsNotBlankAndNotBooleanFalse(MarketingSegmentationsDAO.LEAD_SCORE_CALCULATION_FIELDS,mktgSeg);
            boolean isUpdated = oldItems != null && ObjectFieldService.isOneOftheFieldsUpdated(MarketingSegmentationsDAO.LEAD_SCORE_CALCULATION_FIELDS,mktgSeg,oldItems.get(mktgSeg.Id));
            boolean isForProcessing = isInserted || isUpdated;
            boolean isForContact = isForProcessing && mktgSeg.Contact__c != null;
            boolean isForLead = isForProcessing && mktgSeg.Lead__c != null;

            if(isForContact){
                contactIdSet.add(mktgSeg.Contact__c);
                marketingSegmentationMap.put(mktgSeg.Contact__c, mktgSeg);
            }else if(isForLead){
                leadIdSet.add(mktgSeg.Lead__c);
                marketingSegmentationMap.put(mktgSeg.Lead__c, mktgSeg);
            }
        }

        callSyncOrAsyncCalculation(contactIdSet, leadIdSet, marketingSegmentationMap);
    }    

    /**
     * Determines wether to run async or sync
     */
    private static void callSyncOrAsyncCalculation(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap){
        if(!marketingSegmentationMap.isEmpty() && (System.isQueueable() || System.isFuture() || System.isBatch())){
            executeCalculation(contactIdSet, leadIdSet, marketingSegmentationMap);
        }else if(!marketingSegmentationMap.isEmpty()){
            QueueableCall executeQueueable = new QueueableCall(contactIdSet, leadIdSet, marketingSegmentationMap);
            System.enqueueJob(executeQueueable);  
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Marketing_Segmentation__c markSeg, Map<Id,Contact> contactMap, Map<Id,Lead> leadMap) {
        Boolean isUnderGrad = markSeg.My_Primary_Study_Level__c != null && markSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isDomesticLead = isUnderGrad && markSeg.Lead__c != null &&  
            (markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ);
        Boolean isInternationalLead = isUnderGrad && markSeg.Lead__c != null && 
            markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean isDomesticContact = isUnderGrad && markSeg.Contact__c != null && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isUnderGrad && markSeg.Contact__c != null && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;

        if(isDomesticContact){
            domesticUnderGradMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isDomesticLead){
            domesticUnderGradMap.put(markSeg.Lead__c, markSeg);
        }
        else if(isInternationalContact){
            internationalUnderGradMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isInternationalLead){
            internationalUnderGradMap.put(markSeg.Lead__c, markSeg);
        }
    }

    /**
     * Maps Postgrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(Marketing_Segmentation__c markSeg, Map<Id,Contact> contactMap, Map<Id,Lead> leadMap) {
        Boolean isPostGrad = markSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isDomesticLead = isPostGrad && markSeg.Lead__c != null && 
            (markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ);
        Boolean isInternationalLead = isPostGrad && markSeg.Lead__c != null && 
            markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean isDomesticContact = isPostGrad && markSeg.Contact__c != null && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isPostGrad && markSeg.Contact__c != null && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;

        if(isDomesticContact){
            domesticPostGradMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isDomesticLead){
            domesticPostGradMap.put(markSeg.Lead__c, markSeg);
        }
        else if(isInternationalContact){
            internationalPostGradMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isInternationalLead){
            internationalPostGradMap.put(markSeg.Lead__c, markSeg);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(Marketing_Segmentation__c markSeg, Map<Id,Contact> contactMap, Map<Id,Lead> leadMap) {
        Boolean isUndetermined = 
            String.isBlank(markSeg.My_Primary_Study_Level__c) || 
            (
                markSeg.My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
                markSeg.My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD
            );

        Boolean isDomesticLead = isUndetermined && markSeg.Lead__c != null && 
            String.isNotBlank(markSeg.My_Citizenship_Status__c) && (markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ);
        Boolean isInternationalLead = isUndetermined && markSeg.Lead__c != null && 
            String.isNotBlank(markSeg.My_Citizenship_Status__c) && markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean isDomesticContact = isUndetermined && contactMap.containsKey(markSeg.Contact__c) && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isUndetermined && contactMap.containsKey(markSeg.Contact__c) && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean isConCitizenshipUD = validateUndeterminedUDContact(isUndetermined, contactMap, markSeg);
        Boolean isLeadCitizenshipUD = validateUndeterminedUDLead(isUndetermined, leadMap, markSeg);

        if(isDomesticContact){
            domesticUndeterminedMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isDomesticLead){
            domesticUndeterminedMap.put(markSeg.Lead__c, markSeg);
        }
        else if(isInternationalContact){
            internationalUndeterminedMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isInternationalLead){
            internationalUndeterminedMap.put(markSeg.Lead__c, markSeg);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMap.put(markSeg.Contact__c, markSeg);
        }
        else if(isLeadCitizenshipUD){
            undeterminedUndeterminedMap.put(markSeg.Lead__c, markSeg);
        }
    }   

    /**
     * Queueable class to execute calculation of lead score for marketing segmentation records.
     */
    private class QueueableCall implements Queueable {
        private Set<Id> contactIdSet;
        private Set<Id> leadIdSet;
        private Map<Id,Marketing_Segmentation__c> marketingSegmentationMap;
        
        public QueueableCall(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap) {
            this.contactIdSet = contactIdSet;
            this.leadIdSet = leadIdSet;
            this.marketingSegmentationMap = marketingSegmentationMap;
        }

        public void execute(QueueableContext context) {
            executeCalculation(contactIdSet, leadIdSet, marketingSegmentationMap);
        }
    }

    /**
     * Process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap){
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, leadIdSet, marketingSegmentationMap);
        if(!marketingSegmentationMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, marketingSegmentationMap.keySet(), Marketing_Segmentation__c.getSObjectType());
        }
    }

    /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap){
         //Sort records per study level and citizenship status
         Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
         Map<Id,Lead> leadMap = new Map<Id,Lead>(LeadsDAO.newInstance().getUnconvertedLeadsByIdSet(leadIdSet, AccessLevel.SYSTEM_MODE));

         for(Id key:marketingSegmentationMap.keySet()){
            //filter out marketing segmentations related 
            //to a non Person Contact and
            //to a converted lead
            if(!contactMap.containsKey(key) && !leadMap.containsKey(key)){
                marketingSegmentationMap.remove(key);
                continue;
            }

            mapUnderGradStudyLevel(marketingSegmentationMap.get(key), contactMap, leadMap);
            mapPostGradStudyLevel(marketingSegmentationMap.get(key), contactMap, leadMap);
            mapUndeterminedStudyLevel(marketingSegmentationMap.get(key), contactMap, leadMap);
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

    private static Boolean validateUndeterminedUDContact(Boolean isUndetermined, Map<Id,Contact> contactMap, Marketing_Segmentation__c markSeg){
        return isUndetermined && markSeg.Contact__c!= null && contactMap.containsKey(markSeg.Contact__c) && String.isBlank(contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c);
    }

    private static Boolean validateUndeterminedUDLead(Boolean isUndetermined, Map<Id,Lead> leadMap, Marketing_Segmentation__c markSeg){
        return isUndetermined && markSeg.Lead__c!= null && leadMap.containsKey(markSeg.Lead__c) && String.isBlank(markSeg.My_Citizenship_Status__c);
    }

    /*** Methods for checking if for lead score calculation : End ***/

}

