/**
 * @description helper class for NurturingTrackContactService 
 * @see NurturingTrackContactBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                                                  |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Added handling for Domestic and International                                 |  
      |                                |                       |                        | Enrolment to Census                                                           | 
      | mark.j.mahilum                 | Sept 07, 2023         | DEPP-6479              | Updated methods to replace the Term Intake to                                 |
      |                                |                       |                        | Calculated Intake Date on application record                                  | 
      | mark.j.mahilum                 | Sept 08, 2023         | DEPP-6479              | Remove CURRENT_INTAKE_PERIOD and NurturingTrackService.isDateWithinRange call |
      |                                |                       |                        | as it's no longer used                                                        |
      | arsenio.jr.dayrit              | September 07, 2023    | DEPP-5652              | Added handling for Domestic Strong Interest Pre-Application                   |
      | mark.j.mahilum                 | Sept 19, 2023         | DEPP-6677              | Updated name of sales cadence from Domestic Acceptance to Enrollment to       |
      |                                |                       |                        | Domestic Accepted not yet Enrolled                                            |
      | arsenio.jr.dayrit              | October 03, 2023      | DEPP-6816              | Added handling for International Offer to Acceptance                          |
      | alexander.cadalin              | Oct 3, 2023           | DEPP-6814              | Fixed case detection logic for international strong interest                  |
      | mark.j.mahilum                 | October 04, 2023      | DEPP-6682              | Added new entry criteria for DomesticAcceptedAdmitted sales cadence           |
      | arsenio.jr.dayrit              | October 04, 2023      | DEPP-6834              | Update handling for Domestic Accepted not yet Enrolled                        |
      | arsenio.jr.dayrit              | October 06, 2023      | DEPP-6853              | Update handling for Domestic Strong Interest Pre Application                  |
      | mark.j.mahilum                 | Oct. 06, 2023         | DEPP-6854              | Updated handing for Domestic International Start Date                         |
      | arsenio.jr.dayrit              | Oct. 12, 2023         | DEPP-6901              | Added international citizenship status handling                               |
      | eccarius.munoz                 | October 16, 2023      | DEPP-6914              | Updated handling for Domestic First Offer (Auto). Changed checking of field   | 
      |                                |                       |                        | Admission process. Should be either RTN_DEFER or RTN_QTAC.                    | 
      | eccarius.munoz                 | October 16, 2023      | DEPP-6914              | Transffered String literals (Domestic First Offer Auto && Census)             | 
      |                                |                       |                        | to NurtureTrackConfigurationsDAO.                                             | 
 */
public with sharing class NurturingTrackContactService { //NOPMD
    private static List<hed__Application__c> applicationList;
    private static Map<Id,hed__Application__c>  samsAppWithQtac = new Map<Id,hed__Application__c>();
    private static Map<String,String> appToQtacMap = new Map<String,String>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackWithOffSetDaysMap = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackForExitWithOffSetDaysMap = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackWithThresholdForEntry = new Map<String,Nurture_Track_Configuration__c>();
    private static List<Case> caseList;
    private static Map<Id, Contact> domesticEntryContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> domesticExitContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> internationalEntryContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> internationalExitContactMap = new Map<Id, Contact>();
    private static final String DOMESTIC_ACCEPTANCE_TO_ENROLLMENT = 'DomesticAcceptanceToEnrollment';
    private static final String INTERNATIONAL_DIRECT_APPLICANT = 'InternationalDirectApplicants';
    private static final String DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE = 'DomesticDeferredOfferToAcceptance';
    private static final String DOMESTIC_OFFER_LAPSED_AUTOMATED = 'Domestic Offer Lapsed (Automated)';
    private static final String DOMESTIC_OFFER_LAPSED_MANUAL = 'Domestic Offer Lapsed';
    private static final Map<String, Date> CURRENT_INTAKE_PERIOD = NurturingTrackService.getCurrentIntakePeriod();

    /**
     * @description: process All contacts for Entry and Exit in Cadences assignment
     *
     * @param Map<Id, Contact> contactMap - contacts to process
     * @return List<Contact> contacts to update
     */
    public static List<Contact> processContactForEntryAndExit(Map<Id, Contact> contactMap) {
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();

        //query all the related records required for each entry/exit criteria
        getAllRelatedRecords(contactMap);

        //CALL YOUR ENTRY AND EXIT METHOD HERE PASS ONLY THE

        /**
         * Arrangement according to DEPP-6061
         *   International Application Submission - Direct Applicant (DEPP-6058)
         *   International Application to Offer (DEPP-5746)
         *   Domestic First Offer to Acceptance (DEPP-5747)
         *   Domestic Deferred Offer to Acceptance (DEPP-5755)
         *   International Offer to Acceptance (DEPP-5756)
         *   International Acceptance Deposit not Paid (DEPP-5757)
         *   Domestic Accepted not yet Enrolled (DEPP-5758)
         *   Domestic and International Enrolment to Census (DEPP-5760)
         *   Domestic Offer Lapsed (DEPP-5761)
         */

        //Contact entry criteria to process
        contactToUpdate.putall(getDomesticStrongInterestPreApplicationForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalStrongInterestPreApplication(internationalEntryContactMap));
        contactToUpdate.putall(getEntryInternationalDirectApplicants(internationalEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalApplicationToOffer(internationalEntryContactMap));
        contactToUpdate.putall(getEntryDomesticFirstOffertoAcceptance(domesticEntryContactMap));
        contactToUpdate.putAll(getDomesticDeferredOfferToAcceptanceForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getInternationalOfferToAcceptanceForEntry(internationalEntryContactMap));
        contactToUpdate.putall(getEntryInternationalAcceptanceDepositNotPaid(internationalEntryContactMap));
        contactToUpdate.putAll(getDomesticAcceptanceToEnrollmentForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getEntryDomesticAcceptedAndAdmitted(domesticEntryContactMap));
        contactToUpdate.putAll(getDomesticEnrollmentToCensusForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getInternationalEnrollmentToCensusForEntry(internationalEntryContactMap));
        contactToUpdate.putall(getEntryDomesticOfferLapsed(domesticEntryContactMap));

        //Contact exit criteria to process
        contactToUpdate.putAll(getDomesticStrongInterestPreApplicationForExit(domesticExitContactMap));
        contactToUpdate.putAll(getExitInternationalStrongInterestPreApplication(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalDirectApplicants(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalApplicationToOffer(internationalExitContactMap));
        contactToUpdate.putAll(getExitDomesticFirstOffertoAcceptance(domesticExitContactMap));
        contactToUpdate.putAll(getDomesticDeferredOfferToAcceptanceForExit(domesticExitContactMap));
        contactToUpdate.putAll(getExitInternationalOffertoAcceptance(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalAcceptanceDepositNotPaid(internationalExitContactMap));
        contactToUpdate.putAll(getDomesticAcceptanceToEnrollmentForExit(domesticExitContactMap));
        contactToUpdate.putAll(getDomesticEnrollmentToCensusForExit(domesticExitContactMap));
        contactToUpdate.putAll(getInternationalEnrollmentToCensusForExit(internationalExitContactMap));
        contactToUpdate.putAll(getExitDomesticOfferLapsed(domesticExitContactMap));
        
        return contactToUpdate.values();
    }

    /**
     * @description: Query all the required records needed for each entry and exit criteria
     *
     * @param Map<Id,Contact> mapOfContacts record to query
     */
    private static void getAllRelatedRecords(Map<Id, Contact> mapOfContacts) {
        applicationList = ApplicationsDAO.newInstance()
            .getApplicationsByContactIds(mapOfContacts.keySet(), 'USER_MODE');
        getContactRecordCitizenship(mapOfContacts);
        getFilteredNurturingTrackRecords();
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
            Boolean isContactInternational = (con.hed__Citizenship_Status__c == 'International');

            if (String.isEmpty(con.Calculated_Cadence__c)) {
                if (isContactDomestic) {
                    domesticEntryContactMap.put(key, con);
                } else if(isContactInternational){
                    internationalEntryContactMap.put(key, con);
                }
            } else {
                if (isContactDomestic) {
                    domesticExitContactMap.put(key, con);
                } else if(isContactInternational){
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
                    application.Calculated_Intake_Date__c,
                    CURRENT_INTAKE_PERIOD.get('START_DATE'),
                    CURRENT_INTAKE_PERIOD.get('END_DATE')
                ) &&
                application.Is_Agent_Assisted__c == false
            ) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                'International Application Submission - Direct Applicant',
                'International Application Submission - Direct Applicant (Automated)'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            'International Application Submission - Direct Applicant (Automated)',
            'International Application Submission - Direct Applicant'
        );

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
                application.Is_Agent_Assisted__c == false &&
                application.Application_Status__c == 'Acceptance - Pending Payment' &&
                NurturingTrackService.isDateWithinRange(
                    application.Calculated_Intake_Date__c,
                    CURRENT_INTAKE_PERIOD.get('START_DATE'),
                    CURRENT_INTAKE_PERIOD.get('END_DATE')
                )
            ) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{ 'International Acceptance Deposit not Paid' },
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
    public static Map<Id, Contact> getDomesticAcceptanceToEnrollmentForEntry(
        Map<Id, Contact> domesticEntryContactMap
    ) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentAutomated = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentManual = new Map<Id, hed__Application__c>();
        Set<Id> existingContactIdOnApplication = getDomesticAcceptanceToEnrollmentEntryFilter(
            applicationList
        );
        Set<Id> existingContactIdOnAppWithProgram = getContactOnApplicationWithProgramPlan(
            applicationList,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL
        );

        Map<Id, List<String>> existingContactOnCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED },
            Contact.getSObjectType()
        );

        for (hed__Application__c application : applicationList) {
            Boolean hasExistingApplication = existingContactIdOnApplication.contains(
                application.hed__Applicant__c
            );
            Boolean hasExistingCompletedCadence = existingContactOnCompletedCadence.containsKey(application.hed__Applicant__c);
            Boolean hasExistingApplicationWithProgram = existingContactIdOnAppWithProgram.contains(
                application.hed__Applicant__c
            );
            Boolean checkForManual = (hasExistingCompletedCadence && hasExistingCompletedCadence);
            if (domesticEntryContactMap.containsKey(application.hed__Applicant__c) 
                    && hasExistingApplication && hasExistingApplicationWithProgram 
                    && hasExistingCompletedCadence ) {
                domesticAcceptanceToEnrollmentManual.put(application.Id, application);
            } else if (domesticEntryContactMap.containsKey(application.hed__Applicant__c) && hasExistingApplication && !checkForManual) {
                domesticAcceptanceToEnrollmentAutomated.put(application.Id, application);
            }
        }

        getCompletedCadenceForDomesticAcceptanceToEnrollmentAutomated(
            domesticEntryContactMap,
            domesticAcceptanceToEnrollmentAutomated,
            contactToUpdateMap
        );
        getCompletedCadenceForDomesticAcceptanceToEnrollmentManual(
            domesticEntryContactMap,
            domesticAcceptanceToEnrollmentManual,
            contactToUpdateMap
        );

        return contactToUpdateMap;
    }

    /**
     * @description: Check if the contact is for Entry of Domestic Deferred Offer to Acceptance cadences
     *
     * @param Map<Id,Contact> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance contact
     */
    public static Map<Id, Contact> getDomesticDeferredOfferToAcceptanceForEntry(
        Map<Id, Contact> domesticEntryContactMap
    ) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> domesticDeferredOfferToAcceptanceManual = new Map<Id, hed__Application__c>();
        Set<Id> existingContactIdOnApplication = getContactOnApplicationForDomesticDeferredOfferToAcceptanceEntryFilter(
            applicationList,
            'DomesticDeferredOfferToAcceptance'
        );
        for (hed__Application__c application : applicationList) {
            Boolean hasExistingApplication = existingContactIdOnApplication.contains(
                application.hed__Applicant__c
            );
            if (
                domesticEntryContactMap.containsKey(application.hed__Applicant__c) &&
                hasExistingApplication
            ) {
                domesticDeferredOfferToAcceptanceManual.put(application.Id, application);
            }
        }
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ 'Domestic Deferred Offer to Acceptance' },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            'Domestic Deferred Offer to Acceptance'
        );

        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            domesticDeferredOfferToAcceptanceManual.values(),
            cadenceWrapper
        );
        if (!contactToUpdateListManual.isEmpty()) {
            contactToUpdateMap.putAll(contactToUpdateListManual);
        }

        return contactToUpdateMap;
    }
    
    /**
      * @description: Check if the contact is for Entry International Offer to Acceptance cadences
      *
      * @param Map<Id,Contact> mapOfContacts record to evaluate
      * @return Map<Id,Contact> of domestic acceptance contact
      */    
      public static Map<Id,Contact> getInternationalOfferToAcceptanceForEntry(Map<Id,Contact> internationalEntryContactMap) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> internationalOffertoAcceptanceManual = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated = new Map<Id, hed__Application__c>();
        Map<Id, List<String>> existingContactOnCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AUTOMATED },
            Contact.getSObjectType()
        );
        // To group Automated and Manual Application
        for (hed__Application__c application : applicationList) {
            Boolean hasCompletedCadence = existingContactOnCompletedCadence.containsKey(application.hed__Applicant__c);
            boolean isStudyLinkRecordType = application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            if (
                isStudyLinkRecordType &&
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                ApplicationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_FOR_STUDYLINK.contains(application.Application_Status__c) &&
                NurturingTrackService.isDateWithinRange(
                    application.Calculated_Intake_Date__c,
                    CURRENT_INTAKE_PERIOD.get('START_DATE'),
                    CURRENT_INTAKE_PERIOD.get('END_DATE'))
            ) {
                processCompletedInternationalOffertoAcceptanceAutomated(application, internationalOffertoAcceptanceAutomated, hasCompletedCadence);
                processCompletedInternationalOffertoAcceptanceManual(application, internationalOffertoAcceptanceManual, hasCompletedCadence);
            }
        }

        getCompletedInternationalOffertoAcceptanceAutomated(internationalEntryContactMap, internationalOffertoAcceptanceAutomated, contactToUpdateMap);
        processRemoveApplicationInLatestApplication(internationalOffertoAcceptanceManual, contactToUpdateMap);
        getCompletedInternationalOffertoAcceptanceManual(internationalEntryContactMap, internationalOffertoAcceptanceManual, contactToUpdateMap);
        return contactToUpdateMap;
    }

    private static void processCompletedInternationalOffertoAcceptanceAutomated(hed__Application__c application, Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated, Boolean hasCompletedCadence){
        if( !hasCompletedCadence){
            internationalOffertoAcceptanceAutomated.put(application.Id, application);
        }
    }

    private static void processCompletedInternationalOffertoAcceptanceManual(hed__Application__c application, Map<Id,hed__Application__c> internationalOffertoAcceptanceManual, Boolean hasCompletedCadence){

        if( hasCompletedCadence &&
            application.Is_Agent_Assisted__c == false &&
            nurturingTrackWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL) &&
            nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL).Key_Date_Offset_Days__c != null &&
            application.Calculated_Intake_Date__c.addDays(-(Integer)nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL).Key_Date_Offset_Days__c) <= System.today()){
            internationalOffertoAcceptanceManual.put(application.Id, application);
        }
    }


    /**
     * @description Process Automated Application
     * @param Map<Id, Contact> internationalEntryContactMap
     * @param Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated
     * @param Map<Id, Contact> contactToUpdateMap
     */
    private static void getCompletedInternationalOffertoAcceptanceAutomated(Map<Id, Contact> internationalEntryContactMap,Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated,Map<Id, Contact> contactToUpdateMap){
        // Check Contact and Cadence Name if Automated is already Completed
        Map<Id, List<String>> completedAutomatedCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AUTOMATED
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), null,
                                                                                                                                    NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AUTOMATED);

        // Check and Update Contacts Cadence Name
        List<Contact> completedManualCadenceByContactId = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            completedAutomatedCadenceByContactId,
            internationalOffertoAcceptanceAutomated.values(),
            cadenceWrapper
        );

        if(!completedManualCadenceByContactId.isEmpty()){
            contactToUpdateMap.putAll(completedManualCadenceByContactId);
        }
    }

     /**
     * @description Process Manual Application
     * @param Map<Id, Contact> internationalEntryContactMap
     * @param Map<Id, hed__Application__c> internationalOffertoAcceptanceManual
     * @param Map<Id, Contact> contactToUpdateMap
     */
    private static void getCompletedInternationalOffertoAcceptanceManual(Map<Id, Contact> internationalEntryContactMap,Map<Id, hed__Application__c> internationalOffertoAcceptanceManual,Map<Id, Contact> contactToUpdateMap){
        // Check Contact and Cadence Name if Automated is already Completed
        Map<Id, List<String>> completedAutomatedCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AUTOMATED
            },
            Contact.getSObjectType()
        );
		
        Map<Id, hed__Application__c> latesetApplicationForManualCadence = new Map<Id, hed__Application__c>();

        // Get only the contact application that needs to be inserted if Automated is Completed
        for(Id applicationId : internationalOffertoAcceptanceManual.keySet()){
            hed__Application__c application = internationalOffertoAcceptanceManual.get(applicationId);
           
            if (completedAutomatedCadenceByContactId.containsKey(application.hed__Applicant__c)) {
                latesetApplicationForManualCadence.put(applicationId, application);
            }
        }

        // Check Contact and Cadence Name if Manual is already Completed
        Map<Id, List<String>> completedManualCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(),
                                                                                                        '',
                                                                                                        NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL);

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

    /**
     * @description Update domestic direct applicant contacts based on exit criteria
     * @param Map<Id, Contact> domesticExitContactMap
     * @return Map<Id, Contact> map of id to contact for batch processing
     */
    private static Map<Id, Contact> getExitInternationalOffertoAcceptance(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();

        Set<String> offerStatus = new Set<String>{ 'Accepted', 'Declined by Applicant', 'Deferral Requested','Acceptance - Payment Received','Acceptance - No Payment Required','Acceptance - Pending More Information','Acceptance - Pending Payment','Conditional Acceptance','Withdrawn' };

        for (hed__Application__c application : applicationList) {
            boolean isStudyLinkRecordType = application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            Boolean hasCalculatedCadence =
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AUTOMATED) ||
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL);
            if (
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                isStudyLinkRecordType &&
                offerStatus.contains(application.Application_Status__c) &&
                hasCalculatedCadence
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
     * @description Updates contact if criteria is for Entry of Domestic Enrolment to Census cadence
     * @param Map<Id,Contact> domesticContactForCensusMap - domestic contacts to evaluate
     * @return Map<Id,Contact> - contacts to update
     */ 
    public static Map<Id,Contact> getDomesticEnrollmentToCensusForEntry(Map<Id,Contact> domesticContactForCensusMap){
        return getDomesticAndInternationalEnrollmentToCensusForEntry(domesticContactForCensusMap, true);
    }

    /**
     * @description Updates contact if criteria is for Entry of International Enrolment to Census cadence
     * @param Map<Id,Contact> internationalContactForCensusMap - international contacts to evaluate
     * @return Map<Id,Contact> - contacts to update
     */ 
    public static Map<Id,Contact> getInternationalEnrollmentToCensusForEntry(Map<Id,Contact> internationalContactForCensusMap){
        return getDomesticAndInternationalEnrollmentToCensusForEntry(internationalContactForCensusMap, false);
    }

    /**
     * @description Validate records and update contacts if criteria is for Entry of Domestic and International Enrolment to Census cadence
     * @param Map<Id,Contact> contactMap contacts to evaluate
     * @return Map<Id,Contact> contactToUpdateMap contacts to update
     */  
    public static Map<Id,Contact> getDomesticAndInternationalEnrollmentToCensusForEntry(Map<Id,Contact> contactMap, Boolean isDomestic){
        List<hed__Application__c>  filteredApplicationList = getFilteredApplicationListForDomesticEnrollmentToCensus(contactMap);
        Map<Id, hed__Application__c> applicationMap = new Map<Id, hed__Application__c>();
        for (hed__Application__c application : filteredApplicationList) {
            
            Boolean isOfferedProgramPlanAvailable = (application.Offered_Program_Plan__c != NULL && application.Offered_Program_Plan__r.Availability_Start_Date__c != NULL);
			Date keyOffsetDaysFromToday = null;
            
            if(nurturingTrackWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE)){
               keyOffsetDaysFromToday = Date.today().addDays((Integer)nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE)?.Key_Date_Offset_Days__c); 
            }
 
            if (
                validateAppRecordTypeForEnrollmentToCensus(isDomestic, application) &&
                isOfferedProgramPlanAvailable &&
                keyOffsetDaysFromToday != NULL &&
                application.Offered_Program_Plan__r.Availability_Start_Date__c <= keyOffsetDaysFromToday
            ) {
                applicationMap.put(application.Id, application);
            }
        }

        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            contactMap.keySet(),
            new Set<String>{NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE},
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            applicationMap.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
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
            Boolean hasCalculatedCadence =
                (application.hed__Applicant__r.Calculated_Cadence__c == 'International Application Submission - Direct Applicant (Automated)') ||
                (application.hed__Applicant__r.Calculated_Cadence__c == 'International Application Submission - Direct Applicant');
            if (
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Application_Status__c == 'Submitted' &&
                hasCalculatedCadence
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
    public static Map<Id, Contact> getDomesticAcceptanceToEnrollmentForExit(
        Map<Id, Contact> domesticExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        Set<Id> existingContactIdOnApplicationToExit = getDomesticAcceptanceToEnrollmentExitFilter(
            applicationList,
            'DomesticAcceptanceToEnrollment'
        );
        for (Id contactId : domesticExitContactMap.keySet()) {
            Boolean hasExistingApplicationToExit = existingContactIdOnApplicationToExit.contains(
                contactId
            );
            if (hasExistingApplicationToExit) {
                contactsForUpdatingMap.put(
                    contactId,
                    new Contact(id = contactId, Calculated_Cadence__c = '')
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
    public static Map<Id, Contact> getDomesticDeferredOfferToAcceptanceForExit(
        Map<Id, Contact> domesticExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        Set<Id> existingContactIdOnApplicationToExit = getDomesticDeferredOfferToAcceptanceExitFilter(
            applicationList,
            'DomesticDeferredOfferToAcceptance'
        );
        for (Id contactId : domesticExitContactMap.keySet()) {
            Boolean hasExistingApplicationToExit = existingContactIdOnApplicationToExit.contains(
                contactId
            );
            if (hasExistingApplicationToExit) {
                contactsForUpdatingMap.put(
                    contactId,
                    new Contact(id = contactId, Calculated_Cadence__c = '')
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
        Set<String> stydyLinkApplicationStatus = new Set<String>{
            'Accepted',
            'Accepted -  Deferral',
            'Withdrawn'
        };

        for (hed__Application__c application : applicationList) {
            Boolean hasCalculatedCadence =
                application.hed__Applicant__r.Calculated_Cadence__c == 'International Acceptance Deposit not Paid';
            if (
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                stydyLinkApplicationStatus.contains(application.Application_Status__c) &&
                hasCalculatedCadence
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
    private static Set<Id> getDomesticAcceptanceToEnrollmentEntryFilter(
        List<hed__Application__c> applicationList
    ) {

        Set<Id> contactHasApplicationForEntry = new Set<Id>();
        /* samsApplicationWithQtacApplicantIdChecking(applicationList); */
        for (hed__Application__c app : applicationList) {
            processDomesticAcceptanceToEnrollmentEntryCriteria(
                app,
                contactHasApplicationForEntry
            );
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
    private static Set<Id> getContactOnApplicationForDomesticDeferredOfferToAcceptanceEntryFilter(
        List<hed__Application__c> applicationList,
        String methodName
    ) {
        Set<Id> contactHasApplicationForEntry = new Set<Id>();
        for (hed__Application__c app : applicationList) {
            processDomesticDeferredOfferToAcceptanceEntryCriteria(
                app,
                methodName,
                contactHasApplicationForEntry
            );
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
    private static Set<Id> getDomesticAcceptanceToEnrollmentExitFilter(
        List<hed__Application__c> applicationList,
        String methodName
    ) {
        Set<Id> contactHasApplicationForExit = new Set<Id>();
        for (hed__Application__c app : applicationList) {
            processDomesticAcceptanceToEnrollmentExitCriteria(
                app,
                methodName,
                contactHasApplicationForExit
            );
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
    private static Set<Id> getDomesticDeferredOfferToAcceptanceExitFilter(
        List<hed__Application__c> applicationList,
        String methodName
    ) {
        Set<Id> contactHasApplicationForExit = new Set<Id>();
        for (hed__Application__c app : applicationList) {
            processDomesticDeferredOfferToAcceptanceExitCriteria(
                app,
                methodName,
                contactHasApplicationForExit
            );
        }

        return contactHasApplicationForExit;
    }

    /**
     * @description Updates contact if criteria is for Exit of Domestic Enrolment to Census cadence
     * @param Map<Id,Contact> domesticContactForCensusMap - domestic contacts to evaluate
     * @return Map<Id,Contact> - contacts to update
     */ 
    private static Map<Id, Contact> getDomesticEnrollmentToCensusForExit(Map<Id, Contact> domesticContactForCensusMap) {
        return getDomesticAndInternationalEnrollmentToCensusForExit(domesticContactForCensusMap, true);
    }

    /**
     * @description Updates contact if criteria is for Exit of International Enrolment to Census cadence
     * @param Map<Id,Contact> internationalContactForCensusMap - international contacts to evaluate
     * @return Map<Id,Contact> - contacts to update
     */ 
    private static Map<Id, Contact> getInternationalEnrollmentToCensusForExit(Map<Id, Contact> internationalContactForCensusMap) {
        return getDomesticAndInternationalEnrollmentToCensusForExit(internationalContactForCensusMap, false);
    }

    /**
     * @description Validates the record and update contacts if criteria is for Exit of Domestic and International Enrolment to Census cadence
     * @param Map<Id,Contact> contactMap - contacts to evaluate
     * @param Boolean isDomestic - checker if student is domestic or international
     * @return Map<Id,Contact> contactsForUpdatingMap - contacts to update
     */  
    private static Map<Id, Contact> getDomesticAndInternationalEnrollmentToCensusForExit(Map<Id, Contact> contactMap, Boolean isDomestic) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        for (hed__Application__c application : applicationList) {
            Boolean hasCalculatedCadence =
                application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE;
            if(
                validateAppRecordTypeForEnrollmentToCensus(isDomestic, application) &&
                contactMap.containsKey(application.hed__Applicant__c) &&
                nurturingTrackForExitWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE) &&
                application.Offered_Program_Plan__r.Availability_Start_Date__c != null && 
                application.Offered_Program_Plan__r.Availability_Start_Date__c <= System.today().addDays(-(Integer)nurturingTrackForExitWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE)?.Key_Date_Offset_Days__c) &&
                hasCalculatedCadence
            ) {
                contactsForUpdatingMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsForUpdatingMap;
    }

    private static Boolean validateAppRecordTypeForEnrollmentToCensus(Boolean isDomestic, hed__Application__c application){
        if(
            (isDomestic && (application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID)) ||
            (!isDomestic && application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID)
        ){
            return true;
        }
        return false;
    }
    
    private static void processDomesticAcceptanceToEnrollmentEntryCriteria(
        hed__Application__c app,
        Set<Id> contactHasApplicationForEntry
    ) {
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                app.Application_Status__c != 'Admitted' &&
                app.Is_Active__c &&
                app.Related_QTAC_Application__c != null &&
                app.Related_QTAC_Application__r.Offer_Status__c == 'Accepted unconditionally'
            ) {
                contactHasApplicationForEntry.add(app.hed__Applicant__c);
            }
    }

    private static void processDomesticDeferredOfferToAcceptanceEntryCriteria(
        hed__Application__c app,
        String methodName,
        Set<Id> contactHasApplicationForEntry
    ) {
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        if (methodName == DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE) {
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                (app.Admission_Process__c == ApplicationsDAO.ADMISSION_PROCESS_RTN_DEFER ||
                app.Admission_Process__c == ApplicationsDAO.ADMISSION_PROCESS_RTN_QTAC) &&
                app.Offer_Status__c == 'Offered' &&
                app.Offered_Program_Plan__r.Availability_Start_Date__c.addDays(-21) <=
                System.today() &&
                app.Offered_Program_Plan__r.Availability_Start_Date__c >= System.today()
            ) {
                contactHasApplicationForEntry.add(app.hed__Applicant__c);
            }
        }
    }

    private static void processDomesticAcceptanceToEnrollmentExitCriteria(
        hed__Application__c app,
        String methodName,
        Set<Id> contactHasApplicationForExit
    ) {
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        Boolean hasCalculatedCadence =
                (app.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED) ||
                (app.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL);
        if (methodName == DOMESTIC_ACCEPTANCE_TO_ENROLLMENT) {
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                (app.Application_Status__c == 'Admitted' ||
                app.Application_Status__c == 'Withdrawn' ||
                app.Offer_Status__c == 'Deferred') &&
                hasCalculatedCadence
            ) {
                contactHasApplicationForExit.add(app.hed__Applicant__c);
            }
        }
    }

    private static void processDomesticDeferredOfferToAcceptanceExitCriteria(
        hed__Application__c app,
        String methodName,
        Set<Id> contactHasApplicationForExit
    ) {
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        Boolean hasCalculatedCadence =
                app.hed__Applicant__r.Calculated_Cadence__c == 'Domestic Deferred Offer to Acceptance';
        if (methodName == DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE) {
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                (app.Offer_Status__c == 'Accepted' ||
                app.Offer_Status__c == 'Declined' ||
                app.Offer_Status__c == 'Rescinded' ||
                app.Offer_Status__c == 'Unoffered') &&
                hasCalculatedCadence
            ) {
                contactHasApplicationForExit.add(app.hed__Applicant__c);
            }
        }
    }

    /**
     * @description: Get the nurturing Track Records and set the key to Cadence Name
     *
     */
    private static void getFilteredNurturingTrackRecords() {
        for (Nurture_Track_Configuration__c nurture : NurtureTrackConfigurationsDAO.newInstance().getNurtureTrack(NurtureTrackConfigurationsDAO.NURTURE_FIELDS,'SYSTEM_MODE')) {
            if (nurture.Criteria_Type__c == 'Entry' && nurture.Enquiry_Category_L1__c != null && nurture.Lead_Score_Threshold__c != null) {
                nurturingTrackWithThresholdForEntry.put(nurture.Cadence_Name__c, nurture);
            }
            if (nurture.Key_Date_Offset_Days__c != null) {
                if(nurture.Criteria_Type__c == 'Entry'){
                    nurturingTrackWithOffSetDaysMap.put(nurture.Cadence_Name__c, nurture);
                } else if(nurture.Criteria_Type__c == 'Exit'){
                    nurturingTrackForExitWithOffSetDaysMap.put(nurture.Cadence_Name__c, nurture);
                }
            }
        }
    }

    /**
     * @description: Checks existing completed cadence records of the contact
     *
     * @param List<hed__Application__c> application records to evaluate
     * @param String cadence name to evaluate
     */
    private static Set<Id> getContactOnApplicationWithProgramPlan(
        List<hed__Application__c> applications,
        String cadenceName
    ) {
        Set<Id> contactIds = new Set<Id>();
        for (hed__Application__c app : applications) {
            if (cadenceName == NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL) {
                if (
                    app.Offered_Program_Plan__c != null &&
                    nurturingTrackWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL) &&
                    nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL)
                        ?.Key_Date_Offset_Days__c != null &&
                        app.Offered_Program_Plan__r.Availability_Start_Date__c!=null &&
                        app.Offered_Program_Plan__r.Availability_Start_Date__c.addDays(
                        -(Integer) nurturingTrackWithOffSetDaysMap.get(
                                NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL
                            )
                            ?.Key_Date_Offset_Days__c
                    ) <= System.today() &&
                    app.Offered_Program_Plan__r.Availability_Start_Date__c >= System.today()
                ) {
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
    private static Set<Id> getCompletedCadenceRecord(Set<Id> contactIds, String methodName) {
      
        Set<Id> contactIdOfCompletedCadence = new Set<Id>();
        List<Completed_Cadence__c> compCadenceList = CompletedCadencesDAO.newInstance()
            .getCompletedCadenceByContactIds(contactIds, 'SYSTEM_MODE');
        for (Completed_Cadence__c comCadence : compCadenceList) {
            if(comCadence.Nurture_Track_Configuration__r.Cadence_Name__c != null && comCadence.Nurture_Track_Configuration__r.Cadence_Name__c == methodName ){
                contactIdOfCompletedCadence.add(comCadence.Contact__c);
            }
        }
        return contactIdOfCompletedCadence;
    }

    private static void getCompletedCadenceForDomesticAcceptanceToEnrollmentAutomated(
        Map<Id, Contact> domesticEntryContactMap,
        Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentAutomated,
        Map<Id, Contact> contactToUpdateMap
    ) {
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED
        );

        List<Contact> contactToUpdateListAutomated = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            domesticAcceptanceToEnrollmentAutomated.values(),
            cadenceWrapper
        );

        if (!contactToUpdateListAutomated.isEmpty()) {
            contactToUpdateMap.putAll(contactToUpdateListAutomated);
        }
    }

    private static void getCompletedCadenceForDomesticAcceptanceToEnrollmentManual(
        Map<Id, Contact> domesticEntryContactMap,
        Map<Id, hed__Application__c> domesticAcceptanceToEnrollmentManual,
        Map<Id, Contact> contactToUpdateMap
    ) {
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL
        );

        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            domesticAcceptanceToEnrollmentManual.values(),
            cadenceWrapper
        );
        if (!contactToUpdateListManual.isEmpty()) {
            contactToUpdateMap.putAll(contactToUpdateListManual);
        }
    }

    /**
     * @description Validate records for Domestic Enrolment to Census Entry cadence
     * @param Map<Id,Contact> domesticExitContactMap domestic contacts to evaluate
     * @return Map<Id,Contact> contactsForUpdatingMap domestic contacts to update
     */ 
    private static List<hed__Application__c> getFilteredApplicationListForDomesticEnrollmentToCensus(Map<Id,Contact> domesticEntryContactMap){
        Set<Id> programEnrollmentIds = new Set<Id>();
        Map<Id, hed__Application__c> contactFromAppWithProgramEnrollmentMap = new Map<Id, hed__Application__c>();

        for (hed__Application__c application : applicationList) {
            if(domesticEntryContactMap.containsKey(application.hed__Applicant__c) && application.Program_Enrollment__c != null){
                programEnrollmentIds.add(application.Program_Enrollment__c);
                contactFromAppWithProgramEnrollmentMap.put(application.hed__Applicant__c, application);
            }
        }       

        Set<Id> filteredProgramEnrollmentIds = new Set<Id>();
        List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance().getProgramEnrollmentsById(programEnrollmentIds, 'USER_MODE');
        for(hed__Program_Enrollment__c programEnrollment : programEnrollmentList){
            filteredProgramEnrollmentIds.add(programEnrollment.Id);
        }
        
        List<hed__Application__c> applicationList = new List<hed__Application__c>();
        List<hed__Course_Enrollment__c> courseEnrollmentList = CourseConnectionsDAO.newInstance().getCourseConnectionByProgramEnrollmentIds(filteredProgramEnrollmentIds, 'USER_MODE');
        for(hed__Course_Enrollment__c courseEnrollment : courseEnrollmentList){
            if(contactFromAppWithProgramEnrollmentMap.containsKey(courseEnrollment.hed__Contact__c) && courseEnrollment.Enrollment_Status__c != 'Enrolled'){
                applicationList.add(contactFromAppWithProgramEnrollmentMap.get(courseEnrollment.hed__Contact__c));
            }
        }

        return applicationList;
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
        
        Map<Id, List<String>> existingContactOnCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED },
            Contact.getSObjectType()
        );

        // To group Automated and Manual Application
        for (hed__Application__c application : applicationList) {
            boolean isSAMSLegacyRecType =
                application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType =
                application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                domesticEntryContactMap.containsKey(application.hed__Applicant__c) &&
                application.Offer_Status__c == 'Offer' &&
                (
                    application.Admission_Process__c != ApplicationsDAO.ADMISSION_PROCESS_RTN_DEFER && 
                    application.Admission_Process__c != ApplicationsDAO.ADMISSION_PROCESS_RTN_QTAC
                ) &&
                application.hed__Application_Date__c != null
            ) {
                Boolean hasAutomatedCompletedCadence = existingContactOnCompletedCadence.containsKey(application.hed__Applicant__c);
                processCompletedDomesticFirstOffertoAcceptance(
                    application,
                    domesticFirstOffertoAcceptanceManual,
                    domesticFirstOffertoAcceptanceAutomated,
                    hasAutomatedCompletedCadence                    
                );
            }
        }

        Map<Id, hed__Application__c> latestApplicationAutomated = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> latestApplicationManual = new Map<Id, hed__Application__c>();

        processLatestApplicationDate(
            domesticFirstOffertoAcceptanceAutomated,
            latestApplicationAutomated
        );
        processLatestApplicationDate(domesticFirstOffertoAcceptanceManual, latestApplicationManual);
        getCompletedDomesticFirstOffertoAcceptanceAutomated(
            domesticEntryContactMap,
            latestApplicationAutomated,
            contactToUpdateMap
        );
        processRemoveApplicationInLatestApplication(latestApplicationManual, contactToUpdateMap);
        getCompletedDomesticFirstOffertoAcceptanceManual(
            domesticEntryContactMap,
            latestApplicationManual,
            contactToUpdateMap
        );

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
            boolean isSAMSLegacyRecType =
                application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType =
                application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            Boolean hasCalculatedCadence =
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED) ||
                (application.hed__Applicant__r.Calculated_Cadence__c == 'Domestic First Offer to Acceptance');
            if (
                domesticExitContactMap.containsKey(application.hed__Applicant__c) &&
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                offerStatus.contains(application.Offer_Status__c) &&
                hasCalculatedCadence
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
    private static void processLatestApplicationDate(
        Map<Id, hed__Application__c> domesticFirstOffertoAcceptance,
        Map<Id, hed__Application__c> latestApplication
    ) {
        Map<Id, hed__Application__c> filterByContactApplication = new Map<Id, hed__Application__c>();

        for (Id applicationId : domesticFirstOffertoAcceptance.keySet()) {
            Id contactId = domesticFirstOffertoAcceptance.get(applicationId).hed__Applicant__c;
            hed__Application__c application = domesticFirstOffertoAcceptance.get(applicationId);

            if (
                !filterByContactApplication.containsKey(contactId) ||
                (filterByContactApplication.containsKey(contactId) &&
                (application.hed__Application_Date__c >
                filterByContactApplication.get(contactId).hed__Application_Date__c))
            ) {
                filterByContactApplication.put(
                    contactId,
                    domesticFirstOffertoAcceptance.get(applicationId)
                );
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
    private static void processCompletedDomesticFirstOffertoAcceptance(
        hed__Application__c application,
        Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceManual,
        Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated,
        Boolean hasAutomatedCompletedCadence
    ) {

        if (hasAutomatedCompletedCadence){
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
    private static void processRemoveApplicationInLatestApplication(
        Map<Id, hed__Application__c> latestApplicationManual,
        Map<Id, Contact> contactToUpdateMap
    ) {
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
    private static void getCompletedDomesticFirstOffertoAcceptanceAutomated(
        Map<Id, Contact> domesticEntryContactMap,
        Map<Id, hed__Application__c> domesticFirstOffertoAcceptanceAutomated,
        Map<Id, Contact> contactToUpdateMap
    ) {
        // Check Contact and Cadence Name if Automated is already Completed
        Map<Id, List<String>> completedAutomatedCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED
        );

        // Check and Update Contacts Cadence Name
        List<Contact> completedManualCadenceByContactId = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            completedAutomatedCadenceByContactId,
            domesticFirstOffertoAcceptanceAutomated.values(),
            cadenceWrapper
        );

        if (!completedManualCadenceByContactId.isEmpty()) {
            contactToUpdateMap.putAll(completedManualCadenceByContactId);
        }
    }

    /**
     * @description Process Manual Application
     * @param Map<Id, Contact> domesticEntryContactMap
     * @param Map<Id, hed__Application__c> latestApplicationManual
     * @param Map<Id, Contact> contactToUpdateMap
     */
    private static void getCompletedDomesticFirstOffertoAcceptanceManual(
        Map<Id, Contact> domesticEntryContactMap,
        Map<Id, hed__Application__c> latestApplicationManual,
        Map<Id, Contact> contactToUpdateMap
    ) {
        // Check Contact and Cadence Name if Automated is already Completed
        Map<Id, List<String>> completedAutomatedCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED },
            Contact.getSObjectType()
        );

        Map<Id, hed__Application__c> latesetApplicationForManualCadence = new Map<Id, hed__Application__c>();

        // Get only the contact application that needs to be inserted if Automated is Completed
        for (Id applicationId : latestApplicationManual.keySet()) {
            hed__Application__c application = latestApplicationManual.get(applicationId);

            if (completedAutomatedCadenceByContactId.containsKey(application.hed__Applicant__c)) {
                latesetApplicationForManualCadence.put(applicationId, application);
            }
        }

        // Check Contact and Cadence Name if Manual is already Completed
        Map<Id, List<String>> completedManualCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ 'Domestic First Offer to Acceptance' },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            'Domestic First Offer to Acceptance'
        );

        // Check and Update Contacts Cadence Name
        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            completedManualCadenceByContactId,
            latesetApplicationForManualCadence.values(),
            cadenceWrapper
        );

        if (!contactToUpdateListManual.isEmpty()) {
            contactToUpdateMap.putAll(contactToUpdateListManual);
        }
    }

    /**
     * @description Update Domestic Offer Lapsed contacts based on entry criteria
     * @param Map<Id, Contact> domesticEntryContactMap a map of ids to entry domestic contact records
     * @return Map<Id, Contact> map of ids to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryDomesticOfferLapsed(
        Map<Id, Contact> domesticEntryContactMap
    ) {
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> applicantAutomated = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> applicantManual = new Map<Id, hed__Application__c>();

        for (hed__Application__c application : applicationList) {
            Boolean isSAMSApplicant =
                (application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID) ||
                (application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            
            if (
                application.Offer_Status__c != null &&
                application.Offer_Lapse_Date__c != null &&
                isSAMSApplicant &&
                domesticEntryContactMap.containsKey(application.hed__Applicant__c) &&
                application.Offer_Status__c == 'Lapsed'
            ) {
                processEntryDomesticOfferLapsed(application, applicantAutomated, applicantManual);
            }
        }

        processApplicantAutomated(applicantAutomated, contactsToUpdateMap);
        processApplicantManual(applicantManual, contactsToUpdateMap);

        return contactsToUpdateMap;
    }

    /**
     * @description Update international direct applicant contacts based on entry criteria
     * @param Map<Id, Contact> internationEntryContactMap a map of ids to entry international contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    public static Map<Id, Contact> getEntryInternationalApplicationToOffer(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Double offsetDays = nurturingTrackWithOffSetDaysMap.get('International Application to Offer')?.Key_Date_Offset_Days__c;
        Map<Id, hed__Application__c> internationalApplicantsToOffer = new Map<Id, hed__Application__c>();
        for (hed__Application__c application : applicationList) {
            Boolean withinOffSetDays = false;
            if(
                offsetDays != null &&
                application.Calculated_Intake_Date__c  != null
            ){
                withinOffSetDays = setwithinOffSetDays(application, offsetDays);
            }
            if (checkAppInternationalApplicationToOffer(application) &&
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                withinOffSetDays
            ) {
            	internationalApplicantsToOffer.put(application.Id, application);
            }
        }
        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{
                'International Application to Offer'
            },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            'International Application to Offer'
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            internationalApplicantsToOffer.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description: Check if the contact is for Entry of Domestic Strong Interest Pre-Application cadences
     *
     * @param Map<Id,Contact> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance contact
     */
    private static Map<Id, Contact> getDomesticStrongInterestPreApplicationForEntry(
        Map<Id, Contact> domesticEntryContactMap
    ) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Set<Id> existingContactIdOnApplication = getContactOnApplicationForDomesticStrongInterestPreApplicationEntryFilter(applicationList,domesticEntryContactMap.keySet());
        Set<Id> existingCaseFromContact = getCaseRecordsFromContact(domesticEntryContactMap.keySet());
        Set<Id> contactIdsWithApplication = getContactIdsWithApplication(applicationList);
        Map<Id, List<String>> contactsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            Contact.getSObjectType()
        );

        Map<Id, List<String>> contactsWithCompletedCadenceManual = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL },
            Contact.getSObjectType()
        );

        for (Contact contact : domesticEntryContactMap.values()){
            Boolean contacHasExistingApplication = contactIdsWithApplication.contains(contact.Id);
            Boolean hasInActiveApplication = existingContactIdOnApplication.contains(contact.Id);
            Boolean hasExistingCaseFromContact = existingCaseFromContact.contains(contact.Id);
            Boolean hasExistingCompletedCadence = contactsWithCompletedCadence.containsKey(contact.Id);
            Boolean hasExistingCompletedCadenceManual = contactsWithCompletedCadenceManual.containsKey(contact.Id);
         
            if ((!contacHasExistingApplication || hasInActiveApplication) && hasExistingCaseFromContact && !hasExistingCompletedCadenceManual)
            {
                contactToUpdateMap.put(
                        contact.Id, 
                        new Contact(
                            Id = contact.Id,
                            Calculated_Cadence__c = hasExistingCompletedCadence ?
                                'Domestic Strong Interest Pre-Application' :
                                'Domestic Strong Interest Pre-Application (Automated)'
                        )
                    );
            }
        }
        
        return contactToUpdateMap;
    }

    /**
     * @description Update contact with the “Domestic Accepted and Admitted” when the entry criteria is fulfilled.
     * @param Map<Id, Contact> domesticContact a map of ids to entry contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryDomesticAcceptedAndAdmitted(
        Map<Id, Contact> domesticEntryContactMap
    ) {
        Map<Id, hed__Application__c> domesticAcceptedApplicants = new Map<Id, hed__Application__c>();

        for (hed__Application__c app : applicationList) {
            
            Boolean isSAMSApplication = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            Boolean isProgramEnrollmentAdmitted = (app.Program_Enrollment__c != NULL && String.isNotBlank(app.Program_Enrollment__r.Enrollment_Status__c));
            Boolean isSAMSLatestApplication = (app.Calculated_Intake_Date__c != NULL && app.Calculated_Intake_Date__c > Date.today());
    
            if (isSAMSApplication &&
                domesticEntryContactMap.containsKey(app.hed__Applicant__c) &&
                isProgramEnrollmentAdmitted &&
                isSAMSLatestApplication &&
                app.Program_Enrollment__r.Enrollment_Status__c =='Admitted'
            ) {
                domesticAcceptedApplicants.put(app.Id, app);
            }
        }

        Map<Id, List<String>> applicationIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ 'Domestic Accepted and Admitted' },
            Contact.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            'Domestic Accepted and Admitted'
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadence,
            domesticAcceptedApplicants.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description: Check if the contact is for Exit of Domestic Deferred Offer to Acceptance cadences
     *
     * @param Map<Id,Contact> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance contact
     */
    private static Map<Id, Contact> getDomesticStrongInterestPreApplicationForExit(
        Map<Id, Contact> domesticExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        Set<Id> existingContactIdOnApplicationToExit = getContactOnApplicationForDomesticStrongInterestPreApplicationExitFilter(
            applicationList
        );
        for (Id contactId : domesticExitContactMap.keySet()) {
            Boolean hasExistingApplicationToExit = existingContactIdOnApplicationToExit.contains(
                contactId
            );
            if (hasExistingApplicationToExit || domesticExitContactMap.get(contactId).HasOptedOutOfEmail) {
                contactsForUpdatingMap.put(
                    contactId,
                    new Contact(id = contactId, Calculated_Cadence__c = '')
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
    private static Set<Id> getContactOnApplicationForDomesticStrongInterestPreApplicationEntryFilter(
        List<hed__Application__c> applicationList,
        Set<Id> contactIdSet
    ) {
        Set<Id> contactHasApplicationForEntry = new Set<Id>();
        Map<Id, List<String>> existingContactOnCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            Contact.getSObjectType()
        );
        for (hed__Application__c app : applicationList) {
            boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            if(isSAMSLegacyRecType || isSAMSCiRecType){
                processSamsDomesticStrongInterestPreApplicationEntryCriteria(app,contactHasApplicationForEntry,existingContactOnCompletedCadence.containsKey(app.hed__Applicant__c));
            }
            else if(isQTACRecType){
                processQtacDomesticStrongInterestPreApplicationEntryCriteria(app,contactHasApplicationForEntry,existingContactOnCompletedCadence.containsKey(app.hed__Applicant__c));
            }
        }
        return contactHasApplicationForEntry;
    }

    private static void processSamsDomesticStrongInterestPreApplicationEntryCriteria(
        hed__Application__c app,
        Set<Id> contactHasApplicationForEntry,
        boolean hasCompletedCadence
    ) {

        if(!hasCompletedCadence && checkSamsDomesticStrongInterestPreApplicationAutomated(app)){
                contactHasApplicationForEntry.add(app.hed__Applicant__c);
        }
        else if(hasCompletedCadence && checkSamsDomesticStrongInterestPreApplicationManual(app)){
                contactHasApplicationForEntry.add(app.hed__Applicant__c);
        }
    }

    private static boolean checkSamsDomesticStrongInterestPreApplicationAutomated(hed__Application__c app){
        Boolean isAppStatusValid = app.Application_Status__c == 'Admitted' || app.Application_Status__c == 'Unsuccessful' || app.Application_Status__c == 'Withdrawn';
        if ((app.Offer_Status__c == 'Deferred' || isAppStatusValid) &&
            app.hed__Applicant__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED) &&
            app.hed__Applicant__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.Now() && app.hed__Application_Date__c >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static boolean checkSamsDomesticStrongInterestPreApplicationManual(hed__Application__c app){
        Boolean isAppStatusValid = app.Application_Status__c == 'Admitted' || app.Application_Status__c == 'Unsuccessful' || app.Application_Status__c == 'Withdrawn';
        if ((app.Offer_Status__c == 'Deferred' || isAppStatusValid) &&
            app.hed__Applicant__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL) &&
            app.hed__Applicant__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.Now() && app.hed__Application_Date__c >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static void processQtacDomesticStrongInterestPreApplicationEntryCriteria(
        hed__Application__c app,
        Set<Id> contactHasApplicationForEntry,
        boolean hasCompletedCadence) {
        if(!hasCompletedCadence && checkQtacDomesticStrongInterestPreApplicationAutomated(app)){
            contactHasApplicationForEntry.add(app.hed__Applicant__c);
        }
        else if(hasCompletedCadence && checkQtacDomesticStrongInterestPreApplicationManual(app)){
            contactHasApplicationForEntry.add(app.hed__Applicant__c);
        }
    }

    private static boolean checkQtacDomesticStrongInterestPreApplicationAutomated(hed__Application__c app){
        if (!app.Is_Active__c &&
            app.hed__Applicant__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED) &&
            app.hed__Applicant__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Lead_Score_Threshold__c &&
            (app.CreatedDate <= System.Now() && app.CreatedDate >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static boolean checkQtacDomesticStrongInterestPreApplicationManual(hed__Application__c app){
        if (!app.Is_Active__c &&
            app.hed__Applicant__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL) &&
            app.hed__Applicant__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Lead_Score_Threshold__c &&
            (app.CreatedDate <= System.Now() && app.CreatedDate >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static Set<Id> getContactOnApplicationForDomesticStrongInterestPreApplicationExitFilter(List<hed__Application__c> applicationList){
        Set<Id> contactHasApplicationForExit = new Set<Id>();
        for (hed__Application__c app : applicationList) {
            boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            if(app.Application_Status__c == 'Submitted' && (isSAMSLegacyRecType || isSAMSCiRecType || isQTACRecType)){
                contactHasApplicationForExit.add(app.hed__Applicant__c);
            }
        }
        return contactHasApplicationForExit;
    }

    private static Set<Id> getCaseRecordsFromContact(Set<Id> contactIds){
        Set<Id> caseFromContactIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        Map<Id, List<String>> hasContactOnCompletedCadence = new Map<Id, List<String>>();

        if(nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED)){
            hasContactOnCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                domesticEntryContactMap.keySet(),
                new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
                Contact.getSObjectType()
            );
            caseList = CasesDAO.newInstance().getCasesByContactIds(contactIds, AccessLevel.SYSTEM_MODE);
        }

        for(Case caseRec : caseList){
            if(!hasContactOnCompletedCadence.containsKey(caseRec.ContactId) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromContactIds.add(caseRec.ContactId);
            }
            else if(hasContactOnCompletedCadence.containsKey(caseRec.ContactId) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromContactIds.add(caseRec.ContactId);
            }
        }
        return caseFromContactIds;
    }

    private static boolean checkCaseCreatedDate(Case caseRec){
        return (caseRec.CreatedDate <= System.Now() && caseRec.CreatedDate >= System.Now().addMonths(-3) && caseRec.Category__c != null);
    }

    private static Set<Id> getContactIdsWithApplication(List<hed__Application__c> applications){
        Set<Id> applicationContactIds = new Set<Id>();
        for(hed__Application__c app : applications){
            applicationContactIds.add(app.hed__Applicant__c);
        }
        return applicationContactIds;
    }   



    /**
     * @description Update Domestic Offer Lapsed contacts based on exit criteria
     * @param Map<Id, Contact> domesticExitContactMap a map of ids to exit domestic contact records
     * @return Map<Id, Contact> map of ids to updated contact records for batch processing
     */
    private static Map<Id, Contact> getExitDomesticOfferLapsed(
        Map<Id, Contact> domesticExitContactMap
    ) {
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();
        for (hed__Application__c application : applicationList) {
            Boolean isSAMSApplicant = (application.RecordTypeId ==
            ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
            application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            Boolean hasDomesticOfferLapsedCadence =
                (application.hed__Applicant__r.Calculated_Cadence__c ==
                DOMESTIC_OFFER_LAPSED_AUTOMATED) ||
                (application.hed__Applicant__r.Calculated_Cadence__c ==
                DOMESTIC_OFFER_LAPSED_MANUAL);
            if (
                isSAMSApplicant &&
                hasDomesticOfferLapsedCadence &&
                domesticExitContactMap.containsKey(application.hed__Applicant__c) &&
                application.Offer_Status__c != 'Lapsed'
            ) {
                contactsToUpdateMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsToUpdateMap;
    }

    /**
     * @description Update Domestic Offer Lapsed contacts based on exit criteria
     * @param Map<Id, Contact> domesticExitContactMap a map of ids to exit domestic contact records
     * @return Map<Id, Contact> map of ids to updated contact records for batch processing
     */
    private static Map<Id, Contact> getExitInternationalApplicationToOffer(
        Map<Id, Contact> internationalExitContactMap
    ) {
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();
        for (hed__Application__c application : applicationList) {
            if (
                application.hed__Applicant__r.Calculated_Cadence__c == 'International Application to Offer' &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                !ApplicationsDAO.INTL_EXIT_APPLICATION_TO_OFFER_STATUSES_FOR_STUDYLINK.contains(application.Application_Status__c)
            ) {
                contactsToUpdateMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsToUpdateMap;
    }

    private static void processEntryDomesticOfferLapsed(
        hed__Application__c application,
        Map<Id, hed__Application__c> applicantAutomated,
        Map<Id, hed__Application__c> applicantManual
    ) {
        Map<Id, List<String>> hasExistingAutomatedCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ DOMESTIC_OFFER_LAPSED_AUTOMATED },
            Contact.getSObjectType()
        );

        boolean hasAutomatedOffsetDays =
            nurturingTrackWithOffSetDaysMap.containsKey(DOMESTIC_OFFER_LAPSED_AUTOMATED) &&
                nurturingTrackWithOffSetDaysMap.get(DOMESTIC_OFFER_LAPSED_AUTOMATED)
                    .Key_Date_Offset_Days__c != null;

        boolean hasManualOffsetDays =
            nurturingTrackWithOffSetDaysMap.containsKey(DOMESTIC_OFFER_LAPSED_MANUAL) &&
                nurturingTrackWithOffSetDaysMap.get(DOMESTIC_OFFER_LAPSED_MANUAL)
                    .Key_Date_Offset_Days__c != null;

        if (hasAutomatedOffsetDays) {
            Integer offsetDaysAutomated = (Integer) nurturingTrackWithOffSetDaysMap.get(
                    DOMESTIC_OFFER_LAPSED_AUTOMATED
                )
                .Key_Date_Offset_Days__c;

            Date offsetOfferLapsedDateAutomated = application.Offer_Lapse_Date__c.addDays(
                offsetDaysAutomated
            );

            if (System.today() >= offsetOfferLapsedDateAutomated) {
                applicantAutomated.put(application.Id, application);
            }
        }

        if (hasManualOffsetDays) {
            Integer offsetDaysManual = (Integer) nurturingTrackWithOffSetDaysMap.get(
                    DOMESTIC_OFFER_LAPSED_MANUAL
                )
                .Key_Date_Offset_Days__c;

            Date offsetOfferLapsedDateManual = application.Offer_Lapse_Date__c.addDays(
                offsetDaysManual
            );

            if (
                System.today() >= offsetOfferLapsedDateManual &&
                hasExistingAutomatedCompletedCadence.containsKey(application.hed__Applicant__c)
            ) {
                applicantManual.put(application.Id, application);
            }
        }
    }

    private static void processApplicantAutomated(
        Map<Id, hed__Application__c> applicantAutomated,
        Map<Id, Contact> contactsToUpdateMap
    ) {
        Map<Id, List<String>> applicationIdsWithCompletedCadenceAutomated = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ DOMESTIC_OFFER_LAPSED_AUTOMATED },
            Contact.getSObjectType()
        );
        NurturingTrackService.CadenceWrapper cadenceWrapperAutomated = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            DOMESTIC_OFFER_LAPSED_AUTOMATED,
            null
        );
        List<Contact> contactToUpdateListAutomated = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadenceAutomated,
            applicantAutomated.values(),
            cadenceWrapperAutomated
        );
        contactsToUpdateMap.putAll(new Map<Id, Contact>(contactToUpdateListAutomated));
    }

    private static void processApplicantManual(
        Map<Id, hed__Application__c> applicantManual,
        Map<Id, Contact> contactsToUpdateMap
    ) {
        Map<Id, List<String>> applicationIdsWithCompletedCadenceManual = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new Set<String>{ DOMESTIC_OFFER_LAPSED_MANUAL },
            Contact.getSObjectType()
        );
        NurturingTrackService.CadenceWrapper cadenceWrapperManual = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            DOMESTIC_OFFER_LAPSED_MANUAL
        );
        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicationIdsWithCompletedCadenceManual,
            applicantManual.values(),
            cadenceWrapperManual
        );
        contactsToUpdateMap.putAll(new Map<Id, Contact>(contactToUpdateListManual));
    }

    private static boolean setwithinOffSetDays(hed__Application__c app, Double offsetDays){
        return (app.Calculated_Intake_Date__c.addDays(-(Integer) offsetDays) <= System.today() &&
        app.Calculated_Intake_Date__c >= System.today());
    }

    private static boolean checkAppInternationalApplicationToOffer(hed__Application__c app){
        return (
        app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID  &&
        ApplicationsDAO.INTL_ENTRY_APPLICATION_TO_OFFER_STATUSES_FOR_STUDYLINK.contains(app.Application_Status__c) &&
        NurturingTrackService.isDateWithinRange(
            app.Calculated_Intake_Date__c,
            CURRENT_INTAKE_PERIOD.get('START_DATE'),
            CURRENT_INTAKE_PERIOD.get('END_DATE')
        ) &&        
        app.Is_Agent_Assisted__c == false);
    }

    private static Map<Id, Contact> getEntryInternationalStrongInterestPreApplication(Map<Id, Contact> internationalEntryContactMap) {
        Map<String, Nurture_Track_Configuration__c> intlEntryStrongInterestPreAppConfigs = getIntlEntryStrongInterestPreAppConfigs();
        Map<Id, List<String>> contactIdsWithCmpltdCadenceSet = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_MANUAL,NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_AUTOMATED},
            Contact.getSObjectType()
        );
        
        // Check Contact and Cadence Name if Manual is already Completed
        Set<Id> completedManualCadenceByContactId = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_AUTOMATED },
            Contact.getSObjectType()
        ).keySet();
        
        Map<Id, List<String>> contactIdToCaseCategoriesMap = NurturingTrackService.getApplicantIdToRelatedCaseCategoriesMap(internationalEntryContactMap.keySet(), 3);
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for(Contact internationalEntryContact : internationalEntryContactMap.values()) {
            
            boolean shouldContinueProcessing = contactIdsWithCmpltdCadenceSet.containsKey(internationalEntryContact.Id) && contactIdsWithCmpltdCadenceSet.get(internationalEntryContact.Id).size() >= 2;
            
            if (shouldContinueProcessing) {
                continue;
            }
            
            Boolean isManual = !completedManualCadenceByContactId.contains(internationalEntryContact.Id);
            Decimal threshold = NurturingTrackService.selectThreshold(
                intlEntryStrongInterestPreAppConfigs, 
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_MANUAL,
                isManual
            );
            List<String> l1Categories = NurturingTrackService.selectL1Categories(
                intlEntryStrongInterestPreAppConfigs, 
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_MANUAL,
                isManual
            );
            List<String> relatedCaseCategories = contactIdToCaseCategoriesMap.get(internationalEntryContact.Id);
            if( // ... the contact...
                isContactWithNoActiveStudyLinkAppforXYears(internationalEntryContact, 3) &&  // ... has no active studylink app...
                internationalEntryContact.Lead_Score__c > threshold &&                       // ... has a lead score above threshold...
                NurturingTrackService.isRelatedCaseCategoriesContainsL1Categories(           // ... has a related case with a certain category...
                    l1Categories, 
                    relatedCaseCategories
                )
            ) {
                contactsToUpdate.put(
                    internationalEntryContact.Id, 
                    new Contact(
                        Id = internationalEntryContact.Id,
                        Calculated_Cadence__c = !isManual ?
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_MANUAL:
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_AUTOMATED
                    )
                );
            }
        }
        return contactsToUpdate;
    }

    private static Map<Id, Contact> getExitInternationalStrongInterestPreApplication(Map<Id, Contact> internationalExitContactMap) {
        List<String> cadenceNames = new List<String>{
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_AUTOMATED, 
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_MANUAL
        };
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for(hed__Application__c application : applicationList) {
            Contact relatedContact = internationalExitContactMap.get(application.hed__Applicant__c);
            if(
                relatedContact != null &&
                cadenceNames.contains(relatedContact.Calculated_Cadence__c) && 
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                (!ApplicationsDAO.STUDYLINK_TERMINAL_STATUSES.contains(application.Application_Status__c) ||
                relatedContact.HasOptedOutOfEmail)
            ) {
                contactsToUpdate.put(
                    relatedContact.Id,
                    new Contact(
                        Id = relatedContact.Id,
                        Calculated_Cadence__c = ''
                    )
                );
            }
        }

        getContactHasOptedOutOfEmail(internationalExitContactMap, contactsToUpdate, cadenceNames);

        return contactsToUpdate;
    }

    private static void getContactHasOptedOutOfEmail(Map<Id, Contact> internationalExitContactMap, Map<Id, Contact> contactsToUpdate, List<String> cadenceNames) {
        for(Id contactId : internationalExitContactMap.keySet()) {
            Contact contactDetail = internationalExitContactMap.get(contactId);
            if (
                cadenceNames.contains(contactDetail.Calculated_Cadence__c) &&
                contactDetail.HasOptedOutOfEmail == true &&
                contactsToUpdate.get(contactDetail.Id) == null
            ) {
                contactsToUpdate.put(
                    contactDetail.Id,
                    new Contact(
                        Id = contactDetail.Id,
                        Calculated_Cadence__c = ''
                    )
                );
            }
        }
    }

    private static Boolean isContactWithNoActiveStudyLinkAppforXYears(Contact internationalEntryContact, Integer years) {
        Boolean hasActiveApplication = false;
        for(hed__Application__c application : applicationList) {
            Boolean isApplicantStudylinkApplication = 
                application.hed__Applicant__c == internationalEntryContact.Id && 
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            Boolean isInitiallyCreatedWithinTimeRange = 
                application.hed__Initial_Creation_Date__c <= System.today() &&
                application.hed__Initial_Creation_Date__c >= System.today().addYears(-years);
            Boolean isActiveApplication = !ApplicationsDAO.STUDYLINK_TERMINAL_STATUSES.contains(application.Application_Status__c);
            if(
                isApplicantStudylinkApplication &&
                isInitiallyCreatedWithinTimeRange &&
                isActiveApplication
            ) {
                hasActiveApplication = true;
                break;
            }
        }
        return !hasActiveApplication;
    }

    private static Map<String, Nurture_Track_Configuration__c> getIntlEntryStrongInterestPreAppConfigs() {
        Map<String, Nurture_Track_Configuration__c> configsMap = new Map<String, Nurture_Track_Configuration__c>();
        for(Nurture_Track_Configuration__c config : NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(
            new Set<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_AUTOMATED, 
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PREAPPLICATION_MANUAL},
            'SYSTEM_MODE'
        )) {
            if(config.Criteria_Type__c == 'Entry') {
                configsMap.put(config.Cadence_Name__c, config);
            }
        }
        return configsMap;
    }
}