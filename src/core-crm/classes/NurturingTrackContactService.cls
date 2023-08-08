/**
 * @description helper class for NurturingTrackContactService
 * @see NurturingTrackContactBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                     |
 */
public with sharing class NurturingTrackContactService {
    private static List<hed__Application__c> applicationList;
    private static Map<Id,hed__Application__c>  samsAppWithQtac = new Map<Id,hed__Application__c>();
    private static Map<String,String> appToQtacMap = new Map<String,String>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackWithOffSetDaysMap = new Map<String,Nurture_Track_Configuration__c>();
    private static List<Case> caseList;
    private static Map<Id, Contact> domesticEntryContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> domesticExitContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> internationalEntryContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> internationalExitContactMap = new Map<Id, Contact>();
    private static final String DOMESTIC_ACCEPTANCE_TO_ENROLLMENT = 'DomesticAcceptanceToEnrollment';
    private static final String INTERNATIONAL_DIRECT_APPLICANT = 'InternationalDirectApplicants';
    private static final String DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE = 'DomesticDeferredOfferToAcceptance';
    private static final Map<String, Date> CURRENT_INTAKE_PERIOD = NurturingTrackService.getCurrentIntakePeriod();
    private static final Map<String, Nurture_Track_Configuration__c> nurturingTrackMap = NurturingTrackService.getNurturingTrackRecords();

    /**
     * @description: process All contacts for Entry and Exit in Cadences assignment
     *
     * @param void
     */
    public static List<Contact> processContactForEntryAndExit(Map<Id, Contact> contactMap) {
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();

        //query all the related records required for each entry/exit criteria
        getAllRelatedRecords(contactMap);

        //CALL YOUR ENTRY AND EXIT METHOD HERE PASS ONLY THE

        //Contact entry criteria to process //SAMPLE METHOD ONLY
        contactToUpdate.putall(getEntryInternationalDirectApplicants(internationalEntryContactMap));
        contactToUpdate.putall(getEntryInternationalAcceptanceDepositNotPaid(internationalEntryContactMap));
        contactToUpdate.putAll(getDomesticAcceptanceToEnrollmentForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getDomesticDeferredOfferToAcceptanceForEntry(domesticEntryContactMap));
        contactToUpdate.putall(getEntryDomesticFirstOffertoAcceptance(domesticEntryContactMap));

        //Contact exit criteria to //SAMPLE METHOD ONLY
        contactToUpdate.putAll(getExitInternationalDirectApplicants(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalAcceptanceDepositNotPaid(internationalExitContactMap));
        contactToUpdate.putAll(getDomesticAcceptanceToEnrollmentForExit(domesticExitContactMap));
        contactToUpdate.putAll(getDomesticDeferredOfferToAcceptanceForExit(domesticExitContactMap));
        contactToUpdate.putAll(getExitDomesticFirstOffertoAcceptance(domesticExitContactMap));

        return contactToUpdate.values();
    }

    /**
     * @description: Query all the required records needed for each entry and exit criteria
     *
     * @param Map<Id,Contact> mapOfContacts record to query
     */
    private static void getAllRelatedRecords(Map<Id, Contact> mapOfContacts) {
        applicationList = ApplicationsDAO.newInstance().getApplicationsByContactIds(mapOfContacts.keySet(),'USER_MODE');
        getContactRecordCitizenship(mapOfContacts);
        getNurturingTrackRecords();
    }

    /**
     * @description: separate the contact for international or domestic
     *
     * @param Map<Id,Contact> mapOfContacts
     */
    private static void getContactRecordCitizenship(Map<Id, Contact> mapOfContacts) {
        for (Id key : mapOfContacts.KeySet()) {
            Contact con = mapOfContacts.get(key);
            Boolean isContactDomestic = (con.hed__Citizenship_Status__c == 'Domestic');

            if (String.isEmpty(con.Calculated_Cadence__c)) {
                if (isContactDomestic) {
                    domesticEntryContactMap.put(key, con);
                } else {
                    internationalEntryContactMap.put(key, con);
                }
            } else {
                if (isContactDomestic) {
                    domesticExitContactMap.put(key, con);
                } else {
                    internationalExitContactMap.put(key, con);
                }
            }
        }
    }

    /**
     * @description Update international direct applicant contacts based on entry criteria
     * @param Map<Id, Contact> internationEntryContactMap a map of ids to entry international contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryInternationalDirectApplicants(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Map<Id, hed__Application__c> internationalDirectApplicants = new Map<Id, hed__Application__c>();
        Set<String> newOrUnsubmittedStatus = new Set<String>{ 'New', 'Unsubmitted' };
        for (hed__Application__c application : applicationList) {
            if (
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                newOrUnsubmittedStatus.contains(application.Application_Status__c) &&
                NurturingTrackService.isDateWithinRange(
                    application.Applied_Intake_Study_Period__r.hed__Start_Date__c,
                    CURRENT_INTAKE_PERIOD.get('START_DATE'),
                    CURRENT_INTAKE_PERIOD.get('END_DATE')
                ) &&
                application.Is_Agent_Assisted__c == false
            ) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                'International Application Submission - Direct Applicant',
                'International Application Submission - Direct Applicant (Automated)'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), 
                                                                                                        'International Application Submission - Direct Applicant (Automated)',
                                                                                                        'International Application Submission - Direct Applicant');

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceMultiple(
            applicationIdsWithCompletedCadence,
            internationalDirectApplicants.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
    * @description Update international direct applicant contacts based on entry criteria
    * @param Map<Id, Contact> internationEntryContactMap a map of ids to entry international contact records
    * @return Map<Id, Contact> map of id to updated contact records for batch processing
    */
    private static Map<Id, Contact> getEntryInternationalAcceptanceDepositNotPaid(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Map<Id, hed__Application__c> internationalDirectApplicants = new Map<Id, hed__Application__c>();

        for (hed__Application__c application : applicationList) {
            if (
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Is_Agent_Assisted__c  == false &&
                application.Application_Status__c == 'Acceptance - Pending Payment' &&
                NurturingTrackService.isDateWithinRange(
                    application.Applied_Intake_Study_Period__r.hed__Start_Date__c,
                    CURRENT_INTAKE_PERIOD.get('START_DATE'),
                    CURRENT_INTAKE_PERIOD.get('END_DATE')
                )
            ) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                'International Acceptance Deposit not Paid'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            'International Acceptance Deposit not Paid'
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            internationalDirectApplicants.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
      * @description: Check if the contact is for Entry Domestic Acceptance To Enrollment cadences
      *
      * @param Map<Id,Contact> mapOfContacts record to evaluate
      * @return Map<Id,Contact> of domestic acceptance contact
      */    
      public static Map<Id,Contact> getDomesticAcceptanceToEnrollmentForEntry(Map<Id,Contact> domesticEntryContactMap) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentAutomated = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentManual = new Map<Id, hed__Application__c>();
        Set<Id> existingContactIdOnApplication = getDomesticAcceptanceToEnrollmentEntryFilter(applicationList,'DomesticAcceptanceToEnrollment');
        Set<Id> existingContactIdOnAppWithProgram = getContactOnApplicationWithProgramPlan(applicationList,'Domestic Acceptance to Enrolment');
        
        for (hed__Application__c application : applicationList) {
            Boolean hasExistingApplication = existingContactIdOnApplication.contains(application.hed__Applicant__c);
            Boolean hasExistingApplicationWithProgram = existingContactIdOnAppWithProgram.contains(application.hed__Applicant__c);
            if (domesticEntryContactMap.containsKey(application.hed__Applicant__c) && hasExistingApplication && hasExistingApplicationWithProgram) {
                domesticAcceptanceToEnrollmentManual.put(application.Id, application);
            }
            else if (domesticEntryContactMap.containsKey(application.hed__Applicant__c) && hasExistingApplication && !hasExistingApplicationWithProgram) {
                domesticAcceptanceToEnrollmentAutomated.put(application.Id, application);
            }
        }

        getCompletedCadenceForDomesticAcceptanceToEnrollmentAutomated(domesticEntryContactMap, domesticAcceptanceToEnrollmentAutomated, contactToUpdateMap);
        getCompletedCadenceForDomesticAcceptanceToEnrollmentManual(domesticEntryContactMap, domesticAcceptanceToEnrollmentManual, contactToUpdateMap);

        return contactToUpdateMap;
    }

    /**
     * @description: Check if the contact is for Entry of Domestic Deferred Offer to Acceptance cadences
     *
     * @param Map<Id,Contact> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance contact
     */    
    public static Map<Id,Contact> getDomesticDeferredOfferToAcceptanceForEntry(Map<Id,Contact> domesticEntryContactMap) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> DomesticDeferredOfferToAcceptanceManual = new Map<Id, hed__Application__c>();
        Set<Id> existingContactIdOnApplication = getContactOnApplicationForDomesticDeferredOfferToAcceptanceEntryFilter(applicationList,'DomesticDeferredOfferToAcceptance');
        for (hed__Application__c application : applicationList) {
            Boolean hasExistingApplication = existingContactIdOnApplication.contains(application.hed__Applicant__c);
            if (domesticEntryContactMap.containsKey(application.hed__Applicant__c) && hasExistingApplication) {
                DomesticDeferredOfferToAcceptanceManual.put(application.Id, application);
            }
        }
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{
                'Domestic Deferred Offer to Acceptance'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), null,
                                                                                                        'Domestic Deferred Offer to Acceptance');

        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            DomesticDeferredOfferToAcceptanceManual.values(),
            cadenceWrapper
        );
        if(!contactToUpdateListManual.isEmpty()){
            contactToUpdateMap.putAll(contactToUpdateListManual);
        }

        return contactToUpdateMap;
    }  

    /**
     * @description Update international direct applicant contacts based on exit criteria
     * @param Map<Id, Contact> internationalExitContactMap
     * @return Map<Id, Contact> map of id to contact for batch processing
     */
    private static Map<Id, Contact> getExitInternationalDirectApplicants(
        Map<Id, Contact> internationalExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        for (hed__Application__c application : applicationList) {
            if (
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Application_Status__c == 'Submitted'
            ) {
                contactsForUpdatingMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsForUpdatingMap;
    }

    /**
     * @description: Check if the contact is for Exit of Domestic Acceptance To Enrollment cadences
     *
     * @param Map<Id,Contact> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance contact
     */    
    public static Map<Id,Contact> getDomesticAcceptanceToEnrollmentForExit(Map<Id,Contact> domesticExitContactMap) {
        Map<Id,Contact> contactsForUpdatingMap = new Map<Id,Contact>();     
        Set<Id> existingContactIdOnApplicationToExit = getDomesticAcceptanceToEnrollmentExitFilter(applicationList,'DomesticAcceptanceToEnrollment');
        for(Id contactId: domesticExitContactMap.keySet()){
           Boolean hasExistingApplicationToExit = existingContactIdOnApplicationToExit.contains(contactId);
           if(hasExistingApplicationToExit){
                contactsForUpdatingMap.put(
                   contactId,
                   new Contact(
                           id = contactId,
                           Calculated_Cadence__c = ''
                       )
                   );
           }
         }
         return contactsForUpdatingMap;
     }

     /**
     * @description: Check if the contact is for Exit of Domestic Deferred Offer to Acceptance cadences
     *
     * @param Map<Id,Contact> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance contact
     */    
    public static Map<Id,Contact> getDomesticDeferredOfferToAcceptanceForExit(Map<Id,Contact> domesticExitContactMap) {
        Map<Id,Contact> contactsForUpdatingMap = new Map<Id,Contact>();     
        Set<Id> existingContactIdOnApplicationToExit = getDomesticDeferredOfferToAcceptanceExitFilter(applicationList,'DomesticDeferredOfferToAcceptance');
        /* Set<Id> existingContactOnCompletedCadence = getCompletedCadenceRecord(mapOfContacts.keySet()); */
        for(Id contactId: domesticExitContactMap.keySet()){
          Boolean hasExistingApplicationToExit = existingContactIdOnApplicationToExit.contains(contactId);
          if(hasExistingApplicationToExit){                       
                contactsForUpdatingMap.put(
                  contactId,
                  new Contact(
                          id = contactId,
                          Calculated_Cadence__c = ''
                      )
                  );
          }
        }
        return contactsForUpdatingMap;
    }

    /**
     * @description Update international direct applicant contacts based on exit criteria
     * @param Map<Id, Contact> internationalExitContactMap
     * @return Map<Id, Contact> map of id to contact for batch processing
     */
    private static Map<Id, Contact> getExitInternationalAcceptanceDepositNotPaid(
        Map<Id, Contact> internationalExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        Set<String> stydyLinkApplicationStatus = new Set<String>{ 'Accepted', 'Accepted -  Deferral', 'Withdrawn'};

        for (hed__Application__c application : applicationList) {
            if (
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                stydyLinkApplicationStatus.contains(application.Application_Status__c)
            ) {
                contactsForUpdatingMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsForUpdatingMap;
    }

    /**
     * @description: Checks existing application records of the contact for entry
     *
     * @param List<hed__Application__c> List of Application record to evaluate
     * @param String Name of the cadence
     * @return Set<Id> contactIds
     */
    private static Set<Id> getDomesticAcceptanceToEnrollmentEntryFilter(List<hed__Application__c> applicationList,String methodName) {
        Set<Id> contactHasApplicationForEntry = new Set<Id>();
        samsApplicationWithQtacApplicantIdChecking(applicationList);
        for(hed__Application__c app: applicationList){            
             
            processDomesticAcceptanceToEnrollmentEntryCriteria(app, methodName, contactHasApplicationForEntry);
        }
        
        return contactHasApplicationForEntry;
    }

    /**
     * @description: Checks existing application records of the contact for entry
     *
     * @param List<hed__Application__c> List of Application record to evaluate
     * @param String Name of the cadence
     * @return Set<Id> contactIds
     */
    private static Set<Id> getContactOnApplicationForDomesticDeferredOfferToAcceptanceEntryFilter(List<hed__Application__c> applicationList,String methodName) {
        Set<Id> contactHasApplicationForEntry = new Set<Id>();
        for(hed__Application__c app: applicationList){            
             
            processDomesticDeferredOfferToAcceptanceEntryCriteria(app, methodName, contactHasApplicationForEntry);
        }
        
        return contactHasApplicationForEntry;
    }

    /**
     * @description: Checks existing application records of the contact for exit
     *
     * @param List<hed__Application__c> List of Application record to evaluate
     * @param String Name of the cadence
     * @return Set<Id> contactIds
     */
    private static Set<Id> getDomesticAcceptanceToEnrollmentExitFilter(List<hed__Application__c> applicationList,String methodName) {
        Set<Id> contactHasApplicationForExit = new Set<Id>();            
        for(hed__Application__c app: applicationList){            
           processDomesticAcceptanceToEnrollmentExitCriteria(app, methodName, contactHasApplicationForExit);
        }
        
        return contactHasApplicationForExit;
    }

    /**
     * @description: Checks existing application records of the contact for exit
     *
     * @param List<hed__Application__c> List of Application record to evaluate
     * @param String Name of the cadence
     * @return Set<Id> contactIds
     */
    private static Set<Id> getDomesticDeferredOfferToAcceptanceExitFilter(List<hed__Application__c> applicationList,String methodName) {
        Set<Id> contactHasApplicationForExit = new Set<Id>();            
        for(hed__Application__c app: applicationList){            
           processDomesticDeferredOfferToAcceptanceExitCriteria(app, methodName, contactHasApplicationForExit);
        }
        
        return contactHasApplicationForExit;
    }


    private static void processDomesticAcceptanceToEnrollmentEntryCriteria(hed__Application__c app,String methodName,Set<Id> contactHasApplicationForEntry){
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID; 
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID; 
        if(methodName == DOMESTIC_ACCEPTANCE_TO_ENROLLMENT){
            if((isSAMSLegacyRecType || isSAMSCiRecType) &&
                app.Application_Status__c != 'Admitted' &&
                app.QTAC_ApplicantID__c!=null && 
                appToQtacMap.containsKey(app.Id) &&
                samsAppWithQtac.containsKey(appToQtacMap.get(app.Id)) &&
                samsAppWithQtac.get(appToQtacMap.get(app.Id)).Offer_Status__c == 'Accepted unconditionally'
                ){
                    contactHasApplicationForEntry.add(app.hed__Applicant__c);       
            }
        }
    }

    private static void processDomesticDeferredOfferToAcceptanceEntryCriteria(hed__Application__c app,String methodName,Set<Id> contactHasApplicationForEntry){
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID; 
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        if( methodName == DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE){
            if((isSAMSLegacyRecType || isSAMSCiRecType) &&
                (app.Admission_Process__c == 'RTN_DEFER' || app.Admission_Process__c == 'RTN_QTAC') && 
                app.Offer_Status__c == 'Offered' && 
                app.Offered_Program_Plan__r.Availability_Start_Date__c.addDays(-21) <= System.today() &&
                app.Offered_Program_Plan__r.Availability_Start_Date__c >= System.today() 
                ){
                    contactHasApplicationForEntry.add(app.hed__Applicant__c);
            }
        }
    }

    private static void processDomesticAcceptanceToEnrollmentExitCriteria(hed__Application__c app,String methodName,Set<Id> contactHasApplicationForExit){
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID; 
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID; 
        if(methodName == DOMESTIC_ACCEPTANCE_TO_ENROLLMENT){
            if((isSAMSLegacyRecType || isSAMSCiRecType) && 
                (app.Application_Status__c == 'Admitted' || 
                app.Application_Status__c == 'Withdrawn' || 
                app.Offer_Status__c == 'Deffered')){
                    contactHasApplicationForExit.add(app.hed__Applicant__c);
              }
        }
    }

    private static void processDomesticDeferredOfferToAcceptanceExitCriteria(hed__Application__c app,String methodName,Set<Id> contactHasApplicationForExit){
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID; 
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        if( methodName == DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE){
            if((isSAMSLegacyRecType || isSAMSCiRecType) && 
                (app.Offer_Status__c == 'Accepted' || 
                app.Offer_Status__c == 'Declined'  || 
                app.Offer_Status__c == 'Rescinded' || 
                app.Offer_Status__c == 'Unoffered')){
                    contactHasApplicationForExit.add(app.hed__Applicant__c);
              }
        }
    }

    private static void samsApplicationWithQtacApplicantIdChecking(List<hed__Application__c> applicationList) {
     
        for(hed__Application__c application : applicationList){
           if(application.QTAC_ApplicantID__c != null){
               appToQtacMap.put(application.Id,application.QTAC_ApplicantID__c);
           }
        }
        samsAppWithQtac = new Map<Id,hed__Application__c>(ApplicationsDAO.newInstance().getQtacApplicationsWithQtacApplicantId(appToQtacMap.values(),'SYSTEM_MODE'));
     }

     /**
    * @description: Get the nurturing Track Records and set the key to Cadence Name
    *
    */
    private static void getNurturingTrackRecords() {               
        
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrack(NurtureTrackConfigurationsDAO.NURTURE_FIELDS,'SYSTEM_MODE');
        for(Nurture_Track_Configuration__c nurture: nurtureList){
            if(nurture.Key_Date_Offset_Days__c != null && nurture.Criteria_Type__c == 'Entry'){
                nurturingTrackWithOffSetDaysMap.put(nurture.Cadence_Name__c,nurture);
            }
        }     
    }

    /**
     * @description: Checks existing completed cadence records of the contact
     *
     * @param List<hed__Application__c> application records to evaluate
     * @param String cadence name to evaluate
     */
    private static  Set<Id> getContactOnApplicationWithProgramPlan(List<hed__Application__c> applications, String cadenceName) {
        Set<Id> contactIds = new Set<Id>();
        for(hed__Application__c app : applications){
           if(cadenceName == 'Domestic Acceptance to Enrolment'){
             if(app.Offered_Program_Plan__c != null && 
                   nurturingTrackWithOffSetDaysMap.get('Domestic Acceptance to Enrolment')?.Key_Date_Offset_Days__c !=null &&
                   app.Offered_Program_Plan__r.Availability_Start_Date__c.addDays(-(Integer)nurturingTrackWithOffSetDaysMap.get('Domestic Acceptance to Enrolment')?.Key_Date_Offset_Days__c) <= System.today() &&
                   app.Offered_Program_Plan__r.Availability_Start_Date__c >= System.today()){
                       contactIds.add(app.hed__Applicant__c);
             }
           }
        }
        return contactIds;
    }

    /**
     * @description: Checks existing completed cadence records of the contact
     *
     * @param Set<Id> contactIds to evaluate
     */
    private static Set<Id> getCompletedCadenceRecord(Set<Id> contactIds,String methodName) {    
        Set<Id> contactIdOfCompletedCadence = new Set<Id>();    
        List<Completed_Cadence__c> compCadenceList = CompletedCadencesDAO.newInstance().getCompletedCadenceByContactIds(contactIds,'SYSTEM_MODE'); 
        for(Completed_Cadence__c comCadence : compCadenceList){
           if(comCadence.Nurture_Track_Configuration__r.Cadence_Name__c == methodName ){
               contactIdOfCompletedCadence.add(comCadence.Contact__c);
           }
        }
        return contactIdOfCompletedCadence;
    }

    private static void getCompletedCadenceForDomesticAcceptanceToEnrollmentAutomated(Map<Id, Contact> domesticEntryContactMap,Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentAutomated,Map<Id, Contact> contactToUpdateMap){
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{
                'Domestic Acceptance to Enrolment (Automated)'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), null,
                                                                                                        'Domestic Acceptance to Enrolment (Automated)');

        List<Contact> contactToUpdateListAutomated = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            domesticAcceptanceToEnrollmentAutomated.values(),
            cadenceWrapper
        );

        if(!contactToUpdateListAutomated.isEmpty()){
            contactToUpdateMap.putAll(contactToUpdateListAutomated);
        }
    }

    private static void getCompletedCadenceForDomesticAcceptanceToEnrollmentManual(Map<Id, Contact> domesticEntryContactMap,Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentManual,Map<Id, Contact> contactToUpdateMap){
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{
                'Domestic Acceptance to Enrolment'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), null,
                                                                                                        'Domestic Acceptance to Enrolment');

        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            domesticAcceptanceToEnrollmentManual.values(),
            cadenceWrapper
        );
        if(!contactToUpdateListManual.isEmpty()){
            contactToUpdateMap.putAll(contactToUpdateListManual);
        }
    }

    /**
     * @description Update domestic direct applicant contacts based on entry criteria
     * @param Map<Id, Contact> domesticEntryContactMap a map of ids to entry domestic contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryDomesticFirstOffertoAcceptance(
        Map<Id, Contact> domesticEntryContactMap
    ) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceManual = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated = new Map<Id, hed__Application__c>();

        // To group Automated and Manual Application
        for (hed__Application__c application : applicationList) {
            boolean isSAMSLegacyRecType = application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                domesticEntryContactMap.containsKey(application.hed__Applicant__c) &&
                application.Offer_Status__c == 'Offer' &&
                application.Admission_Process__c != 'RTN_DEFER/RTN_QTAC'
            ) {
                processCompletedDomesticFirstOffertoAcceptance(application, domesticFirstOffertoAcceptanceManual, domesticFirstOffertoAcceptanceAutomated);
            }
        }

        Map<Id, hed__Application__c> latestApplicationAutomated = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> latestApplicationManual = new Map<Id, hed__Application__c>();

        processLatestApplicationDate(domesticFirstOffertoAcceptanceAutomated, latestApplicationAutomated);
        processLatestApplicationDate(domesticFirstOffertoAcceptanceManual, latestApplicationManual);
        getCompletedDomesticFirstOffertoAcceptanceAutomated(domesticEntryContactMap, latestApplicationAutomated, contactToUpdateMap);
        processRemoveApplicationInLatestApplication(latestApplicationManual, contactToUpdateMap);
        getCompletedDomesticFirstOffertoAcceptanceManual(domesticEntryContactMap, latestApplicationManual, contactToUpdateMap);

        return contactToUpdateMap;
    }

    /**
     * @description Update domestic direct applicant contacts based on exit criteria
     * @param Map<Id, Contact> domesticExitContactMap
     * @return Map<Id, Contact> map of id to contact for batch processing
     */
    private static Map<Id, Contact> getExitDomesticFirstOffertoAcceptance(
        Map<Id, Contact> domesticExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();

        Set<String> offerStatus = new Set<String>{ 'Accepted', 'Declined', 'Deferred', 'Lapsed' };

        for (hed__Application__c application : applicationList) {
            boolean isSAMSLegacyRecType = application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;

            if (
                domesticExitContactMap.containsKey(application.hed__Applicant__c) &&
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                offerStatus.contains(application.Offer_Status__c)
            ) {
                contactsForUpdatingMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsForUpdatingMap;
    }

    /**
     * @description Get only latest application by date Automated
     * @param Map<Id, hed__Application__c> domesticFirstOffertoAcceptance
     * @param Map<Id, hed__Application__c> latestApplicationAutomated
     */
    private static void processLatestApplicationDate(Map<Id, hed__Application__c> domesticFirstOffertoAcceptance, Map<Id, hed__Application__c> latestApplication) {
        Map<Id, hed__Application__c> filterByContactApplication = new Map<Id, hed__Application__c>();

        for (Id applicationId : domesticFirstOffertoAcceptance.keySet()) {
            Id contactId = domesticFirstOffertoAcceptance.get(applicationId).hed__Applicant__c;
            hed__Application__c application = domesticFirstOffertoAcceptance.get(applicationId);

            if (
                !filterByContactApplication.containsKey(contactId) ||
                (
                    filterByContactApplication.containsKey(contactId) &&
                    (application.hed__Application_Date__c > filterByContactApplication.get(contactId).hed__Application_Date__c)
                )
            ) {
                filterByContactApplication.put(contactId, domesticFirstOffertoAcceptance.get(applicationId));
            }
        }

        for (Id contactId : filterByContactApplication.keySet()) {
            hed__Application__c application = filterByContactApplication.get(contactId);
            latestApplication.put(application.Id, application);
        }
    }

    /**
     * @description Check 2 days after offer received for Manual else Automated
     * @param Map<Id, hed__Application__c> application
     * @param Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceManual
     * @param Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated
     */
    private static void processCompletedDomesticFirstOffertoAcceptance(hed__Application__c application, Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceManual,Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated){
        Date currentDate = System.TODAY();

        if (
            currentDate.daysBetween(application.Offer_Start_Date__c) <= 2 &&
            currentDate.daysBetween(application.Offer_Start_Date__c) >= 0
        ) {
            domesticFirstOffertoAcceptanceManual.put(application.Id, application); // Group Manual Application
        } else {
            domesticFirstOffertoAcceptanceAutomated.put(application.Id, application); // Group Automated Application
        }
    }

    /**
     * @description Remove in list manual application if Contact Id is in Automated list insertion
     * @param Map<Id, hed__Application__c> latestApplicationManual
     * @param Map<Id, Contact> contactToUpdateMap
     */
    private static void processRemoveApplicationInLatestApplication(Map<Id, hed__Application__c> latestApplicationManual, Map<Id, Contact> contactToUpdateMap) {
        for (Id applicationId : latestApplicationManual.keySet()) {
            hed__Application__c application = latestApplicationManual.get(applicationId);

            if (contactToUpdateMap.containsKey(application.hed__Applicant__c)) {
                latestApplicationManual.remove(applicationId);
            }
        }
    }

    /**
     * @description Process Automated Application
     * @param Map<Id, Contact> domesticEntryContactMap
     * @param Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated
     * @param Map<Id, Contact> contactToUpdateMap
     */
    private static void getCompletedDomesticFirstOffertoAcceptanceAutomated(Map<Id, Contact> domesticEntryContactMap,Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated,Map<Id, Contact> contactToUpdateMap){
        // Check Contact and Cadence Name if Automated is already Completed
        Map<Id, List<String>> completedAutomatedCadenceByContactId = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{
                'Domestic First Offer to Acceptance (Automated)'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), null,
                                                                                                        'Domestic First Offer to Acceptance (Automated)');

        // Check and Update Contacts Cadence Name
        List<Contact> completedManualCadenceByContactId = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            completedAutomatedCadenceByContactId,
            domesticFirstOffertoAcceptanceAutomated.values(),
            cadenceWrapper
        );

        if(!completedManualCadenceByContactId.isEmpty()){
            contactToUpdateMap.putAll(completedManualCadenceByContactId);
        }
    }

    /**
     * @description Process Manual Application
     * @param Map<Id, Contact> domesticEntryContactMap
     * @param Map<Id, hed__Application__c> latestApplicationManual
     * @param Map<Id, Contact> contactToUpdateMap
     */
    private static void getCompletedDomesticFirstOffertoAcceptanceManual(Map<Id, Contact> domesticEntryContactMap,Map<Id, hed__Application__c> latestApplicationManual,Map<Id, Contact> contactToUpdateMap){
        // Check Contact and Cadence Name if Automated is already Completed
        Map<Id, List<String>> completedAutomatedCadenceByContactId = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{
                'Domestic First Offer to Acceptance (Automated)'
            },
            Contact.getSObjectType()
        );


        Map<Id, hed__Application__c> latesetApplicationForManualCadence = new Map<Id, hed__Application__c>();

        // Get only the contact application that needs to be inserted if Automated is Completed
        for(Id applicationId : latestApplicationManual.keySet()){
            hed__Application__c application = latestApplicationManual.get(applicationId);

            if (completedAutomatedCadenceByContactId.containsKey(application.hed__Applicant__c)) {
                latesetApplicationForManualCadence.put(applicationId, application);
            }
        }

        // Check Contact and Cadence Name if Manual is already Completed
        Map<Id, List<String>> completedManualCadenceByContactId = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{
                'Domestic First Offer to Acceptance'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(),
                                                                                                        '',
                                                                                                        'Domestic First Offer to Acceptance');

        // Check and Update Contacts Cadence Name
        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            completedManualCadenceByContactId,
            latesetApplicationForManualCadence.values(),
            cadenceWrapper
        );

        if(!contactToUpdateListManual.isEmpty()){
            contactToUpdateMap.putAll(contactToUpdateListManual);
        }
    }
}
