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
        Map<Id, hed__Program_Enrollment__c> accountProgramMap = new Map<Id, hed__Program_Enrollment__c>();

        /**
         * Filter records to be processed
         */
        for(hed__Program_Enrollment__c programEnrollment : newItems){
            if(programEnrollment.hed__Contact__c != null && programEnrollment.hed__Account__c != null){
                contactIdSet.add(programEnrollment.hed__Contact__c);
                accountProgramMap.put(programEnrollment.hed__Account__c, programEnrollment);
            }
        }
        /**
         * Determines wether to run async or sync
         */
        if(!contactIdSet.isEmpty()){           
            if(System.isQueueable()){
                executeCalculation(contactIdSet, accountProgramMap);
            }else{      
                QueueableCall executeQueueable = new QueueableCall(contactIdSet, accountProgramMap);
                System.enqueueJob(executeQueueable);   
            }
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevel(hed__Program_Enrollment__c progEnrollment, Map<Id,Marketing_Segmentation__c> marketingSegMap) {

        Boolean isUnderGrad = marketingSegMap.containsKey(progEnrollment.hed__Contact__c) && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
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

        Boolean isPostGrad = marketingSegMap.containsKey(progEnrollment.hed__Contact__c) && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
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

        Boolean isUndetermined = marketingSegMap.containsKey(progEnrollment.hed__Contact__c) && marketingSegMap.get(progEnrollment.hed__Contact__c).My_Primary_Study_Level__c == null;
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
        private Map<Id, hed__Program_Enrollment__c> accountProgramMap;
        
        public QueueableCall(Set<Id> contactIdSet, Map<Id, hed__Program_Enrollment__c> accountProgramMap) {
            this.contactIdSet = contactIdSet;
            this.accountProgramMap = accountProgramMap;
        }

        public void execute(QueueableContext context) {
            executeCalculation(contactIdSet, accountProgramMap);
        }
    }

    /**
     * Process that includes:
     * 1. Retrieval of lead score config
     * 2. Calculation of lead score per study level and citizenship status
     * 3. inserting/updating of lead score detail
     */
    public static void executeCalculation(Set<Id> contactIdSet, Map<Id, hed__Program_Enrollment__c> accountProgramMap){
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<String> fields = new List<String>{'Name', 'RecordTypeId', 'Program_Code__c'};
        List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetIds(accountProgramMap.keySet(), fields, AccessLevel.SYSTEM_MODE);
        for(Account account : accountList){
            //sets the program enrollment and the linked account
            accountMap.put(accountProgramMap.get(account.Id).Id, account);
        }

        Map<Id,hed__Program_Enrollment__c> programEnrollmentMap = setProgramEnrollmentMap(contactIdSet, accountMap);        
        LeadScoreCalculatorService.ObjectMap objMap = setObjectMap(contactIdSet, programEnrollmentMap);
        if(!programEnrollmentMap.isEmpty()){
            LeadScoreCalculatorService.calculateLeadScore(objMap, contactIdSet, hed__Program_Enrollment__c.getSObjectType());
        }
    } 

    /**
     * Retrieve sibling records
     */
    private static Map<Id,hed__Program_Enrollment__c> setProgramEnrollmentMap(
        Set<Id> contactIdSet, 
        Map<Id, Account> accountMap
    ){

        Map<Id,hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id,hed__Program_Enrollment__c>();
        List<hed__Program_Enrollment__c> progEnrollmentList = new List<hed__Program_Enrollment__c>();
        if(!contactIdSet.isEmpty()){
            progEnrollmentList = ProgramEnrollmentsDAO.newInstance().getProgramEnrollmentsByContactIdAndStatus(
                contactIdSet,
                ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ENROLLED,
                AccessLevel.SYSTEM_MODE
            );
        }
        for(hed__Program_Enrollment__c progEng : progEnrollmentList){
            if(
                accountMap.containsKey(progEng.Id) && 
                (
                    (accountMap.get(progEng.Id).Name != null) ||
                    (accountMap.get(progEng.Id).Program_Code__c != null)
                ) &&
                (accountMap.get(progEng.Id).RecordTypeId == AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID) 
            ){
                programEnrollmentMap.put(progEng.Id, progEng);
            }
        }

        return programEnrollmentMap;
    }

    /**
     * Sets the object map to be used in queueable job
     */
    private static LeadScoreCalculatorService.ObjectMap setObjectMap(Set<Id> contactIdSet, Map<Id,hed__Program_Enrollment__c> programEnrollmentMap){

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