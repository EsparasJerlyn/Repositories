/**
 * @description helper class for CaseTriggerHandler
 * @see CaseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | Sept 11,2023          | DEPP-6421              | Created file                                     |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added method for updating case using WhatsApp    |
 */
public with sharing class CaseTriggerHelper {

    private static final Map<String, Id> CASE_RECTYPE_MAP = new Map<String, Id>{
        'Domestic FS Enquiry' => CasesDAO.DOMESTICFS_RECTYPE_ID,
        'Incident' => CasesDAO.INCIDENT_RECTYPE_ID,
        'International Enquiry' => CasesDAO.INTERNATIONAL_RECTYPE_ID,
        'International FS Enquiry' => CasesDAO.INTERNATIONALFS_RECTYPE_ID
    };
    private static final Map<String, Integer> PRIORITY_ORDER = new Map<String, Integer>{
        'High' => 3,
        'Medium' => 2,
        'Low' => 1,
        '' => 0,
        null => 0
    };

    //map of object type to the field api names of the fields to be matched
    private static final Map<SObjectType, List<String>> OBJECT_MAP = new Map<SObjectType, List<String>>{
        Lead.SObjectType => new List<String>{ 'Email', 'Work_Email__c' },
        Contact.SObjectType => new List<String>{
            'Email',
            'Work_Email__c',
            'QUT_Learner_Email__c',
            'QUT_Staff_Email__c'
        }
    };

    /**
     * @description: Match the case supplied email from an existing contact or lead email address to
     *               the new created case record
     * @param newItems - List of case record
     */
    public static void matchExistingContactOrLeadToCase(
        List<Case> newCaseList
    ) {        
        Set<String> suppliedEmails = new Set<String>();
        Map<Id,Case> emailToCaseMap = new Map<Id,Case>();
        
        for(Case caseRec: newCaseList)
        {           
            Boolean isContactAndLeadEmpty = (String.isEmpty(caseRec.contactId) && String.isEmpty(caseRec.Lead__c));
            
            if(String.isNotEmpty(caseRec.SuppliedEmail) && 
               isContactAndLeadEmpty)
            {
                suppliedEmails.add(caseRec.SuppliedEmail); 
                emailToCaseMap.put(caseRec.Id,caseRec);
            }            
        }
        
        if(!suppliedEmails.isEmpty())
        {
           processCaseRecordsToContactMatch(suppliedEmails,emailToCaseMap);
        }       
    }

    /**
     * @description: Check contact or lead records for any potential match of an existing contact
     *               or lead records
     * @param Set<String> suppliedEmails
     * @param Map<Id,Case> emailToCaseMap
     */
    private  static void processCaseRecordsToContactMatch(
        Set<String> suppliedEmails,
        Map<Id,Case> emailToCaseMap
    ) {
        List<Case> caseToUpdate = new List<Case>();
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();        
        List<Contact> existingContactsWithMatchingEmails = ContactsDAO.newInstance()
            .getExistingPersonContactsWithMatchingEmails(
                suppliedEmails,
                new Set<Id>(),
                'SYSTEM_MODE'
            );
        
        if (!existingContactsWithMatchingEmails.isEmpty())
        {
            for (Contact newRecord : existingContactsWithMatchingEmails)
            {
                DuplicateCheckerHelper.countUniqueFieldsToMap(newRecord, new ContactsDAO().getSObjectType());
            }
            
            if (
                !DuplicateCheckerHelper.newItemsMatchCount.isEmpty()
            ) {
                //get unique contact record
                Map<String,String> uniqueContactMap = getUniqueRecords((List<sObject>) existingContactsWithMatchingEmails, new ContactsDAO().getSObjectType());
				//link the case to the match contact records                 
                linkCaseToContactRecord((List<Case>) emailToCaseMap.values(),caseToUpdate,uniqueContactMap);
            } 
            
        }else{
            caseToUpdate.addAll(processCaseRecordsToLeadMatch(suppliedEmails,(List<Case>) emailToCaseMap.values())); 
        }
        
        //update the case record if there's a match
        updateCaseRecord(caseToUpdate);
    }
    
    /**
     * @description: Check contact or lead records for any potential match of an existing contact
     *               or lead records
     * @param Set<String> suppliedEmails
     * @param Map<Id,Case> emailToCaseMap
     */
    private static List<Case> processCaseRecordsToLeadMatch(
        Set<String> suppliedEmails,
        List<Case> caseList
    ) {
        List<Case> caseToUpdate = new List<Case>();
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();        
        List<Lead> existingLeadsWithMatchingEmails = LeadsDAO.newInstance()
            .getExistingUnconvertedLeads(
                suppliedEmails,
                'SYSTEM_MODE'
            );
        
        if (!existingLeadsWithMatchingEmails.isEmpty())
        {
            for (Lead newRecord : existingLeadsWithMatchingEmails)
            {
                DuplicateCheckerHelper.countUniqueFieldsToMap(newRecord, new LeadsDAO().getSObjectType());
            }
            
            if (
                !DuplicateCheckerHelper.newItemsMatchCount.isEmpty()
            ) {
                //get unique record match to case email
                Map<String,String> uniqueLeadMap = getUniqueRecords((List<sObject>) existingLeadsWithMatchingEmails, new LeadsDAO().getSObjectType());				
                //link the case to the match lead records                
                linkCaseToLeadRecord(caseList,caseToUpdate,uniqueLeadMap);
            }            
        }
        
        return caseToUpdate;
    }
    
    /**
     * @description: get the unique records that is match to the existing email of contact or lead
     * @param List<sObject> recordList
     * @param SObjectType recordObjectType
     * @return Map<String,String> uniqueRecordMap
     */
    public static Map<String,String> getUniqueRecords(List<sObject> recordList,SObjectType recordObjectType) {
        Map<String,String> uniqueRecordMap = new Map<String,String>();
        for (sObject newRecord : recordList) {
            for (String field : OBJECT_MAP.get(recordObjectType)) {
                if (DuplicateCheckerHelper.newItemsMatchCount?.get((String) newRecord.get(field)) == 1) {
                    uniqueRecordMap.put((String) newRecord.get(field),newRecord.Id);
                }
            }    
        }
        return uniqueRecordMap;
    }

    /**
     * @description: link case record to the match contact record 
     * @param List<Case> caseList
     * @param List<Case> caseToUpdate
     * @param Map<String,String> uniqueContactMap
     * @param Set<String> suppliedEmails
     */
    public static void linkCaseToContactRecord(List<Case> caseList,List<Case> caseToUpdate,Map<String,String> uniqueContactMap) {
        List<Case> caseWithNoContactMatch = new List<Case>();
        Set<String> suppliedEmails = new Set<String>();
        
        for(Case caseRec: caseList){
            if(uniqueContactMap.containsKey(caseRec.SuppliedEmail)){ 
                caseToUpdate.add(
                    new Case(  
                        Id = caseRec.Id, 
                        ContactId = (Id) uniqueContactMap.get(caseRec.SuppliedEmail) 
                    )
                );                        
            }else{
                caseWithNoContactMatch.add(caseRec);
                suppliedEmails.add(caseRec.SuppliedEmail); 
            }
        }
        //match case email to existing lead records
        matchCaseRecordLead(caseToUpdate,suppliedEmails,caseWithNoContactMatch);
    }
    
    /**
     * @description: link case record to the match lead record 
     * @param List<Case> caseList
     * @param List<Case> caseToUpdate
     * @param Map<String,String> uniqueLeadMap
     */
    public static void linkCaseToLeadRecord(List<Case> caseList,List<Case> caseToUpdate,Map<String,String> uniqueLeadMap) {
        for(Case caseRec: caseList){
            if(uniqueLeadMap.containsKey(caseRec.SuppliedEmail)){                       
                caseToUpdate.add(
                    new Case(  
                        Id = caseRec.Id, 
                        Lead__c = (Id) uniqueLeadMap.get(caseRec.SuppliedEmail) 
                    )
                );                       
            }
        }
    }
    
    /**
     * @description: Updating the case record
     *
     * @param List<Case> caseToUpdate
     */
    private static void updateCaseRecord(List<Case> caseToUpdate) {
        if(!caseToUpdate.isEmpty()){
            CasesDAO.newInstance().updateRecords(caseToUpdate, false, AccessLevel.SYSTEM_MODE);  
        }   
    }
    
    /**
     * @description: evaluate the case email having no match to existing contact
     *
     * @param List<Case> caseToUpdate
     */
    private static void matchCaseRecordLead(List<Case> caseToUpdate,Set<String> suppliedEmails,List<Case> caseWithNoContactMatch) {
        if(!caseWithNoContactMatch.isEmpty()){
            caseToUpdate.addAll(processCaseRecordsToLeadMatch(suppliedEmails,caseWithNoContactMatch));
        }   
    }


    public static void caseRecordByMobileMatching (List<Case> newCaseList){
        Map<String,Case> caseWithSuppliedPhoneMap = new Map<String,Case>();
        for(Case caseRec: newCaseList){           
            Boolean isContactAndLeadEmpty = (String.isEmpty(caseRec.contactId) && String.isEmpty(caseRec.Lead__c));
            Boolean isCaseOriginWhatsApp = (caseRec.Origin == CasesDAO.ORIGIN_WHATSAPP);
            Boolean isSuppliedPhoneEmpty = String.isNotEmpty(caseRec.SuppliedPhone);
            if(isCaseOriginWhatsApp && isSuppliedPhoneEmpty && isContactAndLeadEmpty)
            {
                caseWithSuppliedPhoneMap.put(caseRec.SuppliedPhone,caseRec);
            }               
        }
        
        if(!caseWithSuppliedPhoneMap.isEmpty()){
            processAndUpdateCaseRecordsForMobileMatch(caseWithSuppliedPhoneMap);
        }
    }

    private static void processAndUpdateCaseRecordsForMobileMatch(Map<String,Case> caseWithSuppliedPhoneMap){
        Map<String,List<Contact>> contactMap = CaseService.mapExistingContactMatchToCase(caseWithSuppliedPhoneMap.keySet());
        Map<String,List<Lead>> leadtMap = CaseService.mapExistingLeadMatchToCase(caseWithSuppliedPhoneMap.keySet());
        for(Case caseRec : caseWithSuppliedPhoneMap.values()){
            if(contactMap.containsKey(caseRec.SuppliedPhone) && contactMap.get(caseRec.SuppliedPhone).size() == 1){
                caseRec.ContactId = contactMap.get(caseRec.SuppliedPhone)[0].Id;
            }
            else if(leadtMap.containsKey(caseRec.SuppliedPhone) && leadtMap.get(caseRec.SuppliedPhone).size() == 1){
                caseRec.Lead__c = leadtMap.get(caseRec.SuppliedPhone)[0].Id;
            }
        }
    }
    

    /**
     * @description update the Auto_Priority_Assignment__c based on username mdt
     *
     * @param newItems  List of new Case records
     */
    public static void updateCaseAutoPriorityAssignment(List<Case> newItems) {
        Map<String, Auto_Priority_Assignment_Configuration__mdt> usernamesMap = new Map<String, Auto_Priority_Assignment_Configuration__mdt>();
        List<Auto_Priority_Assignment_Configuration__mdt> autoPriorityConfigs = [SELECT Username__c FROM Auto_Priority_Assignment_Configuration__mdt];
        for(Auto_Priority_Assignment_Configuration__mdt autoPriorityConfig : autoPriorityConfigs){
            usernamesMap.put(autoPriorityConfig.Username__c, autoPriorityConfig);
        }
        String userEmail = UserInfo.getUserEmail();
        
        for(Case item : newItems){
            if(usernamesMap.containsKey(userEmail)){
                item.Auto_Priority_Assignment__c = true;
            }
        }
    }

    /**
     * @description: Set the case priority based on
     * @param newItems - List of case record
     */
    public static void handleAutoPriorityAssignedCase(
        List<Case> newCaseList
    ) {
        List<Case> autoPriorityAssignedCases = new List<Case>();
        for(Case item : newCaseList){
            if(
                item.Auto_Priority_Assignment__c == true &&
                item.Status == 'Created' &&
                item.Priority != 'High'
            ){
                autoPriorityAssignedCases.add(item);
            }
        }
        if(!autoPriorityAssignedCases.isEmpty()){
            enqueueQueueableProcess(autoPriorityAssignedCases, 'CasePriorityAssignment');
        }
    }

    /**
     * @description Enqueues the given case for future priority assignment using a DynamicQueueableProcess.
     *
     * @param autoPriorityAssignedCases  List of Cases to enqueue
     * @param methodName name of the method to execute in the DynamicQueueableProcess
     */
    private static void enqueueQueueableProcess(List<Case> autoPriorityAssignedCases, String serviceClassName) {
        DynamicQueueableProcess queueableCalls = new DynamicQueueableProcess(autoPriorityAssignedCases, serviceClassName);
        System.enqueueJob(queueableCalls);
    }

    /**
     * @description: queueable method to set case priorities
     * @param newItems - List of case record
     */
    public static void enqueueCasesToPrioritize(List<Case> autoPriorityAssignedCases){
        try{
            Map<Id,Case> prioritizedCases = new Map<Id,Case>();
            List<Case> completeFieldCases = getCasesWithRequiredFields(autoPriorityAssignedCases);
            Map<String,String> countryTierMap = getCountryTierMap();
            List<Case_Priority_Configuration__c> casePriorityConfigs = [
                SELECT Name, Case_Record_Type__c, Country_Tier__c, Enquiry_Category__c, Enquiry_Sub_Category__c, Lead_Score__c, Future_Student_Stage__c, Date_from__c, Date_to__c, Priority__c
                FROM Case_Priority_Configuration__c
                WHERE Is_Active__c = TRUE
                WITH SYSTEM_MODE
            ];
            for(Case_Priority_Configuration__c config: casePriorityConfigs){
                for(Case item : completeFieldCases){
                    if(
                        item.Priority == 'High' ||
                        PRIORITY_ORDER.get(config.Priority__c) < PRIORITY_ORDER.get(item.Priority)
                    ){
                        break;
                    }

                    boolean isCaseForUpdate = matchConfigToCaseBase(item, config) && matchCountryTier (item, config, countryTierMap) && 
                    matchCategoryAndSubCategory (item, config) && checkDateDuration(config.Date_from__c, config.Date_to__c, item.CreatedDate);

                    if(isCaseForUpdate){
                        item.Priority = config.Priority__c;
                        item.Subject = config.Name;
                        prioritizedCases.put(item.Id, item);
                    }
                }
            }
            updateCases(prioritizedCases);
        } catch (Exception e) {
            Logger.error('Exception caught in method enqueueCasesToPrioritize in class CaseTriggerHelper.')
              .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    private static List<Case> getCasesWithRequiredFields(List<Case> autoPriorityAssignedCases){
        Set<Id> caseIds = new Set<Id>();
        for(Case item : autoPriorityAssignedCases){
            caseIds.add(item.Id);
        }
        return CasesDAO.newInstance().getCasesByIds(caseIds, AccessLevel.SYSTEM_MODE);
    }

    private static Map<String,String> getCountryTierMap(){
        Map<String,String> countryTierMap = new Map<String,String>();
        List<International_Tier__c> countryTierList = [
            SELECT Country_Name__c, Tier_Category__c
            FROM International_Tier__c
            WHERE IsActive__c = TRUE
            WITH SYSTEM_MODE
        ];
        if(!countryTierList.isEmpty()){
            for (International_Tier__c countryTier : countryTierList){
                countryTierMap.put(countryTier.Country_Name__c,countryTier.Tier_Category__c);
            }
        }
        return countryTierMap;
    }

    private static void updateCases(Map<Id,Case> mapCase){
        if(!mapCase.keyset().isEmpty()){
            CasesDAO.newInstance().updateRecords(mapCase.values(),false,AccessLevel.SYSTEM_MODE);
        }
    }

    private static Boolean matchConfigToCaseBase (
        Case item,
        Case_Priority_Configuration__c config
    ){
        Boolean trueSoFar = config.Case_Record_Type__c != null
                          ? CASE_RECTYPE_MAP.get(config.Case_Record_Type__c) == item.RecordTypeId
                          : true;
        if(
            config.Lead_Score__c != null &&
            ( config.Lead_Score__c != item.Lead__r.Lead_Score__c &&
              config.Lead_Score__c != item.Contact.Lead_Score__c )
        ){
            trueSoFar = false;
        }
        if(
            config.Future_Student_Stage__c != null &&
            ( config.Future_Student_Stage__c != item.Lead__r.Future_Student_Journey_Status__c &&
              config.Future_Student_Stage__c != item.Contact.Future_Student_Journey_Status__c )
        ){
            trueSoFar = false;
        }
        return trueSoFar;
    }

    private static Boolean matchCountryTier(
        Case item,
        Case_Priority_Configuration__c config,
        Map<String,String> countryTierMap
    ){
        Boolean trueSoFar = true;
        if(
            config.Country_Tier__c != null &&
            ( config.Country_Tier__c != countryTierMap.get(item.Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c) &&
              config.Country_Tier__c != countryTierMap.get(item.Contact.Citizenship_Country__c) )
        ){
            trueSoFar = false;
        }
        return trueSoFar;
    }

    private static Boolean matchCategoryAndSubCategory(
        Case item,
        Case_Priority_Configuration__c config
    ){
        Boolean trueSoFar = (
            config.Enquiry_Category__c != null ? config.Enquiry_Category__c.split(';').contains(item.Category__c) : true &&
            config.Enquiry_Sub_Category__c != null ? config.Enquiry_Sub_Category__c.split(';').contains(item.Sub_Category__c) : true
        );
        return trueSoFar;
    }

    private static Boolean checkDateDuration(
        Date fromDate,
        Date toDate,
        Datetime caseCreatedDate
    ){
        Boolean trueSoFar = true;
        if(fromDate != null && toDate != null){
            Date dateToCheck = date.newinstance(caseCreatedDate.year(), caseCreatedDate.month(), caseCreatedDate.day());
            trueSoFar = fromDate < dateToCheck && toDate > dateToCheck;
        }
        return trueSoFar;
    }
}