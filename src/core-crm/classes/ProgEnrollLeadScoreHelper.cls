/**
  * @description helper class to compute Lead Score for hed__Program_Enrollment__c
  * @see ..ProgramEnrollmentTriggerHandler
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for contact                                    |
  */
public with sharing class ProgEnrollLeadScoreHelper {

    private static Map<Id,hed__Program_Enrollment__c> domesticUnderGradMap = new Map<Id,hed__Program_Enrollment__c>();
    private static Map<Id,hed__Program_Enrollment__c> domesticPostGradMap = new Map<Id,hed__Program_Enrollment__c>();
    private static Map<Id,hed__Program_Enrollment__c> domesticUndeterminedMap = new Map<Id,hed__Program_Enrollment__c>();
    private static Map<Id,hed__Program_Enrollment__c> internationalUnderGradMap = new Map<Id,hed__Program_Enrollment__c>();
    private static Map<Id,hed__Program_Enrollment__c> internationalPostGradMap = new Map<Id,hed__Program_Enrollment__c>();
    private static Map<Id,hed__Program_Enrollment__c> internationalUndeterminedMap = new Map<Id,hed__Program_Enrollment__c>();
    private static Map<Id,hed__Program_Enrollment__c> undeterminedUndeterminedMap = new Map<Id,hed__Program_Enrollment__c>();  

    public static void processLeadScoreCalculation(List<hed__Program_Enrollment__c> newItems, Map<Id, hed__Program_Enrollment__c> oldItems){

        Set<Id> contactIdSet = new Set<Id>();

        /**
         * Filter records to be processed
         */
        for(hed__Program_Enrollment__c programEnrollment : newItems) {
            Boolean isForInsert = oldItems == null && programEnrollment.hed__Contact__c != null;
            Boolean isForUpdate = oldItems != null && programEnrollment.hed__Contact__c != null && (
                oldItems.get(programEnrollment.Id).hed__Contact__c != programEnrollment.hed__Contact__c ||
                oldItems.get(programEnrollment.Id).hed__Account__c != programEnrollment.hed__Account__c ||
                oldItems.get(programEnrollment.Id).Enrollment_Status__c != programEnrollment.Enrollment_Status__c
            );
            if(!programEnrollment.Lead_Score_Reset__c && (isForInsert || isForUpdate)) {
                contactIdSet.add(programEnrollment.hed__Contact__c);
            }
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
        
        /**
         * Determines wether to run async or sync
         */
        if(!contactMap.isEmpty()){           
            if(System.isQueueable()){
                executeCalculation(contactMap.keySet());
            }else{      
                QueueableCall executeQueueable = new QueueableCall(contactMap.keySet());
                System.enqueueJob(executeQueueable);   
            }
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap) {

        Boolean isUnderGrad = 
            marketingSegMap.containsKey(progEnrollment.hed__Contact__c) && marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isDomestic = isUnderGrad && validateDomesticContact(progEnrollment, marketingSegMap);
        Boolean isInternational = isUnderGrad && validateInternationalContact(progEnrollment, marketingSegMap);

        if(isDomestic){
            domesticUnderGradMap.put(progEnrollment.Id, progEnrollment);
        }
        else if(isInternational){
            internationalUnderGradMap.put(progEnrollment.Id, progEnrollment);
        }
    }

    /**
     * Maps Postgrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap) {

        Boolean isPostGrad = 
            marketingSegMap.containsKey(progEnrollment.hed__Contact__c) && marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isDomestic = isPostGrad && validateDomesticContact(progEnrollment, marketingSegMap);
        Boolean isInternational = isPostGrad && validateInternationalContact(progEnrollment, marketingSegMap);

        if(isDomestic){
            domesticPostGradMap.put(progEnrollment.Id, progEnrollment);
        }
        else if(isInternational){
            internationalPostGradMap.put(progEnrollment.Id, progEnrollment);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap) {

        Boolean isUndetermined = 
            marketingSegMap.containsKey(progEnrollment.hed__Contact__c) && marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            (marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == null ||
            (marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
            marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
        Boolean isDomestic = isUndetermined && validateDomesticContact(progEnrollment, marketingSegMap);
        Boolean isInternational = isUndetermined && validateInternationalContact(progEnrollment, marketingSegMap);
        Boolean isConCitizenshipUD = isUndetermined && validateUndeterminedContact(progEnrollment, marketingSegMap);

        if(isDomestic){
            domesticUndeterminedMap.put(progEnrollment.Id, progEnrollment);
        }
        else if(isInternational){
            internationalUndeterminedMap.put(progEnrollment.Id, progEnrollment);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMap.put(progEnrollment.Id, progEnrollment);
        }
    }   
    
    /**
     * Queueable class to execute calculation of lead score for prog enrollment. This classw ill be removed
     * once all lead score helpers are updated and are using LeadScoreQueueableCall.
     */
    private class QueueableCall implements Queueable {
        private Set<Id> contactIdSet;
        
        public QueueableCall(Set<Id> contactIdSet) {
            this.contactIdSet = contactIdSet;
        }

        public void execute(QueueableContext context) {
            executeCalculation(contactIdSet);
        }
    }

    /**
     * Process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(Set<Id> contactIdSet){
        Map<Id,hed__Program_Enrollment__c> programEnrollmentMap = setProgramEnrollmentMap(contactIdSet);   
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, programEnrollmentMap);
        if(!programEnrollmentMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactIdSet, hed__Program_Enrollment__c.getSObjectType());
        }
    } 

    /**
     * Retrieves all related records
     */
    public static Map<Id,hed__Program_Enrollment__c> setProgramEnrollmentMap(Set<Id> contactIdSet){
        Map<Id,hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id,hed__Program_Enrollment__c>();
        if(!contactIdSet.isEmpty()){              
            programEnrollmentMap.putAll(new Map<Id, hed__Program_Enrollment__c>(
                ProgramEnrollmentsDAO.newInstance().getAllProgramEnrollmentsByContactId(
                    contactIdSet,
                    AccessLevel.SYSTEM_MODE
                ))
            );  
        }
        
        return programEnrollmentMap;
    }

    /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Map<Id,hed__Program_Enrollment__c> programEnrollmentMap){

        //Sort records per study level and citizenship status
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, new Set<Id>());
        for(hed__Program_Enrollment__c progEnrollment : programEnrollmentMap.values()){
            mapUnderGradStudyLevel(progEnrollment, marketingSegMap);
            mapPostGradStudyLevel(progEnrollment, marketingSegMap);
            mapUndeterminedStudyLevel(progEnrollment, marketingSegMap);
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

    private static Boolean validateDomesticContact(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.hed__Citizenship_Status__c!=null && 
            marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
    }

    private static Boolean validateInternationalContact(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.hed__Citizenship_Status__c!=null && 
            marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    private static Boolean validateUndeterminedContact(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(progEnrollment.hed__Contact__c).Contact__r.hed__Citizenship_Status__c == null;
    }
    
}