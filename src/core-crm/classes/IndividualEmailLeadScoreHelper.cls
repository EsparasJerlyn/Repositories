/**
  * @description helper class to compute Lead Score for Individual Email 
  * @see ..IndividualEmailTriggerHandler
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for Individual Email                           |
  */
  public with sharing class IndividualEmailLeadScoreHelper {

    private static Map<Id,et4ae5__IndividualEmailResult__c> domesticUnderGradMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
    private static Map<Id,et4ae5__IndividualEmailResult__c> domesticPostGradMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
    private static Map<Id,et4ae5__IndividualEmailResult__c> domesticUndeterminedMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
    private static Map<Id,et4ae5__IndividualEmailResult__c> internationalUnderGradMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
    private static Map<Id,et4ae5__IndividualEmailResult__c> internationalPostGradMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
    private static Map<Id,et4ae5__IndividualEmailResult__c> internationalUndeterminedMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
    private static Map<Id,et4ae5__IndividualEmailResult__c> undeterminedUndeterminedMap = new Map<Id,et4ae5__IndividualEmailResult__c>();    
    
    public static void processLeadScoreCalculation(List<et4ae5__IndividualEmailResult__c> newItems, Map<Id, et4ae5__IndividualEmailResult__c> oldItems){

        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        for(et4ae5__IndividualEmailResult__c indivEmail : newItems) {            
            if(
                !indivEmail.Lead_Score_Reset__c && 
                (validateIfForInsert(indivEmail, oldItems) || 
                validateIfForUpdate(indivEmail, oldItems))
            ){
                if(indivEmail.et4ae5__Contact__c != null){
                    contactIdSet.add(indivEmail.et4ae5__Contact__c);
                }
                else if(indivEmail.et4ae5__Lead__c != null){
                    leadIdSet.add(indivEmail.et4ae5__Lead__c);
                }
            }
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
        Map<Id,Lead> leadMap = new Map<Id,Lead>(LeadsDAO.newInstance().getUnconvertedLeadsByIdSet(leadIdSet, AccessLevel.SYSTEM_MODE));

        /**
         * Determines wether to run async or sync
         */
        if(!contactMap.isEmpty() || !leadMap.isEmpty()){
            if(System.isQueueable()){
                executeCalculation(contactMap.keySet(), leadMap.keySet());
            }else{      
                QueueableCall executeQueueable = new QueueableCall(contactMap.keySet(), leadMap.keySet());
                System.enqueueJob(executeQueueable);   
            }
        }       
        
    }     

    /**
     * Queueable class to execute calculation of lead score for indiv email result. 
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
    private static void executeCalculation(Set<Id> contactIdSet, Set<Id> leadIdSet){
        Set<Id> contactLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(contactIdSet, leadIdSet);
        Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap = getIndividualEmailResultRecords(contactLeadIds);

        
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, leadIdSet, indivEmailMap);
        if(!indivEmailMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, et4ae5__IndividualEmailResult__c.getSObjectType());
        }
    }

    /**
     * Retrieve all related records
     */
    public static Map<Id,et4ae5__IndividualEmailResult__c> getIndividualEmailResultRecords(Set<Id> contactLeadIds){
        Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap = new Map<Id,et4ae5__IndividualEmailResult__c>();
        if(!contactLeadIds.isEmpty()){
            indivEmailMap.putAll(
                new Map<Id, et4ae5__IndividualEmailResult__c>(
                    IndividualEmailResultsDAO.newInstance().getIndivEmailResultsByContactOrLeadIds(
                        contactLeadIds,
                        AccessLevel.SYSTEM_MODE
                    )
                )
            );
        }
        return indivEmailMap;
    }

     /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap){
        //Sort record per citizenship status and study level
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, leadIdSet);
        for(et4ae5__IndividualEmailResult__c indivEmail : indivEmailMap.values()){
            mapUnderGradStudyLevel(indivEmail, marketingSegMap);
            mapPostGradStudyLevel(indivEmail, marketingSegMap);
            mapUndeterminedStudyLevel(indivEmail, marketingSegMap);
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

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUnderGrad = 
            marketingSegMap.containsKey(indivEmail.et4ae5__Contact__c) && marketingSegMap.get(indivEmail.et4ae5__Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(indivEmail.et4ae5__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && validateDomesticContact(indivEmail, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && validateInternationalContact(indivEmail, marketingSegMap);
        Boolean isLeadUnderGrad = 
            marketingSegMap.containsKey(indivEmail.et4ae5__Lead__c) &&
            marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isLeadDomestic = isLeadUnderGrad && validateDomesticLead(indivEmail, marketingSegMap);
        Boolean isLeadInternational = isLeadUnderGrad && validateInternationalLead(indivEmail, marketingSegMap);

        if(isContactDomestic){
            domesticUnderGradMap.put(indivEmail.Id, indivEmail);                
        }
        else if(isContactInternational){
            internationalUnderGradMap.put(indivEmail.Id, indivEmail);
        }
        else if(isLeadDomestic){
            domesticUnderGradMap.put(indivEmail.Id, indivEmail);                
        }
        else if(isLeadInternational){
            internationalUnderGradMap.put(indivEmail.Id, indivEmail);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactPostGrad = 
            marketingSegMap.containsKey(indivEmail.et4ae5__Contact__c) && marketingSegMap.get(indivEmail.et4ae5__Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(indivEmail.et4ae5__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && validateDomesticContact(indivEmail, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && validateInternationalContact(indivEmail, marketingSegMap);
        Boolean isLeadPostGrad = 
            marketingSegMap.containsKey(indivEmail.et4ae5__Lead__c) &&
            marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isLeadDomestic = isLeadPostGrad && validateDomesticLead(indivEmail, marketingSegMap);
        Boolean isLeadInternational = isLeadPostGrad && validateInternationalLead(indivEmail, marketingSegMap);

        if(isContactDomestic){
            domesticPostGradMap.put(indivEmail.Id, indivEmail);                
        }
        else if(isContactInternational){
            internationalPostGradMap.put(indivEmail.Id, indivEmail);
        }

        else if(isLeadDomestic){
            domesticPostGradMap.put(indivEmail.Id, indivEmail);                
        }
        else if(isLeadInternational){
            internationalPostGradMap.put(indivEmail.Id, indivEmail);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUndetermined =
            marketingSegMap.containsKey(indivEmail.et4ae5__Contact__c) && marketingSegMap.get(indivEmail.et4ae5__Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            (String.isBlank(marketingSegMap.get(indivEmail.et4ae5__Contact__c).My_Primary_Study_Level__c) || 
            (marketingSegMap.get(indivEmail.et4ae5__Contact__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
            marketingSegMap.get(indivEmail.et4ae5__Contact__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
        Boolean isContactDomestic = isContactUndetermined && validateDomesticContact(indivEmail, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && validateInternationalContact(indivEmail, marketingSegMap);
        Boolean isLeadUndetermined = 
            marketingSegMap.containsKey(indivEmail.et4ae5__Lead__c) && 
            (String.isBlank(marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Primary_Study_Level__c) || 
            (marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
            marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
        Boolean isLeadDomestic = isLeadUndetermined && validateDomesticLead(indivEmail, marketingSegMap);
        Boolean isLeadInternational = isLeadUndetermined && validateInternationalLead(indivEmail, marketingSegMap);
        Boolean isConCitizenshipUD = isContactUndetermined && validateUndeterminedContact(indivEmail, marketingSegMap);
        Boolean isLeadCitizenshipUD = isLeadUndetermined && validateUndeterminedLead(indivEmail, marketingSegMap);

        if(isContactDomestic){
            domesticUndeterminedMap.put(indivEmail.Id, indivEmail);                
        }
        else if(isContactInternational){
            internationalUndeterminedMap.put(indivEmail.Id, indivEmail);
        }
        else if(isLeadDomestic){
            domesticUndeterminedMap.put(indivEmail.Id, indivEmail);                
        }
        else if(isLeadInternational){
            internationalUndeterminedMap.put(indivEmail.Id, indivEmail);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMap.put(indivEmail.Id, indivEmail);               
        }
        else if(isLeadCitizenshipUD){
            undeterminedUndeterminedMap.put(indivEmail.Id, indivEmail);                
        }
    }

    public static Boolean validateDomesticContact(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return marketingSegMap.get(indivEmail.et4ae5__Contact__c).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
    }

    public static Boolean validateInternationalContact(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return marketingSegMap.get(indivEmail.et4ae5__Contact__c).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    public static Boolean validateDomesticLead(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
                marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || 
                marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ;
    }

    public static Boolean validateInternationalLead(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    public static Boolean validateUndeterminedContact(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return String.isBlank(marketingSegMap.get(indivEmail.et4ae5__Contact__c).Contact__r.hed__Citizenship_Status__c);
    }

    public static Boolean validateUndeterminedLead(et4ae5__IndividualEmailResult__c indivEmail, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return String.isBlank(marketingSegMap.get(indivEmail.et4ae5__Lead__c).My_Citizenship_Status__c);
    }

    private static Boolean validateIfForInsert(et4ae5__IndividualEmailResult__c indivEmail, Map<Id, et4ae5__IndividualEmailResult__c> oldItems){
        return 
            oldItems == null && 
            indivEmail.et4ae5__Opened__c && 
            indivEmail.et4ae5__Clicked__c && 
            indivEmail.et4ae5__DateOpened__c != null;
    }

    private static Boolean validateIfForUpdate(et4ae5__IndividualEmailResult__c indivEmail, Map<Id, et4ae5__IndividualEmailResult__c> oldItems){
        return 
            oldItems != null && (            
            (indivEmail.et4ae5__DateOpened__c!=null && oldItems.get(indivEmail.Id).et4ae5__DateOpened__c != indivEmail.et4ae5__DateOpened__c) ||
            oldItems.get(indivEmail.Id).et4ae5__Clicked__c != indivEmail.et4ae5__Clicked__c ||
            oldItems.get(indivEmail.Id).et4ae5__Opened__c != indivEmail.et4ae5__Opened__c ||
            oldItems.get(indivEmail.Id).et4ae5__Contact__c != indivEmail.et4ae5__Contact__c ||
            oldItems.get(indivEmail.Id).et4ae5__Lead__c != indivEmail.et4ae5__Lead__c
        );
    }
}
