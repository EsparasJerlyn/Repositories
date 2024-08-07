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
      | ken.marvin.narido              | Oct  12,2023          | DEPP-6871              | changed the reference for the auto prio metadata |
      | mark.j.mahilum                 | Oct 30,2023           | DEPP-7051              | Updated case priority for whatsapp case origin   |
      | julie.jane.alegre              | Nov 07, 2023          | DEPP-7152              | Updated matchExistingContactOrLeadToCase         |
      | eccarius.munoz                 | April 5, 2024         | DEPP-7533	            | Added handleOutreachCasePriority                 | 
      | eccarius.munoz                 | June 2, 2024          | DEPP-8484	            | Added setOutreachKeyForClosedCase                | 
      | eccarius.munoz                 | June 4, 2024          | DEPP-7533	            | Updated handling for outreach case medium prio   | 
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
    public static void matchExistingContactOrLeadToCase(List<Case> newCaseList) {
        Set<String> suppliedEmails = new Set<String>();
        Map<Id, Case> emailToCaseMap = new Map<Id, Case>();
        Map<Id,Case> contactCaseMap = new Map<Id,Case>();

        for (Case caseRec : newCaseList) {
            //Standard email-to-case functionality ensures that a case is matched to a contact,
            //regardless of the record type, 
            //and populates the Case.ContactId
            //we must check if the contact has a recordtype MC PERSONA
            if(String.isNotEmpty(caseRec.contactId)){
                contactCaseMap.put(caseRec.contactId,caseRec);
            }

            Boolean isWithEmailAndContactAndLeadEmpty = (String.isEmpty(caseRec.contactId) &&
            String.isEmpty(caseRec.Lead__c)) && String.isNotEmpty(caseRec.SuppliedEmail);
            if ( isWithEmailAndContactAndLeadEmpty) {
                suppliedEmails.add(caseRec.SuppliedEmail);
                emailToCaseMap.put(caseRec.Id, caseRec);
            }
        }

        if(!contactCaseMap.isEmpty()){    
            //check if contact is mc persona      
            for(Contact con: ContactsDAO.newInstance()
                                .getExistingMCPersonaContactsBySetIds(
                                    contactCaseMap.keySet(), 
                                    AccessLevel.SYSTEM_MODE)
                                ){
                //store case and email info of MC Persona contact
                //for it to be matched with the PERSON contact
                Case caseRec = contactCaseMap.get(con.Id);
                suppliedEmails.add(caseRec.SuppliedEmail);
                emailToCaseMap.put(caseRec.Id, caseRec);
            }
        }
        
        if (!suppliedEmails.isEmpty()) {
            processCaseRecordsToContactMatch(suppliedEmails, emailToCaseMap);
        }
    }

    /**
     * @description: Check contact or lead records for any potential match of an existing contact
     *               or lead records
     * @param Set<String> suppliedEmails
     * @param Map<Id,Case> emailToCaseMap
     */
    private static void processCaseRecordsToContactMatch(
        Set<String> suppliedEmails,
        Map<Id, Case> emailToCaseMap
    ) {
        List<Case> caseToUpdate = new List<Case>();
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
        List<Contact> existingContactsWithMatchingEmails = ContactsDAO.newInstance()
            .getExistingPersonContactsWithMatchingEmails(
                suppliedEmails,
                new Set<Id>(),
                'SYSTEM_MODE'
            );

        if (!existingContactsWithMatchingEmails.isEmpty()) {
            for (Contact newRecord : existingContactsWithMatchingEmails) {
                DuplicateCheckerHelper.countUniqueFieldsToMap(
                    newRecord,
                    new ContactsDAO().getSObjectType()
                );
            }

            if (!DuplicateCheckerHelper.newItemsMatchCount.isEmpty()) {
                //get unique contact record
                Map<String, String> uniqueContactMap = getUniqueRecords(
                    (List<sObject>) existingContactsWithMatchingEmails,
                    new ContactsDAO().getSObjectType()
                );
                //link the case to the match contact records
                linkCaseToContactRecord(
                    (List<Case>) emailToCaseMap.values(),
                    caseToUpdate,
                    uniqueContactMap
                );
            }
            
        } else {
            caseToUpdate.addAll(
                processCaseRecordsToLeadMatch(suppliedEmails, (List<Case>) emailToCaseMap.values())
            );
        }

        

        //update the case record if there's a match
        CaseService.updateCases(caseToUpdate, AccessLevel.SYSTEM_MODE);
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
            .getExistingUnconvertedLeads(suppliedEmails, 'SYSTEM_MODE');

        if (!existingLeadsWithMatchingEmails.isEmpty()) {
            for (Lead newRecord : existingLeadsWithMatchingEmails) {
                DuplicateCheckerHelper.countUniqueFieldsToMap(
                    newRecord,
                    new LeadsDAO().getSObjectType()
                );
            }

            if (!DuplicateCheckerHelper.newItemsMatchCount.isEmpty()) {
                //get unique record match to case email
                Map<String, String> uniqueLeadMap = getUniqueRecords(
                    (List<sObject>) existingLeadsWithMatchingEmails,
                    new LeadsDAO().getSObjectType()
                );
                //link the case to the match lead records
                linkCaseToLeadRecord(caseList, caseToUpdate, uniqueLeadMap);
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
    public static Map<String, String> getUniqueRecords(
        List<sObject> recordList,
        SObjectType recordObjectType
    ) {
        Map<String, String> uniqueRecordMap = new Map<String, String>();
        for (sObject newRecord : recordList) {
            for (String field : OBJECT_MAP.get(recordObjectType)) {
                if (
                    DuplicateCheckerHelper.newItemsMatchCount?.get((String) newRecord.get(field)) ==
                    1
                ) {
                    uniqueRecordMap.put((String) newRecord.get(field), newRecord.Id);
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
    public static void linkCaseToContactRecord(
        List<Case> caseList,
        List<Case> caseToUpdate,
        Map<String, String> uniqueContactMap
    ) {
        List<Case> caseWithNoContactMatch = new List<Case>();
        Set<String> suppliedEmails = new Set<String>();

        for (Case caseRec : caseList) {
            if (uniqueContactMap.containsKey(caseRec.SuppliedEmail)) {
                caseToUpdate.add(
                    new Case(
                        Id = caseRec.Id,
                        ContactId = (Id) uniqueContactMap.get(caseRec.SuppliedEmail)
                    )
                );
            } else {
                caseWithNoContactMatch.add(caseRec);
                suppliedEmails.add(caseRec.SuppliedEmail);
            }
        }
        //match case email to existing lead records
        matchCaseRecordLead(caseToUpdate, suppliedEmails, caseWithNoContactMatch);
    }

    /**
     * @description: link case record to the match lead record
     * @param List<Case> caseList
     * @param List<Case> caseToUpdate
     * @param Map<String,String> uniqueLeadMap
     */
    public static void linkCaseToLeadRecord(
        List<Case> caseList,
        List<Case> caseToUpdate,
        Map<String, String> uniqueLeadMap
    ) {
        for (Case caseRec : caseList) {
            if (uniqueLeadMap.containsKey(caseRec.SuppliedEmail)) {
                caseToUpdate.add(
                    new Case(
                        Id = caseRec.Id,
                        Lead__c = (Id) uniqueLeadMap.get(caseRec.SuppliedEmail),
                        ContactId = null
                    )
                );
            }
        }
    }

    /**
     * @description: evaluate the case email having no match to existing contact
     *
     * @param List<Case> caseToUpdate
     */
    private static void matchCaseRecordLead(
        List<Case> caseToUpdate,
        Set<String> suppliedEmails,
        List<Case> caseWithNoContactMatch
    ) {
        caseToUpdate.addAll(
            processCaseRecordsToLeadMatch(suppliedEmails, caseWithNoContactMatch)
        );
    }

    public static void caseRecordByMobileMatching(List<Case> newCaseList) {
        Map<String, Case> caseWithSuppliedPhoneMap = new Map<String, Case>();
        for (Case caseRec : newCaseList) {

            Boolean isContactAndLeadEmpty = (String.isEmpty(caseRec.contactId) &&
            String.isEmpty(caseRec.Lead__c));
            Boolean isCaseOriginWhatsApp = (caseRec.Origin == CasesDAO.ORIGIN_WHATSAPP);
            Boolean isSuppliedPhoneEmpty = String.isNotEmpty(caseRec.SuppliedPhone);

            Boolean isCaseWithSuppliedPhone = isCaseOriginWhatsApp && isSuppliedPhoneEmpty && isContactAndLeadEmpty;

            if (isCaseWithSuppliedPhone) {
                caseWithSuppliedPhoneMap.put(caseRec.SuppliedPhone, caseRec);
            }

            caseRec.Priority = (isCaseOriginWhatsApp && isSuppliedPhoneEmpty)? 'Low': caseRec.Priority;
        }

        processAndUpdateCaseRecordsForMobileMatch(caseWithSuppliedPhoneMap);
    }

    private static void processAndUpdateCaseRecordsForMobileMatch(
        Map<String, Case> caseWithSuppliedPhoneMap
    ) {
        Map<String, List<Contact>> contactMap = CaseService.mapExistingContactMatchToCase(
            caseWithSuppliedPhoneMap.keySet()
        );
        Map<String, List<Lead>> leadtMap = CaseService.mapExistingLeadMatchToCase(
            caseWithSuppliedPhoneMap.keySet()
        );
        for (Case caseRec : caseWithSuppliedPhoneMap.values()) {

            boolean isOneContactWithMobile = contactMap.containsKey(caseRec.SuppliedPhone) &&
            contactMap.get(caseRec.SuppliedPhone).size() == 1;

            boolean isOneLeadWithMobile = 
            leadtMap.containsKey(caseRec.SuppliedPhone) &&
            leadtMap.get(caseRec.SuppliedPhone).size() == 1;

            if (
                isOneContactWithMobile
            ) {
                caseRec.ContactId = contactMap.get(caseRec.SuppliedPhone)[0].Id;
            } else if (
                isOneLeadWithMobile
            ) {
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
        Set<String> userNameSet = new Set<String>();

        for (
            Auto_Priority_Assignment_Configuration__mdt autoPriorityConfig : Auto_Priority_Assignment_Configuration__mdt.getAll()
                .values()
        ) {
            userNameSet.add(autoPriorityConfig.Username__c);
        }

        boolean isUserPriority = userNameSet.contains(UserInfo.getUserName());

        if (isUserPriority) {
            for (Case item : newItems) {
                item.Auto_Priority_Assignment__c = true;
            }
        }
    }

    /**
     * @description: Set the case priority based on
     * @param newItems - List of case record
     */
    public static void handleAutoPriorityAssignedCase(List<Case> newCaseList) {
        List<Case> autoPriorityAssignedCases = new List<Case>();

        for (Case item : newCaseList) {
            Boolean isCaseForProcess =
                item.RecordTypeId == CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID &&
                item.Auto_Priority_Assignment__c == true &&
                item.Status == 'Created' &&
                item.Priority != 'High';

            if (isCaseForProcess) {
                autoPriorityAssignedCases.add(item);
            }
        }

        if (!autoPriorityAssignedCases.isEmpty()) {
            DynamicQueueableProcess queueableCalls = new DynamicQueueableProcess(
                autoPriorityAssignedCases,
                'CaseService',
                AccessLevel.SYSTEM_MODE
            );
            System.enqueueJob(queueableCalls);
        }
    }

    /**
     * @description Handles case priority setup for outreac record type
     * @param newItems - List of case record
     */
    public static void handleOutreachCasePriority(List<Case> newItems) {

        //get all contacts from case
        Map<Id, Case> caseByContactMap = new Map<Id, Case>();        
        for(Case caseRecord : newItems){
            if(caseRecord.RecordTypeId == CasesDAO.OUTREACH_RECTYPE_ID){
                caseByContactMap.put(caseRecord.contactId, caseRecord);
            }
        }

        if(!caseByContactMap.isEmpty()){
            setOutreachCasePriority(caseByContactMap);
        }        
    }

    /**
     * @description Sets the case priority for outreach record type
     * @param caseByContactMap - Map of Cases by Contact Ids
     */
    private static void setOutreachCasePriority(Map<Id, Case> caseByContactMap){
        //get person contact details
        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(caseByContactMap.keySet(), AccessLevel.SYSTEM_MODE));
        Set<Id> contactsWithPriorityCourses = getContacIdsWithPriorityCourse(caseByContactMap.keySet());

        for(Case caseRecord : caseByContactMap.values()){

            //set priority to low as default for case outreach
            caseRecord.Priority = CasesDAO.PRIORITY_LOW;        

            if(contactMap.containsKey(caseRecord.contactId)){

                //validate record if for high priority
                Boolean isCriteriaForHigh = 
                    contactMap.get(caseRecord.contactId).Low_Socio_Economic_Status__c == 'Yes' ||
                    contactMap.get(caseRecord.contactId).Regional_Remote__c == 'Yes' ||
                    (
                        contactMap.get(caseRecord.contactId).ATSI_Code__c == ContactsDAO.ATSI_CODE_ABORIGINAL || 
                        contactMap.get(caseRecord.contactId).ATSI_Code__c == ContactsDAO.ATSI_CODE_ISLANDER || 
                        contactMap.get(caseRecord.contactId).ATSI_Code__c == ContactsDAO.ATSI_CODE_ABORIGINAL_ISLANDER
                    );
                
                //validate record if for medium priority
                Boolean isCriteriaForMeidum = !isCriteriaForHigh && contactsWithPriorityCourses.contains(caseRecord.contactId);

                //set Priority
                if(isCriteriaForHigh){
                    caseRecord.Priority = CasesDAO.PRIORITY_HIGH;
                }else if(isCriteriaForMeidum){
                    caseRecord.Priority = CasesDAO.PRIORITY_MEDIUM;
                }
            }
        }
    }

    /**
     * @description Retrieves Contact IDs with priority courses.
     * @param contactIdSet - Set<Id> Contact IDs to check.
     * @return Set<Id> - Set of Contact IDs with priority courses.
     */
    private static Set<Id> getContacIdsWithPriorityCourse(Set<Id> contactIdSet){

        Set<Id> contactsWithPriorityCourses = new Set<Id>();

        Map<String, Object> params = new Map<String, Object>{
            'contactIdSet' => contactIdSet,
            'academicProgramRecTypeId' => AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID,
            'enrollmentStatusList' => new Set<String>{
                ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED, 
                ProgramEnrollmentsDAO.ENROLLMENT_STATUS_LEAVE_OF_ABSENCE
            }
        };

        List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance().getPriorityCourses(params, AccessLevel.SYSTEM_MODE);
        for(hed__Program_Enrollment__c programEnrollment : programEnrollmentList){
            contactsWithPriorityCourses.add(programEnrollment.hed__Contact__c);
        }
        
        return contactsWithPriorityCourses;
    }

    /**
     * @description Sets the Outreach Key for outreach record type only
     * @param newItems - List of case record
     */
    public static void setOutreachKeyForClosedCase(List<Case> newItems, Map<Id, Case> oldItems) {

        List<Case> casesToUpdate = new List<Case>();      
        for(Case caseRecord : newItems){
            if(
                oldItems.get(caseRecord.Id).Status != caseRecord.Status &&
                caseRecord.RecordTypeId == CasesDAO.OUTREACH_RECTYPE_ID && 
                caseRecord.IsClosed
            ){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = caseRecord.Id;
                caseToUpdate.Outreach_Key__c = caseRecord.Engagement_List_Configuration__c + '_' + caseRecord.ContactId + '_' + caseRecord.Id;
                casesToUpdate.add(caseToUpdate);
            }
        }

        if(!casesToUpdate.isEmpty()){
            CasesDAO.newInstance().updateRecords(casesToUpdate, true, AccessLevel.SYSTEM_MODE);
        }
    }

}
