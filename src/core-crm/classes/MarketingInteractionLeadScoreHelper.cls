/**
  * @description helper class to compute Lead Score for Marketing_Interaction__c
  * @see ..MarketingInteractionTriggerHandler
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
public with sharing class MarketingInteractionLeadScoreHelper implements ILeadScoreCommand{

    private static Map<Id,Marketing_Interaction__c> domesticUnderGradMap = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> domesticPostGradMap = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> domesticUndeterminedMap = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> internationalUnderGradMap = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> internationalPostGradMap = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> internationalUndeterminedMap = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> undeterminedUndeterminedMap = new Map<Id,Marketing_Interaction__c>();

    /**
     * Filter records to be processed
     */
    public static void processLeadScoreCalculation(List<Marketing_Interaction__c> newItems, Map<Id, Marketing_Interaction__c> oldItems){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        Map<Id,Marketing_Interaction__c> mktgInteractionsMap = new Map<Id,Marketing_Interaction__c>();
        for(Marketing_Interaction__c mktgInteraction : newItems){
            if(checkIfForInsert(mktgInteraction, oldItems) || checkIfForUpdate(mktgInteraction, oldItems)){
                mktgInteractionsMap.put(mktgInteraction.Id, mktgInteraction);
                if(mktgInteraction.Contact__c != null){
                    contactIdSet.add(mktgInteraction.Contact__c);
                }else{
                    leadIdSet.add(mktgInteraction.Lead__c);
                }
            }
        }

        Set<Id> contactLeadIds = new Set<Id>();
        contactLeadIds.addAll(contactIdSet);
        contactLeadIds.addAll(leadIdSet);

        getMarketingInteractionSiblingRecords(mktgInteractionsMap, contactLeadIds);

        //Sort records per study level and citizenship status
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, leadIdSet);
        for(Marketing_Interaction__c mktgInt : mktgInteractionsMap.values()){
            mapUnderGradStudyLevel(mktgInt, marketingSegMap);
            mapPostGradStudyLevel(mktgInt, marketingSegMap);
            mapUndeterminedStudyLevel(mktgInt, marketingSegMap);
        }

        if(!mktgInteractionsMap.isEmpty()){
            LeadScoreQueueableCall executeQueueable = new LeadScoreQueueableCall(new MarketingInteractionLeadScoreHelper(), setMarketingSegMap(), contactLeadIds);
            System.enqueueJob(executeQueueable);        
        }

    }

    /**
     * Retrieve sibling records
     */
    private static void getMarketingInteractionSiblingRecords(Map<Id,Marketing_Interaction__c> mktgInteractionsMap, Set<Id> contactLeadIds){
        List<Marketing_Interaction__c> mktgInteractions = new List<Marketing_Interaction__c>();
        
        if(!contactLeadIds.isEmpty()){
            mktgInteractions = MarketingInteractionsDAO.newInstance().getMarketingInteractionsByContactOrLeadIds(contactLeadIds, AccessLevel.SYSTEM_MODE);
        }
        
        for(Marketing_Interaction__c mktgInt : mktgInteractions){
            if(!mktgInteractionsMap.containsKey(mktgInt.Id)){
                mktgInteractionsMap.put(mktgInt.Id, mktgInt);
            }
        }
    }

    /**
     * Async process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(LeadScoreCalculatorService.ObjectMap objectMap, Set<Id> contactLeadIds){
        LeadScoreCalculatorService.calculateLeadScore(objectMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
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
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUnderGrad = marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadUnderGrad = marketingSegMap.containsKey(mktgInt.Lead__c) && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isLeadDomestic = isLeadUnderGrad && validateDomesticLead(mktgInt, marketingSegMap);
        Boolean isLeadInternational = isLeadUnderGrad && validateInternationalLead(mktgInt, marketingSegMap);

        if(isContactDomestic){
            domesticUnderGradMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isContactInternational){
            internationalUnderGradMap.put(mktgInt.Id, mktgInt);
        }
        else if(isLeadDomestic){
            domesticUnderGradMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadInternational){
            internationalUnderGradMap.put(mktgInt.Id, mktgInt);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactPostGrad = marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadPostGrad = marketingSegMap.containsKey(mktgInt.Lead__c) && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isLeadDomestic = isLeadPostGrad && validateDomesticLead(mktgInt, marketingSegMap);
        Boolean isLeadInternational = isLeadPostGrad && validateInternationalLead(mktgInt, marketingSegMap);

        if(isContactDomestic){
            domesticPostGradMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isContactInternational){
            internationalPostGradMap.put(mktgInt.Id, mktgInt);
        }

        else if(isLeadDomestic){
            domesticPostGradMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadInternational){
            internationalPostGradMap.put(mktgInt.Id, mktgInt);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUndetermined = marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == null;
        Boolean isContactDomestic = isContactUndetermined && validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadUndetermined = marketingSegMap.containsKey(mktgInt.Lead__c) && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == null;
        Boolean isLeadDomestic = isLeadUndetermined && validateDomesticLead(mktgInt, marketingSegMap);
        Boolean isLeadInternational = isLeadUndetermined && validateInternationalLead(mktgInt, marketingSegMap);
        Boolean isConCitizenshipUD = isContactUndetermined && validateUndeterminedContact(mktgInt, marketingSegMap);
        Boolean isLeadCitizenshipUD = isLeadUndetermined && validateUndeterminedLead(mktgInt, marketingSegMap);

        if(isContactDomestic){
            domesticUndeterminedMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isContactInternational){
            internationalUndeterminedMap.put(mktgInt.Id, mktgInt);
        }
        else if(isLeadDomestic){
            domesticUndeterminedMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadInternational){
            internationalUndeterminedMap.put(mktgInt.Id, mktgInt);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMap.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadCitizenshipUD){
            undeterminedUndeterminedMap.put(mktgInt.Id, mktgInt);                
        }
    }

    private static Boolean checkIfForInsert(Marketing_Interaction__c mktgInteraction, Map<Id, Marketing_Interaction__c> oldItems){
        return 
            oldItems == null && 
            (
                mktgInteraction.Lead_Source_Category__c != null ||
                mktgInteraction.Interaction_DateTime__c != null ||
                mktgInteraction.Lead_Source__c != null ||
                mktgInteraction.Match_My_Skill_Completion__c != null ||
                mktgInteraction.Event_Type__c != null || 
                mktgInteraction.Event_Date__c != null
            );
    }

    private static Boolean checkIfForUpdate(Marketing_Interaction__c mktgInteraction, Map<Id, Marketing_Interaction__c> oldItems){
        return 
            oldItems != null && 
            (
                (   
                    (mktgInteraction.Lead_Source_Category__c != oldItems.get(mktgInteraction.Id).Lead_Source_Category__c) ||
                    (mktgInteraction.Interaction_DateTime__c != null && mktgInteraction.Interaction_DateTime__c != oldItems.get(mktgInteraction.Id).Interaction_DateTime__c) ||
                    (mktgInteraction.Lead_Source__c != oldItems.get(mktgInteraction.Id).Lead_Source__c) ||
                    (mktgInteraction.Match_My_Skill_Completion__c != oldItems.get(mktgInteraction.Id).Match_My_Skill_Completion__c) ||
                    (mktgInteraction.Event_Type__c != oldItems.get(mktgInteraction.Id).Event_Type__c) ||
                    (mktgInteraction.Event_Date__c != oldItems.get(mktgInteraction.Id).Event_Date__c) ||
                    (mktgInteraction.Has_Attended__c != oldItems.get(mktgInteraction.Id).Has_Attended__c)
                )
            );
    }

    public static Boolean validateDomesticContact(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(mktgInt.Contact__c).Contact__r.hed__Citizenship_Status__c!=null && 
            marketingSegMap.get(mktgInt.Contact__c).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
    }

    public static Boolean validateInternationalContact(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(mktgInt.Contact__c).Contact__r.hed__Citizenship_Status__c!=null && 
            marketingSegMap.get(mktgInt.Contact__c).Contact__r.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    public static Boolean validateDomesticLead(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(mktgInt.Lead__c).My_Citizenship_Status__c!=null && 
            (
                marketingSegMap.get(mktgInt.Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || 
                marketingSegMap.get(mktgInt.Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ
            );
    }

    public static Boolean validateInternationalLead(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(mktgInt.Lead__c).My_Citizenship_Status__c!=null &&
            marketingSegMap.get(mktgInt.Lead__c).My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
    }

    public static Boolean validateUndeterminedContact(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(mktgInt.Contact__c).Contact__r.hed__Citizenship_Status__c == null;
    }

    public static Boolean validateUndeterminedLead(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap){
        return 
            marketingSegMap.get(mktgInt.Lead__c).My_Citizenship_Status__c == null;
    }
    
}