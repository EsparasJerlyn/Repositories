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
      | roy.nino.s.regala              | Nov 03, 2023          | DEPP-7145              | Moved reusable methods for Lead Score Reset Logic              |
      | sebastianne.k.trias            | June 1, 2024          | DEPP-8474              | Removed modify Opt in/out fields                               |
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
        boolean isUpdate = oldItems != null;
        hed__Application__c oldApplication;
        for(hed__Application__c application : (List<hed__Application__c>) newItems.values()) {

            oldApplication = isUpdate?(hed__Application__c) oldItems.get(application.Id):null;
            // evaluate application if address fields are allowed to be mapped
            if(!isMapToContact(application,oldApplication)){
                continue;
            }

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

                // skip process if address type is not other or mailing
                // or address fields for specific type is not populated
                if( !ApplicationsDAO.ADDRESS_FIELDS.containsKey(address.hed__Address_Type__c) || 
                    !ApplicationService.isAddressFieldsPopulated(application, ApplicationsDAO.ADDRESS_FIELDS.get(address.hed__Address_Type__c))){
                    continue;
                }

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
            // added checking to only create address records if application addresses are populated
            if(!hasMailing && ApplicationService.isAddressFieldsPopulated(application, ApplicationsDAO.ADDRESS_FIELDS.get('Mailing'))) {
                contactTypeToAddressMap.put(
                    (String) applicant.Id + 'Mailing',
                    ApplicationService.fillAddressLines(new hed__Address__c(), application, 'Mailing')
                );
            }
            // added checking to only create address records if application addresses are populated
            if(!hasOther && ApplicationService.isAddressFieldsPopulated(application, ApplicationsDAO.ADDRESS_FIELDS.get('Other'))){
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
        hed__Application__c oldApplication;
        boolean isUpdate = oldItems != null;
        for(hed__Application__c application : (List<hed__Application__c>) newItems.values()) {
            oldApplication = isUpdate?(hed__Application__c) oldItems.get(application.Id):null;
            if(isMapToContact(application,oldApplication)){
                Contact applicant = ApplicationService.getContactFromUpdateMap(contactMapToUpdate, application.hed__Applicant__c);
                ApplicationService.RecordsToReferenceWrapper recordsToReference = new ApplicationService.RecordsToReferenceWrapper();
                recordsToReference.existingContact = relatedContactMap.get(application.hed__Applicant__c);
                recordsToReference.application = application;
                recordsToReference.oldApplication = oldApplication;
                ApplicationService.mappedApplicationToContact(applicant, recordsToReference);
            }
        }
        // update
        if(!contactMapToUpdate.keySet().isEmpty()) {
            ContactsDAO.newInstance().updateRecords(contactMapToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * Determines if the application should be mapped to a contact.
     *
     * @param application The current application being processed.
     * @param oldApplication The previous version of the application (if it exists).
     * @return true if the application should be mapped to a contact, false otherwise.
     */
    private static boolean isMapToContact(
        hed__Application__c application,
        hed__Application__c oldApplication
    ) {
        // Check if there is an old application, indicating an update
        boolean isUpdate = oldApplication != null;

        // Check if the application is of SAMS record type
        boolean isSAMSRecType = (application.RecordTypeId ==
        ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
        application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);

        // Check if the application is of QTAC record type
        boolean isQTACRecType = application.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;

        // Determine if the application is a non-study link type (QTAC or SAMS)
        boolean isNonStudyLink = isQTACRecType || isSAMSRecType;

        // Check if the application is of StudyLink record type
        boolean isStudylink = application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;

        // Determine if updates should be blocked for non-study link applications
        boolean isBlockUpdateForNonStudyLink =
            isUpdate &&
            isNonStudyLink &&
            oldApplication.Offer_Status__c != null;

        // Determine if updates should be blocked for study link applications
        boolean isBlockUpdateForStudyLink =
            isUpdate &&
            isStudylink &&
            ApplicationsDAO.CONTACT_UPDATE_BLOCK_STUDYLINK_STATUS.contains(
                oldApplication.Application_Status__c
            );

        // Combine the conditions for blocking updates from non-study link and study link applications
        boolean isBlockUpdate = isBlockUpdateForNonStudyLink || isBlockUpdateForStudyLink;

        // Check if the applicant has been updated
        boolean isApplicantUpdated =
            isUpdate && oldApplication.hed__Applicant__c != application.hed__Applicant__c;

        // Determine if the application should be mapped to a contact
        return application.hed__Applicant__c != null && (!isBlockUpdate || isApplicantUpdated);
    }


    /**
     * @description reset the lead score of the linked contact/lead
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records 
     */
    public static void resetLeadScore(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems){

        Set<Id> contactLeadIdSet = new Set<Id>();
        for(hed__Application__c app : newItems){
            if(isStudyLinkForScoreReset(app,oldItems) || isSAMSLegacyForScoreReset(app,oldItems) || isSAMSCIAnywhereForScoreReset(app,oldItems)){
                if(app.hed__Applicant__c != null){
                    contactLeadIdSet.add(app.hed__Applicant__c);
                }else if(app.Lead__c != null){
                    contactLeadIdSet.add(app.Lead__c);
                }
            }
        }    

        if(!contactLeadIdSet.isEmpty()){
            Boolean isAsyncProcess = System.isQueueable() || System.isFuture() || System.isBatch();
            if(isAsyncProcess){
                LeadScoreService.updateLeadScoreRelatedRecords(contactLeadIdSet);    
            }else{      
                QueueableCall executeQueueable = new QueueableCall(contactLeadIdSet);
                System.enqueueJob(executeQueueable);   
            }            
        }   
    }

    private static Boolean isStudyLinkForScoreReset(
        hed__Application__c app,
        Map<Id, hed__Application__c> oldItems
    ) {
        //only reset lead score for Study link
        //if application status is updated to
        //Declined by applicant or Withdrawn
        return app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
            app.Application_Status__c != oldItems.get(app.Id).Application_Status__c &&
            (app.Application_Status__c == ApplicationsDAO.STATUS_DECLINED_BY_APP ||
            app.Application_Status__c == ApplicationsDAO.STATUS_WITHDRAWN);
    }

    private static Boolean isSAMSLegacyForScoreReset(
        hed__Application__c app,
        Map<Id, hed__Application__c> oldItems
    ) {
        //only reset lead score for SAMS
        //if offer status is updated to
        //Declined or Withdrawn
        return app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID &&
            app.Offer_Status__c != oldItems.get(app.Id).Offer_Status__c &&
            (app.Offer_Status__c == ApplicationsDAO.STATUS_DECLINED ||
            app.Offer_Status__c == ApplicationsDAO.STATUS_WITHDRAWN);
    }

    private static Boolean isSAMSCIAnywhereForScoreReset(
        hed__Application__c app,
        Map<Id, hed__Application__c> oldItems
    ) {
        //only reset lead score for SAMS
        //if offer status is updated to
        //Declined or Withdrawn
        return app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID &&
            app.Offer_Status__c != oldItems.get(app.Id).Offer_Status__c &&
            (app.Offer_Status__c == ApplicationsDAO.STATUS_DECLINED ||
            app.Offer_Status__c == ApplicationsDAO.STATUS_WITHDRAWN);
    }

    /**
     * @description get the existing contact in the application record
     *
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     */
    public static void getContactOnApplication(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems) {         
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
            Boolean isAsync = System.isBatch() || System.isFuture() || System.isScheduled() || System.isQueueable();          
            if(isAsync){
                ContactPersonaFlagsService.updateContactApplicantFlag(contactIds);               
            }else{                
                ContactPersonaFlagsService.processContactIds(contactIds,'updateContactApplicantFlag'); 
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
        Boolean isCalculatedIntakeDateValid = app.Calculated_Intake_Date__c !=NULL;
        
        if(String.isNotEmpty(oldApp.hed__Applicant__c) && isContactChanged){
            contactIds.add(oldApp.hed__Applicant__c); 
        }  
        
        if((isStatusChanged || isQTACActive || isCalculatedIntakeDateValid) && String.isNotEmpty(app.hed__Applicant__c)){
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
    
    private class QueueableCall implements Queueable {
        private Set<Id> contactLeadIdSet;

        public QueueableCall(Set<Id> contactLeadIdSet) {
            this.contactLeadIdSet = contactLeadIdSet;
        }
        public void execute(QueueableContext context) {
            LeadScoreService.updateLeadScoreRelatedRecords(contactLeadIdSet);
        }
    }
}