/**
  * @description helper class to compute Lead Score for Case 
  * @see ..CaseTriggerHandler
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for case                                       |
  *    | alexander.cadalin              | Oct 16, 2023          | DEPP-6919              | SOQL limit fix                                 |
  *    | eccarius.munoz                 | October 18, 2023      | DEPP-6919              | Updated filtering of case records and          | 
  *    |                                |                       |                        | retrieval of related/sibling case records      |
  *    | eccarius.munoz                 | October 18, 2023      | DEPP-6919              | Included all logic that includes soql in queue | 
  *    | eccarius.munoz                 | October 22, 2023      | DEPP-6957              | Added handling to run calculation in sync      | 
  *    |                                |                       |                        | process if there's already an existing queue.  | 
  */
  public with sharing class CaseLeadScoreHelper{ 

    private static Map<Id,Case> domesticUnderGradMap = new Map<Id,Case>();
    private static Map<Id,Case> domesticPostGradMap = new Map<Id,Case>();
    private static Map<Id,Case> domesticUndeterminedMap = new Map<Id,Case>();
    private static Map<Id,Case> internationalUnderGradMap = new Map<Id,Case>();
    private static Map<Id,Case> internationalPostGradMap = new Map<Id,Case>();
    private static Map<Id,Case> internationalUndeterminedMap = new Map<Id,Case>();
    private static Map<Id,Case> undeterminedUndeterminedMap = new Map<Id,Case>();        

    /**
     * Filter records to be processed for calculation of lead score for case
     * @param List<Case> newItems - Case.Trigger.new
     * @param Map<Id, Case> oldItems - Case.Trigger.old
     */
    public static void processLeadScoreCalculation(List<Case> newItems, Map<Id, Case> oldItems) {

        /**
         * Filtering of case records
         */
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();
        
        for(Case caseRec : newItems){   
            Boolean isValidRecordType = caseRec.RecordTypeId == CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID;
            if(isValidRecordType && isForProcessing(caseRec, oldItems)) {    
                setContactIds(caseRec, oldItems, contactIdSet);    
                setLeadIds(caseRec, oldItems, leadIdSet);
            }
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
        Map<Id,Lead> leadMap = new Map<Id,Lead>(LeadsDAO.newInstance().getUnconvertedLeadsByIdSet(leadIdSet, AccessLevel.SYSTEM_MODE));
        /**
         * Determines wether to run async or sync
         */
        if(!contactMap.keySet().isEmpty() || !leadMap.keySet().isEmpty()){
            if(System.isQueueable()){
                executeCalculation(contactMap.keySet(), leadMap.keySet());
            }else{      
                QueueableCall executeQueueable = new QueueableCall(contactMap.keySet(), leadMap.keySet());
                System.enqueueJob(executeQueueable);   
            }
        }

    }    

    /**
     * Method used in filtering records to be processed
     * @param Case caseRec - Case Record to validate
     * @param Map<Id, Case> oldItems - Case.Trigger.old
     * @return Boolean - Validated result if for insert or for update
     */
    private static Boolean isForProcessing(Case caseRec, Map<Id, Case> oldItems) {
        Boolean isForInsert = oldItems == null && caseRec.Category__c != null && (caseRec.Lead__c != null || caseRec.ContactId != null);
        Boolean isForUpdate = oldItems != null && (
            (oldItems.get(caseRec.Id).Lead__c != caseRec.Lead__c) || 
            (oldItems.get(caseRec.Id).ContactId != caseRec.ContactId) ||
            (oldItems.get(caseRec.Id).Category__c != caseRec.Category__c)
        );

        return !caseRec.Lead_Score_Reset__c && (isForInsert || isForUpdate);
    }

    /**
     * Sets contact id set
     * @param Case caseRec
     * @param Map<Id, Case> oldItems
     * @param Set<Id> contactIdSet
     */
    private static void setContactIds(Case caseRec, Map<Id, Case> oldItems, Set<Id> contactIdSet){
        if(caseRec.ContactId != null){
            contactIdSet.add(caseRec.ContactId);
        }else if(caseRec.ContactId == null && oldItems != null && oldItems.get(caseRec.Id).ContactId != null){
            contactIdSet.add(oldItems.get(caseRec.Id).ContactId);
        }
    }

    /**
     * Sets lead id set
     * @param Case caseRec
     * @param Map<Id, Case> oldItems
     * @param Set<Id> leadIdSet
     */
    private static void setLeadIds(Case caseRec, Map<Id, Case> oldItems, Set<Id> leadIdSet){
        if(caseRec.Lead__c != null){
            leadIdSet.add(caseRec.Lead__c);
        }else if(caseRec.Lead__c == null && oldItems != null && oldItems.get(caseRec.Id).Lead__c != null){
            leadIdSet.add(oldItems.get(caseRec.Id).Lead__c);
        }
    }    

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUnderGrad = 
            marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadUnderGrad = 
            marketingSegMap.containsKey(caseRec.Lead__c) &&
            marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isLeadDomestic = isLeadUnderGrad && validateDomesticLead(caseRec, marketingSegMap);
        Boolean isLeadInternational = isLeadUnderGrad && validateInternationalLead(caseRec, marketingSegMap);

        if(isContactDomestic){
            domesticUnderGradMap.put(caseRec.Id, caseRec);                
        }
        else if(isContactInternational){
            internationalUnderGradMap.put(caseRec.Id, caseRec);
        }
        else if(isLeadDomestic){
            domesticUnderGradMap.put(caseRec.Id, caseRec);                
        }
        else if(isLeadInternational){
            internationalUnderGradMap.put(caseRec.Id, caseRec);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactPostGrad = 
            marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadPostGrad = 
            marketingSegMap.containsKey(caseRec.Lead__c) &&
            marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isLeadDomestic = isLeadPostGrad && validateDomesticLead(caseRec, marketingSegMap);
        Boolean isLeadInternational = isLeadPostGrad && validateInternationalLead(caseRec, marketingSegMap);

        if(isContactDomestic){
            domesticPostGradMap.put(caseRec.Id, caseRec);                
        }
        else if(isContactInternational){
            internationalPostGradMap.put(caseRec.Id, caseRec);
        }

        else if(isLeadDomestic){
            domesticPostGradMap.put(caseRec.Id, caseRec);                
        }
        else if(isLeadInternational){
            internationalPostGradMap.put(caseRec.Id, caseRec);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUndetermined = 
            marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            (String.isBlank(marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c) ||
            (marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
            marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
        Boolean isContactDomestic = isContactUndetermined && validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadUndetermined = 
            marketingSegMap.containsKey(caseRec.Lead__c) &&
            (String.isBlank(marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c) || 
            (marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
            marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
        Boolean isLeadDomestic = isLeadUndetermined && validateDomesticLead(caseRec, marketingSegMap);
        Boolean isLeadInternational = isLeadUndetermined && validateInternationalLead(caseRec, marketingSegMap);
        Boolean isConCitizenshipUD = isContactUndetermined && validateUndeterminedContact(caseRec, marketingSegMap);
        Boolean isLeadCitizenshipUD = isLeadUndetermined && validateUndeterminedLead(caseRec, marketingSegMap);

        if(isContactDomestic){
            domesticUndeterminedMap.put(caseRec.Id, caseRec);                
        }
        else if(isContactInternational){
            internationalUndeterminedMap.put(caseRec.Id, caseRec);
        }
        else if(isLeadDomestic){
            domesticUndeterminedMap.put(caseRec.Id, caseRec);                
        }
        else if(isLeadInternational){
            internationalUndeterminedMap.put(caseRec.Id, caseRec);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMap.put(caseRec.Id, caseRec);               
        }
        else if(isLeadCitizenshipUD){
            undeterminedUndeterminedMap.put(caseRec.Id, caseRec);                
        }
    }

    public static Boolean validateDomesticContact(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return marketingSegMap.get(caseRec.ContactId).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
    }

    public static Boolean validateInternationalContact(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return marketingSegMap.get(caseRec.ContactId).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    public static Boolean validateDomesticLead(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
                marketingSegMap.get(caseRec.Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || 
                marketingSegMap.get(caseRec.Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ;
    }

    public static Boolean validateInternationalLead(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return marketingSegMap.get(caseRec.Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    public static Boolean validateUndeterminedContact(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return String.isBlank(marketingSegMap.get(caseRec.ContactId).Contact__r.hed__Citizenship_Status__c);
    }

    public static Boolean validateUndeterminedLead(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return String.isBlank(marketingSegMap.get(caseRec.Lead__c).My_Citizenship_Status__c);
    }

    /**
     * Queueable class to execute calculation of lead score for case. 
     */
    private class QueueableCall implements Queueable {
        private Set<Id> contactIdSet;
        private Set<Id> leadIdSet;
        
        public QueueableCall(Set<Id> contactIdSet, Set<Id> leadIdSet) {
            this.contactIdSet = contactIdSet;
            this.leadIdSet = leadIdSet;
        }

        public void execute(QueueableContext context) {
            executeCalculation(contactIdSet, leadIdSet);
        }
    }

    /**
     * Process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(Set<Id> contactIdSet, Set<Id> leadIdSet){
        Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Map<Id,Case> caseMap = setCaseMap(contactLeadIds);
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, leadIdSet, caseMap);
        if(!caseMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Case.getSObjectType());
        }
    }
    
    /**
     * Retrieves all related cases
     */
    public static Map<Id,Case> setCaseMap(Set<Id> contactLeadIds){
        Map<Id,Case> caseMap = new Map<Id,Case>();
        if(!contactLeadIds.isEmpty()){              
            caseMap.putAll(new Map<Id, Case>(CasesDAO.newInstance().getCasesByContactOrLeadIds(contactLeadIds, AccessLevel.SYSTEM_MODE)));  
        }
        
        return caseMap;
    }

     /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,Case> caseMap){
        //Sort record per citizenship status and study level
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, leadIdSet);
        for(Case caseRec : caseMap.values()){
            mapUnderGradStudyLevel(caseRec, marketingSegMap);
            mapPostGradStudyLevel(caseRec, marketingSegMap);
            mapUndeterminedStudyLevel(caseRec, marketingSegMap);
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