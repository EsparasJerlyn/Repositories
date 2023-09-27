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
    
}