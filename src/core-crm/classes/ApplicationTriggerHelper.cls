/**
 * @description helper class for ApplicationTriggerHelperHandler
 * @see ApplicationTriggerHelperHandler
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | mark.j.mahilum                 | July 12, 2023         | DEPP-5799              | Created file                                                   |
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added new method to set Can Nurture flag                       |
      | alexander.cadalin              | Aug 16, 2023          | DEPP-6124              | Refactor to consider multiple field updates                    |
      | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6455              | Updated getContactOnApplication to get the old Contact Id      |
      | julie.jane.alegre              | September 19, 2023    | DEPP-6667              | Added new method updateContactWhenQTACAppIsInactive            |
      | alexander.cadalin              | Sep. 22, 2023         | DEPP-6652,6653,6654    | Added methods for contact field updates on match to application|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added method to reset lead score of linked contact/lead        |
      | mark.j.mahilum                 | Oct 19, 2023          | DEPP-6933              | Added logic in handling bulkAPI data when running queable job  |
 */
public with sharing class ApplicationTriggerHelper {
    /**
     * @description If a QTAC application has an applicant, creates or updates addresses for the applicant record
     * @param Map<Id, SObject> newItems - An application id to new/updated application record map
     * @param Map<Id, SObject> oldItems - An application id to replaced application record map
     */
    public static void createAddressesForMatchingQTACApplicant(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, hed__Application__c> qtacApplicationsMap = new Map<Id, hed__Application__c>();
        Set<Id> qtacApplicantIdSet = new Set<Id>();
        for(hed__Application__c application : (List<hed__Application__c>) newItems.values()) {
            if(ApplicationService.isContactMatchedQTACApplication(application, oldItems)) {
                qtacApplicationsMap.put(application.Id, application);
                qtacApplicantIdSet.add(application.hed__Applicant__c);
            }
        }
        if(qtacApplicationsMap.keySet().isEmpty()) { return; } // if no valid application, stop here.

        Map<Id, Contact> contactsMap = new Map<Id, Contact>(
            ContactsDAO.newInstance().getContactsForQTACAddressUpdate(qtacApplicantIdSet, AccessLevel.SYSTEM_MODE)
        );

        Map<String, hed__Address__c> contactTypeToAddressMap = new Map<String, hed__Address__c>();

        processAddresses(qtacApplicationsMap, contactsMap, contactTypeToAddressMap);
        
        if(!contactTypeToAddressMap.keySet().isEmpty()) {
            AddressesDAO.newInstance().upsertRecords(contactTypeToAddressMap.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }
    
    private static void processAddresses(
        Map<Id, hed__Application__c> qtacApplicationsMap,
        Map<Id, Contact> contactsMap,
        Map<String, hed__Address__c> contactTypeToAddressMap
    ) {
        for(hed__Application__c application : qtacApplicationsMap.values()) {
            Boolean hasMailing = false;
            Boolean hasOther = false;
            Contact applicant = (Contact) contactsMap.get(application.hed__Applicant__c);
            for(hed__Address__c address : applicant.hed__Addresses__r) {
                address = ApplicationService.fillAddressLines(address, application, address.hed__Address_Type__c);
                switch on address.hed__Address_Type__c {
                    when 'Mailing' { 
                        hasMailing = true; 
                    }
                    when 'Other' { 
                        hasOther = true; 
                    }
                }
                contactTypeToAddressMap.put((String) applicant.Id + address.hed__Address_Type__c, address);
            }
            if(!hasMailing) {
                contactTypeToAddressMap.put(
                    (String) applicant.Id + 'Mailing',
                    ApplicationService.fillAddressLines(new hed__Address__c(), application, 'Mailing')
                );
            }
            if(!hasOther) {
                contactTypeToAddressMap.put(
                    (String) applicant.Id + 'Other',
                    ApplicationService.fillAddressLines(new hed__Address__c(), application, 'Other')
                );
            }
        }
    }

    /**
     * @description Perform field updates on related records of the applications
     * @param Map<Id, SObject> newItems - An application id to new/updated application record map
     * @param Map<Id, SObject> oldItems - An application id to replaced application record map
     */
    public static void updateRelatedRecords(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // update/upsert maps/list
        Map<Id, Contact> contactMapToUpdate = new Map<Id, Contact>();
        // related maps
        Map<Id, Contact> relatedContactMap = new Map<Id, Contact>(ApplicationService.getApplicantsFromApplications((List<hed__Application__c>) newItems.values()));
        // process
        for(hed__Application__c application : (List<hed__Application__c>) newItems.values()) {
            if(application.hed__Applicant__c != null){
                // initial steps...
                Contact applicant = ApplicationService.getContactFromUpdateMap(contactMapToUpdate, application.hed__Applicant__c);
                ApplicationService.RecordsToReferenceWrapper recordsToReference = new ApplicationService.RecordsToReferenceWrapper();
                recordsToReference.existingContact = relatedContactMap.get(application.hed__Applicant__c);
                recordsToReference.application = application;
                recordsToReference.oldApplication = oldItems == null ? null : (hed__Application__c) oldItems.get(application.Id);
                // field updates...
                ApplicationService.mapFieldsToApplicant(applicant, recordsToReference.application);
                ApplicationService.switchMapFieldsByRecordType(applicant, recordsToReference);
            }
        }
        // update
        if(!contactMapToUpdate.keySet().isEmpty()) {
            ContactsDAO.newInstance().updateRecords(contactMapToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description reset the lead score of the linked contact/lead
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records 
     */
    public static void resetLeadScore(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems){

        Set<Id> contactLeadIdSet = new Set<Id>();
        for(hed__Application__c app : newItems){
            if(isStudyLinkForScoreReset(app) || isSAMSLegacyForScoreReset(app) || isSAMSCIAnywhereForScoreReset(app)){
                if(app.hed__Applicant__c != null){
                    contactLeadIdSet.add(app.hed__Applicant__c);
                }else if(app.Lead__c != null){
                    contactLeadIdSet.add(app.Lead__c);
                }
            }
        }    

        List<Lead_Score_Detail__c> leadScoreDetails = getLeadScoreDetailsToUpdate(contactLeadIdSet);
        if(!leadScoreDetails.isEmpty()){
            LeadScoreDetailsDAO.newInstance().updateRecords(leadScoreDetails, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * Retrieves the lead score details by contact/lead and sets all categories to 0
     */
    private static List<Lead_Score_Detail__c> getLeadScoreDetailsToUpdate(Set<Id> contactLeadIdSet){
        List<Lead_Score_Detail__c> leadScoreDetailsToUpdate = new List<Lead_Score_Detail__c>();
        if(!contactLeadIdSet.isEmpty()){
            List<Lead_Score_Detail__c> leadScoreDetailsList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(contactLeadIdSet, AccessLevel.SYSTEM_MODE);
            for(Lead_Score_Detail__c detail: leadScoreDetailsList){            
                leadScoreDetailsToUpdate.add(new Lead_Score_Detail__c(
                    Id = detail.Id,
                    Country_Tier__c = 0,
                    Course_Level__c = 0,
                    Download__c = 0,
                    Email_Interaction__c = 0,
                    Enquiries__c = 0,
                    Event_Registration_Attendance__c = 0,
                    Funding__c = 0,
                    Interested_In_Double_Degrees__c = 0,
                    Interested_In_English_Pathway_Programs__c = 0,
                    Manual_Assessment__c = 0,
                    Marketing_Consent__c = 0,
                    Match_My_Skills__c = 0,
                    Preferred_Intake__c = 0,
                    Primary_NSA__c = 0,
                    Primary_BSA__c = 0,
                    Program_Engagement__c = 0,
                    Residence__c = 0
                ));
            }
        }
        
        return leadScoreDetailsToUpdate;
    }

    private static Boolean isStudyLinkForScoreReset(hed__Application__c app){
        return app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID && (app.Application_Status__c == ApplicationsDAO.STATUS_DECLINED_BY_APP || app.Application_Status__c == ApplicationsDAO.STATUS_WITHDRAWN);
    }

    private static Boolean isSAMSLegacyForScoreReset(hed__Application__c app){
        return app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID && (app.Offer_Status__c == ApplicationsDAO.STATUS_DECLINED|| app.Offer_Status__c == ApplicationsDAO.STATUS_WITHDRAWN);
    }

    private static Boolean isSAMSCIAnywhereForScoreReset(hed__Application__c app){
        return app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID && (app.Offer_Status__c == ApplicationsDAO.STATUS_DECLINED || app.Offer_Status__c == ApplicationsDAO.STATUS_WITHDRAWN);
    }

    /**
     * @description get the existing contact in the application record
     *
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     */
    public static void getContactOnApplication(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems, boolean isBulkAPI) {         
        Set<Id> contactIds = new Set<Id>();
        
        for (hed__Application__c app : newItems) {
            
            boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            boolean isValidRecType = isStudylinkRecType || isSAMSRecType || isQTACRecType;
            boolean isCalculatedIntakeDateValid = app.Calculated_Intake_Date__c !=NULL && app.Calculated_Intake_Date__c >= Date.Today();
                         
            if(oldItems == null && String.isNotEmpty(app.hed__Applicant__c) && isValidRecType && isCalculatedIntakeDateValid){
                contactIds.add(app.hed__Applicant__c);
            }
            
            if(oldItems != null) {              
                hed__Application__c oldApp = oldItems.get(app.Id);
                getContactOnApplicationValidation(app,oldApp,contactIds);               
            }         
        }
        
        if(!contactIds.isEmpty()){
            if(!isBulkAPI){
                ContactPersonaFlagsService.processContactIds(contactIds,'updateContactApplicantFlag'); 
            }else{                
                ContactPersonaFlagsService.updateContactApplicantFlag(contactIds);
            }
        }      
    }
    
    /**
     * @description validate application data on trigger update
     *
     * @param app  new hed__Application__c record
     * @param oldApp old hed__Application__c record
     * @param contactIds set of contactIds for processing
     */    
    private static void getContactOnApplicationValidation(hed__Application__c app, hed__Application__c oldApp, Set<Id> contactIds){
        Boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        Boolean isContactChanged = (app.hed__Applicant__c != oldApp.hed__Applicant__c);
        Boolean isStatusChanged = (app.Application_Status__c != oldApp.Application_Status__c);
        Boolean isQTACActive = (app.Is_Active__c != oldApp.Is_Active__c && isQTACRecType);
        Boolean isCalculatedIntakeDateChanged = (app.Calculated_Intake_Date__c != oldApp.Calculated_Intake_Date__c);
        
        if(String.isNotEmpty(oldApp.hed__Applicant__c) && isContactChanged){
            contactIds.add(oldApp.hed__Applicant__c); 
        }  
        
        if((isStatusChanged || isQTACActive || isCalculatedIntakeDateChanged) && String.isNotEmpty(app.hed__Applicant__c)){
            contactIds.add(app.hed__Applicant__c);
        }
    }

    /**
     * @description update the inserted Sams application record
     *
     * @param newItems  List of new hed__Application__c records
     */
    public static void updateCalculatedDateOnSamsApplicationRecords(List<hed__Application__c> newItems) {
        try{
            Set<Id> termsIdInApplication = ApplicationService.getAllTermsIdInApplication(newItems);
            Map<Id,hed__Term__c> termRecords = new Map<Id,hed__Term__c>(TermsDAO.newInstance().getTermRecordByApplication(termsIdInApplication,'SYSTEM_MODE'));

            for (hed__Application__c app : newItems) {
                boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
                    if(isSAMSRecType && termRecords.containsKey(app.Applied_Intake_Study_Period__c)){
                        app.Calculated_Intake_Date__c = termRecords.get(app.Applied_Intake_Study_Period__c).hed__Start_Date__c;
                    }
            }
        } catch (Exception e) {
            Logger.error('Exception caught in method updateCalculatedDateOnSamsApplicationRecords in class ApplicationTriggerHelper.')
              .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * @description Update related Contacts Marketing Preference when QTAC application is inactive 
     * @param newItems
     */
    public static void updateContactWhenQTACAppIsInactive(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems) {
        Set<Id> applicantIds = new Set<Id>();
        for(hed__Application__c app : newItems){
            if(ApplicationService.isInactiveQTACApp(app, oldItems)){
                applicantIds.add(app.hed__Applicant__c);
            }
        }
        List<Contact> contactsToUpdate = ApplicationService.mapContactToUpdate(applicantIds);
        if(!contactsToUpdate.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contactsToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }
}