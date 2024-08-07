/**
 * @description helper class to map case marketing fields
 * @see ..CaseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                                  |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------------|
 *    | roy.nino.s.regala              | November 01, 2023     | DEPP-7060              | Created file to handle case marketing fields mapping            |
 *    | mark.j.mahilum                 | Feb 19, 2024          | DEPP-7551              | Updated method to add field mapping for contact and lead fields |
 *    | sebastianne.k.trias            | June 17, 2024         | DEPP-8474              | Removed Marketing Opt In Functionality                          |
 */
public with sharing class CaseMarketingHelper { //NOPMD
    private static final List<String> MARKETING_FIELDS = new List<String>{
        'My_Country_Of_Citizenship__c',
        'My_Citizenship_Status__c',
        'My_Country_Of_Residency__c',
        'My_Education_Level__c',
        'My_Primary_Study_Level__c'
    };

    public static void mapMarketingFieldsFromCase(List<Case> newItems, Map<Id, Case> oldItems) {
        Boolean isInsert = oldItems == null;

        //map that groups contact/lead to its updated marketing segmentation record
        Map<Id, Marketing_Segmentation__c> parentIdToMarketingSegmentation = new Map<Id, Marketing_Segmentation__c>();
        Set<Id> contactLeadIds = new Set<Id>();
        Map<Id,Case> contactLeadCaseMap = new Map<Id,Case>();

        for (Case caseRecord : newItems) {
            //check if case is new linked to contact/lead
            Boolean isForInboundEnquiry = caseRecord.RecordTypeId == CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID;

            if(!isForInboundEnquiry){
                continue;
            }
            
            Boolean isNewContactLinked =
                caseRecord.ContactId != null &&
                (isInsert || oldItems.get(caseRecord.Id).ContactId != caseRecord.ContactId);
            Boolean isNewLeadLinked =
                caseRecord.Lead__c != null &&
                (isInsert || oldItems.get(caseRecord.Id).Lead__c != caseRecord.Lead__c);

                
            //map case marketing fields to new instance of marketing segmentation
            if (isNewContactLinked) {
                mapMarketingSegmenationFields(
                    caseRecord.ContactId,
                    caseRecord,
                    parentIdToMarketingSegmentation
                );
            }else if (isNewLeadLinked) {
                mapMarketingSegmenationFields(
                    caseRecord.Lead__c,
                    caseRecord,
                    parentIdToMarketingSegmentation
                );
            }
            
            Boolean isCaseEmailMobilePhoneNotEmpty = (String.isNotEmpty(caseRecord.Web_Mobile_Locale__c) || String.isNotEmpty(caseRecord.Web_Mobile_No_Locale__c) || String.isNotEmpty(caseRecord.SuppliedEmail));
            Boolean isNewCaseContactLeadEmailPhoneNotEmpty = (isNewContactLinked || isNewLeadLinked) && isCaseEmailMobilePhoneNotEmpty;
            
            if(isNewCaseContactLeadEmailPhoneNotEmpty) {
                Id contactLeadId = (caseRecord.ContactId != null)? caseRecord.ContactId : caseRecord.Lead__c;
                contactLeadIds.add(contactLeadId);
                contactLeadCaseMap.put(contactLeadId,caseRecord);
            }
        }

        updateMarketingSegmentationRecords(parentIdToMarketingSegmentation);
        updateLeadAndContactOptInDates(contactLeadIds,contactLeadCaseMap);
    }

    private static void mapMarketingSegmenationFields(
        Id parentId,
        Case caseRecord,
        Map<Id, Marketing_Segmentation__c> parentIdToMarketingSegmentation
    ) {
        Marketing_Segmentation__c marSegRecord = new Marketing_Segmentation__c();

        //maps case marketing fields to marketing segmentation if not empty
        //e.g Case.My_Country_Of_Citizenship__c -> Marketing_Segmentation__r.My_Country_Of_Citizenship__c
        //see MARKETING_FIELDS static variable
        for (String marketingField : MARKETING_FIELDS) {
            if (String.isNotBlank((String) caseRecord.get(marketingField))) {
                marSegRecord.put(marketingField, (String) caseRecord.get(marketingField));
                parentIdToMarketingSegmentation.put(parentId, marSegRecord);
            }
        }
    }

    private static void updateMarketingSegmentationRecords(
        Map<Id, Marketing_Segmentation__c> parentIdToMarketingSegmentation
    ) {
        List<Marketing_Segmentation__c> marketingSegmentationsToUpdate = new List<Marketing_Segmentation__c>();
        Marketing_Segmentation__c marSegTemp;

        if (parentIdToMarketingSegmentation.keySet().isEmpty()) {
            return;
        }

        //get marketing segmentations related to the contact/lead
        //ideally, marketing segmentation has a 1:1 relationship to contact/lead
        for (
            Marketing_Segmentation__c marSeg : MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactOrLead(
                    parentIdToMarketingSegmentation.keySet(),
                    parentIdToMarketingSegmentation.keySet(),
                    AccessLevel.SYSTEM_MODE
                )
        ) {
            //set marketing segmentation fields from case
            marSegTemp = new Marketing_Segmentation__c();

            //construct marketing segmentation records to update using the contact/lead relationship
            Boolean containsContact = marSeg.Contact__c != null && parentIdToMarketingSegmentation.containsKey(marSeg.Contact__c);
            Boolean containsLead = marSeg.Lead__c != null && parentIdToMarketingSegmentation.containsKey(marSeg.Lead__c);
            if (containsContact) {
                marSegTemp = parentIdToMarketingSegmentation.get(marSeg.Contact__c);
                marSegTemp.Id = marSeg.Id;
                marketingSegmentationsToUpdate.add(marSegTemp);
            } else if (containsLead) {
                marSegTemp = parentIdToMarketingSegmentation.get(marSeg.Lead__c);
                marSegTemp.Id = marSeg.Id;
                marketingSegmentationsToUpdate.add(marSegTemp);
            }
        }

        if (!marketingSegmentationsToUpdate.isEmpty()) {

            //this process remove duplicates by force
            Map<Id,Marketing_Segmentation__c> uniqueMarketingSegmentations = new Map<Id,Marketing_Segmentation__c>();
            uniqueMarketingSegmentations.putAll(marketingSegmentationsToUpdate);

            MarketingSegmentationsDAO.newInstance()
                .updateRecords(
                    uniqueMarketingSegmentations.values(),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
        }
    }

    private static void updateLeadAndContactOptInDates(
        Set<Id> contactLeadIds,
        Map<Id,Case> contactLeadCaseMap
    ) {
        Map<Id,Contact> contactsToUpdateMap = new Map<Id,Contact>();
        Map<Id,Lead> leadsToUpdateMap = new Map<Id,Lead>();

        if (contactLeadIds.isEmpty()) {
            return;
        }

        for (
            Contact contactRecord : ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    contactLeadIds,
                    AccessLevel.SYSTEM_MODE
                )
        ) {
            
            mapCaseToContactFields(contactRecord,contactLeadCaseMap,contactsToUpdateMap);
            
        }

        //get lead fields
        //and check if Email_Opt_In_DateTime__c is already populated
        //and update email opt in date of lead to Case.Createddate
        for (
            Lead leadRecord : LeadsDAO.newInstance()
                .getLeadsByIdSet(contactLeadIds, AccessLevel.SYSTEM_MODE)
        ) {
            
            mapCaseToLeadFields(leadRecord,contactLeadCaseMap,leadsToUpdateMap);
        }

        if (!contactsToUpdateMap.values().isEmpty()) {
            ContactsDAO.newInstance()
                .updateRecords(contactsToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
        }

        if (!leadsToUpdateMap.values().isEmpty()) {
            LeadsDAO.newInstance().updateRecords(leadsToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }
    
    /**
     * Maps Case fields to Contact fields based on specific conditions.
     * 
     * @param contactRecord The Contact record to map fields to.
     * @param contactLeadCaseMap A map containing Case records linked to Contact records.
     * @param contactsToUpdateMap A map containing Contact records to update.
     */    
    private static void mapCaseToContactFields(
        Contact contactRecord,
        Map<Id,Case> contactLeadCaseMap,
        Map<Id,Contact> contactsToUpdateMap
    ) {
        // Check if the contact record has a corresponding case in the map
        if (!contactLeadCaseMap.containsKey(contactRecord.Id)) {
            return; // Exit the method if no corresponding case found
        }
        
        // Retrieve the case associated with the contact record
        Case contactCase = contactLeadCaseMap.get(contactRecord.Id);
        // Extract email and mobile locale information from the case
        String caseEmail = contactCase.SuppliedEmail;
        String webMobileLocale = contactCase.Web_Mobile_Locale__c;
        String webMobileNoLocale = contactCase.Web_Mobile_No_Locale__c;
        
        // Check if the primary email of the contact is empty and if the case email is not empty
        boolean isPrimaryEmailEmpty = String.isEmpty(contactRecord.Email) && String.isNotEmpty(caseEmail);
        // Check if the Web Mobile Locale field associated with the case is not empty and the contact's mobile phone is empty
        boolean isWebMobileLocaleNotEmpty = String.isEmpty(contactRecord.MobilePhone) && String.isNotEmpty(webMobileLocale);
        // Check if the Web Mobile No Locale field associated with the case is not empty and the contact's mobile phone is empty
        boolean isWebMobileNoLocaleNotEmpty = String.isEmpty(contactRecord.MobilePhone) && String.isNotEmpty(webMobileNoLocale);
        
        // Check if the email-case mapping is valid by evaluating the validity of work email, QUT Learner email, and QUT Staff email
        boolean isEmailCaseMappingValid = isPrimaryEmailEmpty &&
            (contactRecord.Work_Email__c != caseEmail || contactRecord.QUT_Learner_Email__c != caseEmail || contactRecord.QUT_Staff_Email__c != caseEmail);
        
        // Perform updates if the email-case mapping is valid or if Web Mobile Locale or Web Mobile No Locale fields are not empty
        if (isEmailCaseMappingValid || isWebMobileLocaleNotEmpty || isWebMobileNoLocaleNotEmpty) {
            // Create a new Contact object with updated fields
            Contact updatedContact = new Contact(
                Id = contactRecord.Id,
                Email = isEmailCaseMappingValid ? caseEmail : contactRecord.Email,
                ContactMobile_Locale__c = isWebMobileLocaleNotEmpty ? webMobileLocale : contactRecord.ContactMobile_Locale__c,
                Mobile_No_Locale__c = isWebMobileNoLocaleNotEmpty ? webMobileNoLocale : contactRecord.Mobile_No_Locale__c
            );
            
            // Check if the contact already exists in the map of contacts to update
            if (contactsToUpdateMap.containsKey(contactRecord.Id)) {
                // Update the existing contact with the updated fields
                Contact existingContact = contactsToUpdateMap.get(contactRecord.Id);
                existingContact.Email = updatedContact.Email;
                existingContact.ContactMobile_Locale__c = updatedContact.ContactMobile_Locale__c;
                existingContact.Mobile_No_Locale__c = updatedContact.Mobile_No_Locale__c;
            } else {
                // Add the updated contact to the map of contacts to update
                contactsToUpdateMap.put(contactRecord.Id, updatedContact);
            }
        }
    }

    /**
     * Maps Case fields to Lead fields based on specific conditions.
     * 
     * @param leadRecord The Lead record to map fields to.
     * @param contactLeadCaseMap A map containing Case records linked to Lead records.
     * @param leadsToUpdateMap A map containing Lead records to update.
     */    
    private static void mapCaseToLeadFields(
        Lead leadRecord,
        Map<Id,Case> contactLeadCaseMap,
        Map<Id,Lead> leadsToUpdateMap
    ) {
        // Check if the lead record has a corresponding case in the map
        if (!contactLeadCaseMap.containsKey(leadRecord.Id)) {
            return; // Exit the method if no corresponding case found
        }
        
        // Retrieve the case associated with the lead record
        Case leadCase = contactLeadCaseMap.get(leadRecord.Id);
        // Extract email and mobile locale information from the case
        String caseEmail = leadCase.SuppliedEmail;
        String webMobileLocale = leadCase.Web_Mobile_Locale__c;
        String webMobileNoLocale = leadCase.Web_Mobile_No_Locale__c;
        
        // Check if the primary email of the lead is empty and if the case email is not empty
        boolean isPrimaryEmailEmpty = String.isEmpty(leadRecord.Email) && String.isNotEmpty(caseEmail);
        // Check if the Web Mobile Locale field associated with the case is not empty and the lead's mobile phone is empty
        boolean isWebMobileLocaleNotEmpty = String.isEmpty(leadRecord.MobilePhone) && String.isNotEmpty(webMobileLocale);
        // Check if the Web Mobile No Locale field associated with the case is not empty and the lead's mobile phone is empty
        boolean isWebMobileNoLocaleNotEmpty = String.isEmpty(leadRecord.MobilePhone) && String.isNotEmpty(webMobileNoLocale);
        
        // Check if the email-case mapping is valid by evaluating the validity of work email
        boolean isEmailCaseMappingValid = isPrimaryEmailEmpty && leadRecord.Work_Email__c != caseEmail;
        
        // Perform updates if the email-case mapping is valid or if Web Mobile Locale or Web Mobile No Locale fields are not empty
        if (isEmailCaseMappingValid || isWebMobileLocaleNotEmpty || isWebMobileNoLocaleNotEmpty) {
            // Create a new Lead object with updated fields
            Lead updatedLead = new Lead(
                Id = leadRecord.Id,
                Email = isEmailCaseMappingValid ? caseEmail : leadRecord.Email,
                LeadMobile_Locale__c = isWebMobileLocaleNotEmpty ? webMobileLocale : leadRecord.LeadMobile_Locale__c,
                Mobile_No_Locale__c = isWebMobileNoLocaleNotEmpty ? webMobileNoLocale : leadRecord.Mobile_No_Locale__c
            );
            
            // Check if the lead Id already exists in the map of lead to update
            if (leadsToUpdateMap.containsKey(leadRecord.Id)) {
                // Update the existing lead with the updated fields
                Lead existingLead = leadsToUpdateMap.get(leadRecord.Id);
                existingLead.Email = updatedLead.Email;
                existingLead.LeadMobile_Locale__c = updatedLead.LeadMobile_Locale__c;
                existingLead.Mobile_No_Locale__c = updatedLead.Mobile_No_Locale__c;
            } else {
                // Add the updated lead to the map of leads to update
                leadsToUpdateMap.put(leadRecord.Id, updatedLead);
            }
        }
    }
                                                                       
}