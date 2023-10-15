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
  */
public with sharing class CaseLeadScoreHelper implements ILeadScoreCommand{

    private static Map<Id,Case> domesticUnderGradMap = new Map<Id,Case>();
    private static Map<Id,Case> domesticPostGradMap = new Map<Id,Case>();
    private static Map<Id,Case> domesticUndeterminedMap = new Map<Id,Case>();
    private static Map<Id,Case> internationalUnderGradMap = new Map<Id,Case>();
    private static Map<Id,Case> internationalPostGradMap = new Map<Id,Case>();
    private static Map<Id,Case> internationalUndeterminedMap = new Map<Id,Case>();
    private static Map<Id,Case> undeterminedUndeterminedMap = new Map<Id,Case>();    
    
    /**
     * Filter records to be processed
     */
    public static void processLeadScoreCalculation(List<Case> newItems, Map<Id, Case> oldItems){

        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        //check contact with multiple cases
        Map<Id,Case> caseMap = new Map<Id,Case>();
        for(Case caseRec : newItems){
            Boolean isForInsert = oldItems == null && caseRec.Category__c != null;
            Boolean isForUpdate = oldItems != null && (
                (caseRec.Lead__c!=null && oldItems.get(caseRec.Id).Lead__c != caseRec.Lead__c) || 
                (caseRec.ContactId!=null && oldItems.get(caseRec.Id).ContactId != caseRec.ContactId) ||
                (caseRec.Category__c!=null && oldItems.get(caseRec.Id).Category__c != caseRec.Category__c)
            );

            Boolean isForProcessing = isForInsert || isForUpdate;
            if(isForProcessing){
                caseMap.put(caseRec.Id, caseRec);
                if(caseRec.ContactId != null){
                    contactIdSet.add(caseRec.ContactId);
                }else{
                    leadIdSet.add(caseRec.Lead__c);
                }
            }
        }

        Set<Id> contactLeadIds = new Set<Id>();
        contactLeadIds.addAll(contactIdSet);
        contactLeadIds.addAll(leadIdSet);

        getCaseSiblingRecords(caseMap, contactLeadIds);
        
        //Sort record per citizenship status and study level
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, leadIdSet);
        for(Case caseRec : caseMap.values()){
            mapUnderGradStudyLevel(caseRec, marketingSegMap);
            mapPostGradStudyLevel(caseRec, marketingSegMap);
            mapUndeterminedStudyLevel(caseRec, marketingSegMap);
        }

        if(!caseMap.isEmpty()){
            LeadScoreQueueableCall executeQueueable = new LeadScoreQueueableCall(new CaseLeadScoreHelper(), setMarketingSegMap(), contactLeadIds);
            System.enqueueJob(executeQueueable);   
        }
    }   

    /**
     * Async process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(LeadScoreCalculatorService.ObjectMap objectMap, Set<Id> contactLeadIds){  
        LeadScoreCalculatorService.calculateLeadScore(objectMap, contactLeadIds, Case.getSObjectType());
    } 

    /**
     * Sets the object map to be used in queueable job
     */
    private static LeadScoreCalculatorService.ObjectMap setMarketingSegMap(){
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
     * Retrieve case sibling records
     */
    private static void getCaseSiblingRecords(Map<Id,Case> caseMap, Set<Id> contactLeadIds){
        if(!contactLeadIds.isEmpty()){
            caseMap = new Map<Id,Case>(CasesDAO.newInstance().getCasesByContactOrLeadIds(contactLeadIds, AccessLevel.SYSTEM_MODE));
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUnderGrad = marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadUnderGrad = marketingSegMap.containsKey(caseRec.Lead__c) && marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
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
        
        Boolean isContactPostGrad = marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadPostGrad = marketingSegMap.containsKey(caseRec.Lead__c) &&  marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
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
        
        Boolean isContactUndetermined = marketingSegMap.containsKey(caseRec.ContactId) && String.isBlank(marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c);
        Boolean isContactDomestic = isContactUndetermined && validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadUndetermined = marketingSegMap.containsKey(caseRec.Lead__c) && String.isBlank(marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c);
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

}