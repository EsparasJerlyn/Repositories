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
  */
  public with sharing class MarketingSegmentationLeadScoreHelper{    

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
    public static void processLeadScoreCalculation(List<Marketing_Segmentation__c> newItems, Map<Id, Marketing_Segmentation__c> oldItems){

        Map<Id,Marketing_Segmentation__c> marketingSegmentationMap = new Map<Id,Marketing_Segmentation__c>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Marketing_Segmentation__c mktgSeg : newItems){
            if(
                checkIfForUpdate(oldItems, mktgSeg) || 
                checkIfForUpdatedToUndetermined(oldItems, mktgSeg) || 
                checkUndeterminedUndetermined(mktgSeg)
            ){
                if(mktgSeg.Contact__c != null){
                    contactIdSet.add(mktgSeg.Contact__c);
                    marketingSegmentationMap.put(mktgSeg.Contact__c, mktgSeg);
                }else if(mktgSeg.Lead__c != null){
                    marketingSegmentationMap.put(mktgSeg.Lead__c, mktgSeg);
                }
            }
        }

        callSyncOrAsyncCalculation(contactIdSet, marketingSegmentationMap);
    }    

    /**
     * Determines wether to run async or sync
     */
    private static void callSyncOrAsyncCalculation(Set<Id> contactIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap){
        if(!marketingSegmentationMap.isEmpty()){
            if(System.isQueueable()){
                executeCalculation(contactIdSet, marketingSegmentationMap);
            }else{
                QueueableCall executeQueueable = new QueueableCall(contactIdSet, marketingSegmentationMap);
                System.enqueueJob(executeQueueable);   
            }
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Marketing_Segmentation__c markSeg, Map<Id,Contact> contactMap) {
        Boolean isUnderGrad = markSeg.My_Primary_Study_Level__c != null && markSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isDomesticLead = isUnderGrad && markSeg.Lead__c != null && (markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ);
        Boolean isInternationalLead = isUnderGrad && markSeg.Lead__c != null && markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
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
    private static void mapPostGradStudyLevel(Marketing_Segmentation__c markSeg, Map<Id,Contact> contactMap) {
        Boolean isPostGrad = markSeg.My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isDomesticLead = isPostGrad && markSeg.Lead__c != null &&  (markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ);
        Boolean isInternationalLead = isPostGrad && markSeg.Lead__c != null && markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
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
    private static void mapUndeterminedStudyLevel(Marketing_Segmentation__c markSeg, Map<Id,Contact> contactMap) {
        Boolean isUndetermined = String.isBlank(markSeg.My_Primary_Study_Level__c);
        Boolean isDomesticLead = isUndetermined && markSeg.Lead__c != null && String.isNotBlank(markSeg.My_Citizenship_Status__c) && (markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU || markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ);
        Boolean isInternationalLead = isUndetermined && markSeg.Lead__c != null && String.isNotBlank(markSeg.My_Citizenship_Status__c) && markSeg.My_Citizenship_Status__c == MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean isDomesticContact = isUndetermined && contactMap.containsKey(markSeg.Contact__c) && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isUndetermined && contactMap.containsKey(markSeg.Contact__c) && contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean isConCitizenshipUD = validateUndeterminedUDContact(isUndetermined, contactMap, markSeg);
        Boolean isLeadCitizenshipUD = validateUndeterminedUDLead(isUndetermined, markSeg);

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
        private Map<Id,Marketing_Segmentation__c> marketingSegmentationMap;
        
        public QueueableCall(Set<Id> contactIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap) {
            this.contactIdSet = contactIdSet;
            this.marketingSegmentationMap = marketingSegmentationMap;
        }

        public void execute(QueueableContext context) {
            executeCalculation(contactIdSet, marketingSegmentationMap);
        }
    }

    /**
     * Process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(Set<Id> contactIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap){
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, marketingSegmentationMap);
        if(!marketingSegmentationMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, marketingSegmentationMap.keySet(), Marketing_Segmentation__c.getSObjectType());
        }
    }

    /**
     * Sets the object map to be used in queueable job
     */
    public static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Map<Id,Marketing_Segmentation__c> marketingSegmentationMap){
         //Sort records per study level and citizenship status
         Map<Id,Contact> contactMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, AccessLevel.SYSTEM_MODE));
         for(Marketing_Segmentation__c mktgSeg : marketingSegmentationMap.values()){
             mapUnderGradStudyLevel(mktgSeg, contactMap);
             mapPostGradStudyLevel(mktgSeg, contactMap);
             mapUndeterminedStudyLevel(mktgSeg, contactMap);
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

    /*** Methods for checking if for lead score calculation : Start ***/
    private static Boolean checkIfForUpdate(Map<Id,Marketing_Segmentation__c> oldMarkSegMap, Marketing_Segmentation__c markSeg){
        return 
            oldMarkSegMap != null && 
            markSeg.My_Primary_Study_Level__c != null &&
            (           
                (String.isNotBlank(markSeg.My_Citizenship_Status__c) && markSeg.My_Citizenship_Status__c != oldMarkSegMap.get(markSeg.Id).My_Citizenship_Status__c) ||
                (markSeg.My_Country_Of_Residency__c != oldMarkSegMap.get(markSeg.Id).My_Country_Of_Residency__c) ||
                (markSeg.My_Country_Of_Citizenship__c != oldMarkSegMap.get(markSeg.Id).My_Country_Of_Citizenship__c) ||
                (String.isNotBlank(markSeg.My_Funding_Source__c) && markSeg.My_Funding_Source__c != oldMarkSegMap.get(markSeg.Id).My_Funding_Source__c) ||
                (markSeg.My_Primary_BSA__c != oldMarkSegMap.get(markSeg.Id).My_Primary_BSA__c) ||
                (markSeg.My_Primary_NSA__c != oldMarkSegMap.get(markSeg.Id).My_Primary_NSA__c) ||
                (markSeg.My_Double_Degree__c != oldMarkSegMap.get(markSeg.Id).My_Double_Degree__c) ||
                (markSeg.My_Interested_English_Pathways__c != oldMarkSegMap.get(markSeg.Id).My_Interested_English_Pathways__c) ||
                (markSeg.My_Expected_Admission_Year__c != oldMarkSegMap.get(markSeg.Id).My_Expected_Admission_Year__c) ||
                (markSeg.My_Primary_Study_Level__c != oldMarkSegMap.get(markSeg.Id).My_Primary_Study_Level__c)
            );
    }

    private static Boolean checkIfForUpdatedToUndetermined(Map<Id,Marketing_Segmentation__c> oldMarkSegMap, Marketing_Segmentation__c markSeg){
        return 
            oldMarkSegMap != null &&             
            (                
                (String.isNotBlank(markSeg.My_Citizenship_Status__c) && markSeg.My_Citizenship_Status__c != oldMarkSegMap.get(markSeg.Id).My_Citizenship_Status__c) ||
                (markSeg.My_Country_Of_Residency__c != oldMarkSegMap.get(markSeg.Id).My_Country_Of_Residency__c) ||
                (markSeg.My_Country_Of_Citizenship__c != oldMarkSegMap.get(markSeg.Id).My_Country_Of_Citizenship__c) ||
                (String.isNotBlank(markSeg.My_Funding_Source__c) && markSeg.My_Funding_Source__c != oldMarkSegMap.get(markSeg.Id).My_Funding_Source__c) ||
                (markSeg.My_Primary_BSA__c != oldMarkSegMap.get(markSeg.Id).My_Primary_BSA__c) ||
                (markSeg.My_Primary_NSA__c != oldMarkSegMap.get(markSeg.Id).My_Primary_NSA__c) ||                
                (markSeg.My_Double_Degree__c != oldMarkSegMap.get(markSeg.Id).My_Double_Degree__c) ||
                (markSeg.My_Interested_English_Pathways__c != oldMarkSegMap.get(markSeg.Id).My_Interested_English_Pathways__c) ||
                (markSeg.My_Expected_Admission_Year__c != oldMarkSegMap.get(markSeg.Id).My_Expected_Admission_Year__c) ||
                (markSeg.My_Primary_Study_Level__c != oldMarkSegMap.get(markSeg.Id).My_Primary_Study_Level__c && markSeg.My_Primary_Study_Level__c == null)
            );
    }

    private static Boolean checkUndeterminedUndetermined(Marketing_Segmentation__c markSeg){
        return 
            String.isBlank(markSeg.My_Primary_Study_Level__c) && 
            String.isBlank(markSeg.My_Citizenship_Status__c);
    }

    private static Boolean validateUndeterminedUDContact(Boolean isUndetermined, Map<Id,Contact> contactMap, Marketing_Segmentation__c markSeg){
        return contactMap.containsKey(markSeg.Contact__c) && String.isBlank(contactMap.get(markSeg.Contact__c).hed__Citizenship_Status__c);
    }

    private static Boolean validateUndeterminedUDLead(Boolean isUndetermined, Marketing_Segmentation__c markSeg){
        return isUndetermined && String.isBlank(markSeg.My_Citizenship_Status__c);
    }

    /*** Methods for checking if for lead score calculation : End ***/

}
