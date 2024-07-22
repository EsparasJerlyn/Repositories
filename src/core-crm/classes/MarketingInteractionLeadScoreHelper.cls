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
  *    |                                |                       |                        | for marketing interactions                     |
  */
//public with sharing class MarketingInteractionLeadScoreHelper implements ILeadScoreCommand{
public with sharing class MarketingInteractionLeadScoreHelper {

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
        
        /**
         * Filtering of marketing interaction records
         */
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        for(Marketing_Interaction__c mktgInteraction : newItems){
            if(
                !mktgInteraction.Lead_Score_Reset__c && 
                (checkIfForInsert(mktgInteraction, oldItems) || 
                checkIfForUpdate(mktgInteraction, oldItems))
            ) {
                setContactIds(mktgInteraction, oldItems, contactIdSet);    
                setLeadIds(mktgInteraction, oldItems, leadIdSet);
            }
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
        Map<Id,Lead> leadMap = new Map<Id,Lead>(LeadsDAO.newInstance().getUnconvertedLeadsByIdSet(leadIdSet, AccessLevel.SYSTEM_MODE));

        /**
         * Determines wether to run async or sync
         */
        if(!contactMap.isEmpty() || !leadMap.isEmpty()){
            if(System.isQueueable() || System.isBatch() || System.isFuture() || System.isScheduled()){
                executeCalculation(contactMap.keySet(), leadMap.keySet());
            }else{      
                //Will update to use LeadScoreQueueableCall after updating all the Lead Score helper classes.          
                //LeadScoreQueueableCall executeQueueable = new LeadScoreQueueableCall(new MarketingInteractionLeadScoreHelper(), contactIdSet, leadIdSet);
                QueueableCall executeQueueable = new QueueableCall(contactMap.keySet(), leadMap.keySet());
                System.enqueueJob(executeQueueable);   
            }
        }
    }        

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isContactUnderGrad = 
            marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadUnderGrad = 
            marketingSegMap.containsKey(mktgInt.Lead__c) && 
            marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
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
        
        Boolean isContactPostGrad = 
            marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadPostGrad = 
            marketingSegMap.containsKey(mktgInt.Lead__c) && 
            marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
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
        
        Boolean isContactUndetermined = 
            marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).Contact__r.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            (marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == null ||
            (marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD &&
            marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
        Boolean isContactDomestic = isContactUndetermined && validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadUndetermined = 
            marketingSegMap.containsKey(mktgInt.Lead__c) && 
            (marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == null || 
            (marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD && 
            marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c != MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD));
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
                    (mktgInteraction.Interaction_DateTime__c != oldItems.get(mktgInteraction.Id).Interaction_DateTime__c) ||
                    (mktgInteraction.Lead_Source__c != oldItems.get(mktgInteraction.Id).Lead_Source__c) ||
                    (mktgInteraction.Match_My_Skill_Completion__c != oldItems.get(mktgInteraction.Id).Match_My_Skill_Completion__c) ||
                    (mktgInteraction.Event_Type__c != oldItems.get(mktgInteraction.Id).Event_Type__c) ||
                    (mktgInteraction.Event_Date__c != oldItems.get(mktgInteraction.Id).Event_Date__c) ||
                    (mktgInteraction.Has_Attended__c != oldItems.get(mktgInteraction.Id).Has_Attended__c) ||
                    (mktgInteraction.Contact__c != oldItems.get(mktgInteraction.Id).Contact__c) ||
                    (mktgInteraction.Lead__c != oldItems.get(mktgInteraction.Id).Lead__c)
                )
            );
    }

    /**
     * Sets contact id set
     * @param Marketing_Interaction__c mktIntact
     * @param Map<Id, Marketing_Interaction__c> oldItems
     * @param Set<Id> contactIdSet
     */
    private static void setContactIds(Marketing_Interaction__c mktIntact, Map<Id, Marketing_Interaction__c> oldItems, Set<Id> contactIdSet){
        if(mktIntact.Contact__c != null){
            contactIdSet.add(mktIntact.Contact__c);
        }else if(mktIntact.Contact__c == null && oldItems != null && oldItems.get(mktIntact.Id).Contact__c != null){
            contactIdSet.add(oldItems.get(mktIntact.Id).Contact__c);
        }
    }

    /**
     * Sets lead id set
     * @param Marketing_Interaction__c mktIntact
     * @param Map<Id, Marketing_Interaction__c> oldItems
     * @param Set<Id> leadIdSet
     */
    private static void setLeadIds(Marketing_Interaction__c mktIntact, Map<Id, Marketing_Interaction__c> oldItems, Set<Id> leadIdSet){
        if(mktIntact.Lead__c != null){
            leadIdSet.add(mktIntact.Lead__c);
        }else if(mktIntact.Lead__c == null && oldItems != null && oldItems.get(mktIntact.Id).Lead__c != null){
            leadIdSet.add(oldItems.get(mktIntact.Id).Lead__c);
        }
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

    /**
     * Queueable class to execute calculation of lead score for marketing interactions. This class will
     * be removed once all lead score helpers are updated and are using LeadScoreQueueableCall.
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
        Map<Id,Marketing_Interaction__c> mktIntMap = setMarketingInteractionMap(contactLeadIds);
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, leadIdSet, mktIntMap);
        if(!mktIntMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
        }
    }

    /**
     * Retrieves all related marketing interactions
     */
    public static Map<Id,Marketing_Interaction__c> setMarketingInteractionMap(Set<Id> contactLeadIds){
        Map<Id,Marketing_Interaction__c> mktIntMap = new Map<Id,Marketing_Interaction__c>();
        if(!contactLeadIds.isEmpty()){              
            mktIntMap.putAll(new Map<Id, Marketing_Interaction__c>(MarketingInteractionsDAO.newInstance().getMarketingInteractionsByContactOrLeadIds(contactLeadIds, AccessLevel.SYSTEM_MODE)));  
        }
        
        return mktIntMap;
    }

    /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Set<Id> leadIdSet, Map<Id,Marketing_Interaction__c> mktgInteractionsMap){
        //Sort records per study level and citizenship status
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactIdSet, leadIdSet);
        for(Marketing_Interaction__c mktgInt : mktgInteractionsMap.values()){
            mapUnderGradStudyLevel(mktgInt, marketingSegMap);
            mapPostGradStudyLevel(mktgInt, marketingSegMap);
            mapUndeterminedStudyLevel(mktgInt, marketingSegMap);
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