/**
  * @description helper class to compute Lead Score for Contact
  * @see ..CaseTriggerHandler
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
public inherited sharing class ContactLeadScoreHelper implements ILeadScoreCommand{

    private static Map<Id,Contact> domesticUnderGradMap = new Map<Id,Contact>();
    private static Map<Id,Contact> domesticPostGradMap = new Map<Id,Contact>();
    private static Map<Id,Contact> domesticUndeterminedMap = new Map<Id,Contact>();
    private static Map<Id,Contact> internationalUnderGradMap = new Map<Id,Contact>();
    private static Map<Id,Contact> internationalPostGradMap = new Map<Id,Contact>();
    private static Map<Id,Contact> internationalUndeterminedMap = new Map<Id,Contact>();
    private static Map<Id,Contact> undeterminedUndeterminedMap = new Map<Id,Contact>();

    /**
     * Filter records to be processed
     */
    public static void processLeadScoreCalculation(List<Contact> newItems, Map<Id, Contact> oldItems){

        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Boolean isForInsert = oldItems == null;
        for(Contact con : newItems){
            Boolean isRecTypeValid = con.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID;
            Boolean isForUpdate = oldItems != null &&
                (oldItems.get(con.Id).Email_Opt_In_DateTime__c != con.Email_Opt_In_DateTime__c ||
                oldItems.get(con.Id).hed__Citizenship_Status__c != con.hed__Citizenship_Status__c);
            if(isRecTypeValid && ((isForInsert && con.Email_Opt_In_DateTime__c != null) || isForUpdate)){
                contactMap.put(con.Id, con);
            }
        }
        //Sort records per study level and citizenship status
        Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactMap.keySet(), new Set<Id>());
        for(Contact con : contactMap.values()){
            mapUnderGradStudyLevel(con, marketingSegMap);
            mapPostGradStudyLevel(con, marketingSegMap);
            mapUndeterminedStudyLevel(con, marketingSegMap);
        }

        if(!contactMap.isEmpty()){
            if(System.isQueueable()){
                LeadScoreCalculatorService.calculateLeadScore(setMarketingSegMap(), contactMap.keySet(), Contact.getSObjectType());
            }else{
                LeadScoreQueueableCall executeQueueable = new LeadScoreQueueableCall(new ContactLeadScoreHelper(), setMarketingSegMap(), contactMap.keySet());
                System.enqueueJob(executeQueueable);
            }
        }
    }

    /**
     * Async process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(LeadScoreCalculatorService.ObjectMap objectMap, Set<Id> contactIds){
        LeadScoreCalculatorService.calculateLeadScore(objectMap, contactIds, Contact.getSObjectType());
    } 

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(Contact contact, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isUnderGrad = marketingSegMap.containsKey(contact.Id) && marketingSegMap.get(contact.Id).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isDomesticContact = isUnderGrad && contact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isUnderGrad && contact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        
        if(isDomesticContact){
            domesticUnderGradMap.put(contact.Id, contact);
        }
        else if(isInternationalContact){
            internationalUnderGradMap.put(contact.Id, contact);
        }
    }

    /**
     * Maps Postgrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevel(Contact contact, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isPostGrad = marketingSegMap.containsKey(contact.Id) && marketingSegMap.get(contact.Id).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isDomesticContact = isPostGrad && contact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isPostGrad && contact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;

        if(isDomesticContact){
            domesticPostGradMap.put(contact.Id, contact);
        }
        else if(isInternationalContact){
            internationalPostGradMap.put(contact.Id, contact);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap, internationalUndeterminedMap, and undeterminedUndeterminedMap
     */
    private static void mapUndeterminedStudyLevel(Contact contact, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        Boolean isUndetermined = marketingSegMap.containsKey(contact.Id) && String.isBlank(marketingSegMap.get(contact.Id).My_Primary_Study_Level__c);
        Boolean isDomesticContact = isUndetermined && contact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
        Boolean isInternationalContact = isUndetermined && contact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        Boolean hasNoCitizenship = isUndetermined && String.isBlank(contact.hed__Citizenship_Status__c);

        if(isDomesticContact){
            domesticUndeterminedMap.put(contact.Id, contact);
        }
        else if(isInternationalContact){
            internationalUndeterminedMap.put(contact.Id, contact);
        }
        else if(hasNoCitizenship){
            undeterminedUndeterminedMap.put(contact.Id, contact);
        }
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

}