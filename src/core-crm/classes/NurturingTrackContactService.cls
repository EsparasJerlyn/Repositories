/**
 * @description helper class for NurturingTrackContactService 
 * @see NurturingTrackContactBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                     |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                                                       |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Added handling for Domestic and International                                      |
      |                                |                       |                        | Enrolment to Census                                                                |
      | mark.j.mahilum                 | Sept 07, 2023         | DEPP-6479              | Updated methods to replace the Term Intake to                                      |
      |                                |                       |                        | Calculated Intake Date on application record                                       |
      | mark.j.mahilum                 | Sept 08, 2023         | DEPP-6479              | Remove CURRENT_INTAKE_PERIOD and NurturingTrackService.isDateWithinRange call      |
      |                                |                       |                        | as it's no longer used                                                             |
      | arsenio.jr.dayrit              | September 07, 2023    | DEPP-5652              | Added handling for Domestic Strong Interest Pre-Application                        |
      | mark.j.mahilum                 | Sept 19, 2023         | DEPP-6677              | Updated name of sales cadence from Domestic Acceptance to Enrollment to            |
      |                                |                       |                        | Domestic Accepted not yet Enrolled                                                 |
      | arsenio.jr.dayrit              | October 03, 2023      | DEPP-6816              | Added handling for International Offer to Acceptance                               |
      | alexander.cadalin              | Oct 3, 2023           | DEPP-6814              | Fixed case detection logic for international strong interest                       |
      | mark.j.mahilum                 | October 04, 2023      | DEPP-6682              | Added new entry criteria for DomesticAcceptedAdmitted sales cadence                |
      | arsenio.jr.dayrit              | October 04, 2023      | DEPP-6834              | Update handling for Domestic Accepted not yet Enrolled                             |
      | arsenio.jr.dayrit              | October 06, 2023      | DEPP-6853              | Update handling for Domestic Strong Interest Pre Application                       |
      | mark.j.mahilum                 | Oct. 06, 2023         | DEPP-6854              | Updated handing for Domestic International Start Date                              |
      | arsenio.jr.dayrit              | Oct. 12, 2023         | DEPP-6901              | Added international citizenship status handling                                    |
      | eccarius.munoz                 | October 16, 2023      | DEPP-6914              | Updated handling for Domestic First Offer (Auto). Changed checking of field        |
      |                                |                       |                        | Admission process. Should be either RTN_DEFER or RTN_QTAC.                         |
      | eccarius.munoz                 | October 16, 2023      | DEPP-6914              | Transffered String literals (Domestic First Offer Auto && Census)                  |
      |                                |                       |                        | to NurtureTrackConfigurationsDAO.                                                  |
      | arsenio.jr.dayrit              | Oct. 19, 2023         | DEPP-6958              | Added Domestic Deffered Offer to Acceptance exit handling                          |
      | arsenio.jr.dayrit              | Nov. 20, 2023         | DEPP-7268              | Added Domestic First Offer to Acceptance entry and exit criteria                   |
      | roy.nino.s.regala              | Jan. 03, 2024         | Shutdown PMD Fix       | Fix cyclomatic complexity issues                                                   |
      | arsenio.jr.dayrit              | Jan. 10, 2024         | DEPP-6958              | Added Domestic Accepted and Admitted exit handling                                 |
      | eccarius.munoz                 | January 22, 2024      | DEPP-7651              | Updated application list used in International Strong Interest exit criteria       |
      | mark.j.mahilum                 | Feb 06, 2024          | DEPP-7862              | Updated entry and exit criteria of (Domestic Accepted not yet enrolled)            |
      | arsenio.jr.dayrit              | Feb 23, 2024          | DEPP-7709              | Update handling for International International Strong Interest Pre –              |
      |                                |                       |                        | Application Entry and International Application Submission - Direct Applicant Entry|
      | arsenio.jr.dayrit              | Feb 29, 2024          | DEPP-7595              | Update handling for Domestic First Offer To Acceptance entry method                |
      |                                |                       |                        | and Domestic Accepted and Admitted entry method                                    | 
      | eccarius.munoz                 | February 29, 2024     | DEPP-7838              | Renamed International Offer to Acceptance (add - Direct) and created new nurture   |
      |                                |                       |                        | track named International Offer to Acceptance - Agent                              |
      | mark.j.mahilum                 | March 04, 2024        | DEPP-7708              | Added new entry and exit criteria for InternationalPreApplicationPartnerSourced    |
      | arsenio.jr.dayrit              | March 21, 2024        | DEPP-8349              | Update handling for Domestic First Offer To Acceptance entry method                |
      |                                |                       |                        | and Domestic Accepted and Admitted entry method                                    | 
      | mark.j.mahilum                 | April 04, 2024        | DEPP-8450              | Updated created date logic to make sure that only the date value is getting match  |
      |                                |                       |                        | to the exact date today                                                            |
      | mark.j.mahilum                 | April 09, 2024        | DEPP-8473              | Updated checkContactWithValidProgramEnrollmentAndQtac to check if contact has no   |
      |                                |                       |                        | related program enrollments                                                        |
      | mark.j.mahilum                 | April 12, 2024        | DEPP-8484              | Updated checkContactWithValidProgramEnrollmentAndQtac to check if contact has no   |
      |                                |                       |                        | latest program enrollment or has no program enrollment = Admitted                  |
      | mark.j.mahilum                 | April 26, 2024        | DEPP-8717              | Remove Program enrollment status date < 12 months from Nurture Tracks              |
 */
public with sharing class NurturingTrackContactService { //NOPMD
    private static List<hed__Application__c> applicationList = new List<hed__Application__c>();
    private static List<hed__Application__c> applicationListForStrongInterest = new List<hed__Application__c>();
    private static Map<Id,hed__Application__c>  samsAppWithQtac = new Map<Id,hed__Application__c>();
    private static Map<String,String> appToQtacMap = new Map<String,String>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackWithOffSetDaysMap = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackForExitWithOffSetDaysMap = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackWithThresholdForEntry = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<Id, Set<String>> applicantIdsWithCompletedCadence = new Map<Id, Set<String>>();
    private static Map<Id, Set<String>> applicantIdsWithAllCompletedCadence = new Map<Id, Set<String>>();
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
    private static final String DOMESTIC_ACCEPTED_AND_ADMITTED = 'Domestic Accepted and Admitted';
    private static final Map<String, Date> CURRENT_INTAKE_PERIOD = NurturingTrackService.getCurrentIntakePeriod();
    private static final Set<String> ALL_CADENCES = new Set<String>{
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED,
        NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE,
        NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED,
        NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
        NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_OFFER_LAPSED_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_OFFER_LAPSED_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED
    };
    private static Map<String,International_Tier__c> InternationalTierRestrictedMap = NurturingTrackService.getAllRestrictedCountry();

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
         *   International Offer to Acceptance - Direct (Original DEPP-5756, New DEPP-7838)
         *   International Acceptance Deposit not Paid (DEPP-5757)
         *   Domestic Accepted not yet Enrolled (DEPP-5758)
         *   Domestic and International Enrolment to Census (DEPP-5760)
         *   Domestic Offer Lapsed (DEPP-5761)
         */

        //Contact entry criteria to process
        contactToUpdate.putall(getDomesticStrongInterestPreApplicationForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalStrongInterestPreApplication(internationalEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalPreApplicationPartnerSourced(internationalEntryContactMap));
        contactToUpdate.putall(getEntryInternationalDirectApplicants(internationalEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalApplicationToOfferDirectAutomated(internationalEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalApplicationToOfferAgentAutomated(internationalEntryContactMap));
        contactToUpdate.putAll(getEntryInternationalApplicationToOffer(internationalEntryContactMap));
        contactToUpdate.putall(getEntryDomesticFirstOffertoAcceptance(domesticEntryContactMap));
        contactToUpdate.putAll(getDomesticDeferredOfferToAcceptanceForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getInternationalOfferToAcceptanceDirectForEntry(internationalEntryContactMap));
        contactToUpdate.putAll(getInternationalOfferToAcceptanceAgentForEntry(internationalEntryContactMap));
        contactToUpdate.putall(getEntryInternationalAcceptanceDepositNotPaid(internationalEntryContactMap));
        contactToUpdate.putAll(getDomesticAcceptanceToEnrollmentForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getEntryDomesticAcceptedAndAdmitted(domesticEntryContactMap));
        contactToUpdate.putAll(getDomesticEnrollmentToCensusForEntry(domesticEntryContactMap));
        contactToUpdate.putAll(getInternationalEnrollmentToCensusForEntry(internationalEntryContactMap));
        contactToUpdate.putall(getEntryDomesticOfferLapsed(domesticEntryContactMap));

        //Contact exit criteria to process
        contactToUpdate.putAll(getDomesticStrongInterestPreApplicationForExit(domesticExitContactMap));
        contactToUpdate.putAll(getExitInternationalStrongInterestPreApplication(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalPreApplicationPartnerSourced(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalDirectApplicants(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalApplicationToOfferDirectAutomated(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalApplicationToOfferAgentAutomated(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalApplicationToOffer(internationalExitContactMap));
        contactToUpdate.putAll(getExitDomesticFirstOffertoAcceptance(domesticExitContactMap));
        contactToUpdate.putAll(getDomesticDeferredOfferToAcceptanceForExit(domesticExitContactMap));
        contactToUpdate.putAll(getExitInternationalOffertoAcceptance(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalOffertoAcceptanceAgent(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalAcceptanceDepositNotPaid(internationalExitContactMap));
        contactToUpdate.putAll(getDomesticAcceptanceToEnrollmentForExit(domesticExitContactMap));
        contactToUpdate.putAll(getExitDomesticAcceptedAndAdmitted(domesticExitContactMap));
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
        applicationListForStrongInterest.addAll(ApplicationsDAO.newInstance()
            .getApplicationsByContactIds(mapOfContacts.keySet(), 'SYSTEM_MODE'));
        getAppsWithLatestCalculatedIntakeDatePerContact(mapOfContacts.keySet());
        getContactRecordCitizenship(mapOfContacts);
        getFilteredNurturingTrackRecords();

        List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance().getCompletedCadenceByTargetIds(mapOfContacts.keySet(),ALL_CADENCES,'SYSTEM_MODE');
        //get all successful completed cadences related to the contact
        applicantIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            mapOfContacts.keySet(),
            completedCadenceList,
            Contact.getSObjectType()
        );

        //get all completed cadences regardless of the status related to the contact
        applicantIdsWithAllCompletedCadence = NurturingTrackService.getApplicantIdsWithAllCompletedCadence(
            mapOfContacts.keySet(),
            completedCadenceList,
            Contact.getSObjectType()
        );

    }

    private static void getAppsWithLatestCalculatedIntakeDatePerContact(Set<Id> contactIds){

        Map<String, hed__Application__c> contactToOnePerApplicationRTMap = new Map<String, hed__Application__c>();
        for(hed__Application__c app : ApplicationsDAO.newInstance()
        .getAppsWithLatestCalculatedIntakeDateByApplicantIds(contactIds, 'SYSTEM_MODE')){
            //gets the contact id + app recordtype string combo
            //make this string combo the key
            //this ensures that application list will only have 1 per contact and app record type
            String contactToAppRTCombo = (String)app.hed__Applicant__c + (String)app.RecordTypeId;
            if(!contactToOnePerApplicationRTMap.containsKey(contactToAppRTCombo)){
                contactToOnePerApplicationRTMap.put(contactToAppRTCombo,app);
            }
        }
        //add all application with unique contact and recordtype
        applicationList.addAll(contactToOnePerApplicationRTMap.values());
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
        Set<String> completedCadencesCopy = new Set<String>();
        Set<Id> contactIdsWithRestricted = getCitizenshipCountryIsRestricted(internationalEntryContactMap.values());
        Set<String> leadSourceCategory = new Set<String>{ContactsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCE};
        for (hed__Application__c application : applicationList) {
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();
            boolean isPartnerSourced = leadSourceCategory.contains(application.hed__Applicant__r.Lead_Source_Category__c);
            boolean hasContactIdsWithRestricted = contactIdsWithRestricted.contains(application.hed__Applicant__c);

            boolean isCriteriaMet = internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                                    application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                                    application.Calculated_Intake_Date__c > System.today() &&
                                    newOrUnsubmittedStatus.contains(application.Application_Status__c) &&
                                    !hasContactIdsWithRestricted &&
                                    !isPartnerSourced &&
                                    //make sure that there are no completed cadence against any succeeding cadence
                                    //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                                    !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_DIRECT_APPLICANT);
            if (isCriteriaMet) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL,
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED,
            NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceMultiple(
            filteredApplicantIdsWithCompletedCadence,
            internationalDirectApplicants.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description Entry Criteria for International Pre-Application - Partner Source Contacts
     * @param Map<Id, Contact> internationEntryContactMap a map of ids to entry international contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryInternationalPreApplicationPartnerSourced(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        
        Map<Id, Set<String>> contactIdsWithCmpltdCadenceSet = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED},
            applicantIdsWithCompletedCadence
        );
        Set<String> completedCadencesCopy = new Set<String>();
        Set<String> leadSourceCategory = new Set<String>{ContactsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCE};
        Set<Id> contactIdsWithActiveApplication = getContactWithApplicationsforXYears(3);

        // Check Contact and Cadence Name if Manual is already Completed
        Set<Id> completedManualCadenceByContactId = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED },
            applicantIdsWithCompletedCadence
        ).keySet();

        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for(Contact internationalEntryContact : internationalEntryContactMap.values()) {
            boolean isPartnerSourced = leadSourceCategory.contains(internationalEntryContact.Lead_Source_Category__c);
            boolean shouldContinueProcessing = contactIdsWithCmpltdCadenceSet.containsKey(internationalEntryContact.Id) && contactIdsWithCmpltdCadenceSet.get(internationalEntryContact.Id).size() >= 2;
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(internationalEntryContact.Id)?new Set<String>(applicantIdsWithAllCompletedCadence.get(internationalEntryContact.Id)):new Set<String>();

            if (shouldContinueProcessing ||
                contactIdsWithActiveApplication.contains(internationalEntryContact.Id) ||
                !isPartnerSourced ||
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_PARTNER_SOURCED)) {
                continue;
            }

            Boolean isManual = !completedManualCadenceByContactId.contains(internationalEntryContact.Id);
            
            contactsToUpdate.put(
                internationalEntryContact.Id,
                new Contact(
                    Id = internationalEntryContact.Id,
                    Calculated_Cadence__c = !isManual ?
                    NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL:
                    NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED
                )
            );
        }
        
        return contactsToUpdate;
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
        Set<String> completedCadencesCopy = new Set<String>();

        for (hed__Application__c application : applicationList) {
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            if (
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Is_Agent_Assisted__c == false &&
                application.Application_Status__c == 'Acceptance - Pending Payment' &&
                NurturingTrackService.isDateWithinRange(
                    application.Calculated_Intake_Date__c,
                    CURRENT_INTAKE_PERIOD.get('START_DATE'),
                    CURRENT_INTAKE_PERIOD.get('END_DATE')
                ) &&
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_ACCEPTANCE_DEPOSIT_NOT_PAID)
            ) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            NurtureTrackConfigurationsDAO.INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
        Set<String> completedCadencesCopy = new Set<String>();

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED },
            applicantIdsWithCompletedCadence
        );

        for (hed__Application__c application : applicationList) {
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            Boolean hasExistingApplication = existingContactIdOnApplication.contains(
                application.hed__Applicant__c
            );
            Boolean hasExistingCompletedCadence = filteredApplicantIdsWithCompletedCadence.containsKey(application.hed__Applicant__c);
            Boolean hasExistingApplicationWithProgram = existingContactIdOnAppWithProgram.contains(
                application.hed__Applicant__c
            );
            Boolean checkForManual = (hasExistingCompletedCadence && hasExistingCompletedCadence);

            //make sure that there are no completed cadence against any succeeding cadence
            //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
            if(completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_NOT_YET_ENROLLED)){
                continue;
            }

            boolean entryForManual = domesticEntryContactMap.containsKey(application.hed__Applicant__c)
            && hasExistingApplication && hasExistingApplicationWithProgram
            && hasExistingCompletedCadence;

            boolean entryForAutomated = domesticEntryContactMap.containsKey(application.hed__Applicant__c) && hasExistingApplication && !checkForManual;

            if (entryForManual) {
                domesticAcceptanceToEnrollmentManual.put(application.Id, application);
            } else if (entryForAutomated) {
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
        Set<Id> existingContactIdOnApplication = new Set<Id>();
        Set<String> completedCadencesCopy = new Set<String>();

        if(!applicationList.isEmpty()){
            existingContactIdOnApplication.addAll(getContactOnApplicationForDomesticDeferredOfferToAcceptanceEntryFilter(
                applicationList,
                'DomesticDeferredOfferToAcceptance'
            ));
        }

        for (hed__Application__c application : applicationList) {
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            Boolean hasExistingApplication = existingContactIdOnApplication.contains(
                application.hed__Applicant__c
            );
            if (
                domesticEntryContactMap.containsKey(application.hed__Applicant__c) &&
                hasExistingApplication &&
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_DEFFERED_OFFER)
            ) {
                domesticDeferredOfferToAcceptanceManual.put(application.Id, application);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL
        );

        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
      public static Map<Id,Contact> getInternationalOfferToAcceptanceDirectForEntry(Map<Id,Contact> internationalEntryContactMap) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> internationalOffertoAcceptanceManual = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated = new Map<Id, hed__Application__c>();
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED },
            applicantIdsWithCompletedCadence
        );
        Set<String> completedCadencesCopy = new Set<String>();

        // To group Automated and Manual Application
        for (hed__Application__c application : applicationList) {
            Boolean hasCompletedCadence = filteredApplicantIdsWithCompletedCadence.containsKey(application.hed__Applicant__c);
            boolean isStudyLinkRecordType = application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            boolean isAgentAssisted = application.Is_Agent_Assisted__c;
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            if (
                isStudyLinkRecordType &&
                !isAgentAssisted &&
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                ApplicationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_FOR_STUDYLINK.contains(application.Application_Status__c) &&
                (application.Calculated_Intake_Date__c != null && application.Calculated_Intake_Date__c > Date.today()) &&
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_OFFER_TO_ACCEPTANCE)
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

    /**
     * @description Validate records and update contacts if criteria is for Entry of International Offer to Acceptance - Agent cadence
     * @param Map<Id,Contact> contactMap contacts to evaluate
     */
    public static Map<Id,Contact> getInternationalOfferToAcceptanceAgentForEntry(Map<Id,Contact> contactMap){

        Set<String> completedCadencesCopy = new Set<String>();
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated = new Map<Id, hed__Application__c>();
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED },
            applicantIdsWithCompletedCadence
        );        

        for (hed__Application__c application : applicationList) {
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            boolean isForProcessing = 
                !filteredApplicantIdsWithCompletedCadence.containsKey(application.hed__Applicant__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Is_Agent_Assisted__c &&
                ApplicationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_FOR_STUDYLINK.contains(application.Application_Status__c) &&
                (application.Calculated_Intake_Date__c != null && application.Calculated_Intake_Date__c > Date.today()) &&
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_OFFER_TO_ACCEPTANCE);
            
            if (isForProcessing) {
                internationalOffertoAcceptanceAutomated.put(application.Id, application);
            }
        }

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(), 
            null,
            NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED
        );

        // Check and Update Contacts Cadence Name
        List<Contact> completedManualCadenceByContactId = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
            internationalOffertoAcceptanceAutomated.values(),
            cadenceWrapper
        );

        if(!completedManualCadenceByContactId.isEmpty()){
            contactToUpdateMap.putAll(completedManualCadenceByContactId);
        }
       
        return contactToUpdateMap;
    }
    
    /**
     * @description Validate records and update contacts if criteria is for Exit of International Offer to Acceptance - Agent cadence
     * @param Map<Id,Contact> contactMap contacts to evaluate
     */
    private static Map<Id, Contact> getExitInternationalOffertoAcceptanceAgent(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();

        for (hed__Application__c application : applicationList) {
            boolean isStudyLinkRecordType = application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            boolean hasCalculatedCadence = application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED;
            boolean isAppStatusValid = ApplicationsDAO.STATUS_SET_ACCEPTS_DECLINES_DEFERS_OFFER.contains(application.Application_Status__c);
            if (
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                isStudyLinkRecordType &&
                isAppStatusValid &&
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

    private static void processCompletedInternationalOffertoAcceptanceAutomated(hed__Application__c application, Map<Id, hed__Application__c> internationalOffertoAcceptanceAutomated, Boolean hasCompletedCadence){
        if( !hasCompletedCadence){
            internationalOffertoAcceptanceAutomated.put(application.Id, application);
        }
    }

    private static void processCompletedInternationalOffertoAcceptanceManual(hed__Application__c application, Map<Id,hed__Application__c> internationalOffertoAcceptanceManual, Boolean hasCompletedCadence){
        if( 
            hasCompletedCadence &&
            nurturingTrackWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL) &&
            nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL).Key_Date_Offset_Days__c != null &&
            application.Offer_Status_Date__c != null && application.Offer_Status_Date__c.addDays((Integer)nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL).Key_Date_Offset_Days__c) == System.today()
        ){
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(), null,
                                                                                                                                    NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED);

        // Check and Update Contacts Cadence Name
        List<Contact> completedManualCadenceByContactId = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
        Map<Id, Set<String>> applicantWithCompletedCadenceAutomated = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED
            },
            applicantIdsWithCompletedCadence
        );

        Map<Id, hed__Application__c> latesetApplicationForManualCadence = new Map<Id, hed__Application__c>();

        // Get only the contact application that needs to be inserted if Automated is Completed
        for(Id applicationId : internationalOffertoAcceptanceManual.keySet()){
            hed__Application__c application = internationalOffertoAcceptanceManual.get(applicationId);

            if (applicantWithCompletedCadenceAutomated.containsKey(application.hed__Applicant__c)) {
                latesetApplicationForManualCadence.put(applicationId, application);
            }
        }

        // Check Contact and Cadence Name if Manual is already Completed
        Map<Id, Set<String>> applicantWithCompletedCadenceManual = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(),
                                                                                                        '',
                                                                                                        NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL);

        // Check and Update Contacts Cadence Name
        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicantWithCompletedCadenceManual,
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

        for (hed__Application__c application : applicationList) {
            boolean isStudyLinkRecordType = application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            Boolean hasCalculatedCadence =
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED) ||
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL);
            boolean isAppStatusValid = ApplicationsDAO.STATUS_SET_ACCEPTS_DECLINES_DEFERS_OFFER.contains(application.Application_Status__c);
            if (
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                isStudyLinkRecordType &&
                isAppStatusValid &&
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
        Set<String> completedCadencesCopy = new Set<String>();
        Set<String> succeedingTrackToCheck = isDomestic?NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_CENSUS:new Set<String>();


        for (hed__Application__c application : filteredApplicationList) {

            boolean isOfferedProgramPlanAvailable = (application.Offered_Program_Plan__c != NULL && application.Offered_Program_Plan__r.Availability_Start_Date__c != NULL);
			Date keyOffsetDaysFromToday = null;

            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            if(nurturingTrackWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE)){
               keyOffsetDaysFromToday = Date.today().addDays((Integer)nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE)?.Key_Date_Offset_Days__c);
            }

            boolean isAppForEntry = validateAppRecordTypeForEnrollmentToCensus(isDomestic, application) &&
                                    isOfferedProgramPlanAvailable &&
                                    keyOffsetDaysFromToday != NULL &&
                                    application.Offered_Program_Plan__r.Availability_Start_Date__c <= keyOffsetDaysFromToday &&
                                    //make sure that there are no completed cadence against any succeeding cadence
                                    //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                                    !completedCadencesCopy.removeAll(succeedingTrackToCheck);

            if (isAppForEntry) {
                applicationMap.put(application.Id, application);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            contactMap.keySet(),
            new List<String>{NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE},
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            NurtureTrackConfigurationsDAO.DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED) ||
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL);
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
        Set<Id> existingContactIdOnApplicationToExit = new Set<Id>();

        if(!applicationList.isEmpty()){
            existingContactIdOnApplicationToExit.addAll(getDomesticAcceptanceToEnrollmentExitFilter(
                applicationList,
                'DomesticAcceptanceToEnrollment'
            ));
        }

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
        Set<Id> existingContactIdOnApplicationToExit = new Set<Id>();

        if(!applicationList.isEmpty()){
            existingContactIdOnApplicationToExit.addAll(getDomesticDeferredOfferToAcceptanceExitFilter(
                applicationList,
                'DomesticDeferredOfferToAcceptance'
            ));
        }

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
                application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL;
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
        Boolean isProgramEnrollmentStatusNotAdmitted = (app.Program_Enrollment__c != NULL && app.Program_Enrollment__r.Enrollment_Status__c !='Admitted');
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                isProgramEnrollmentStatusNotAdmitted &&
                app.Related_QTAC_Application__c != null &&
                app.Related_QTAC_Application__r.Offer_Status__c == 'Accepted' &&
                app.Related_QTAC_Application__r.Is_Active__c
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
            boolean isCriteriaMet = (isSAMSLegacyRecType || isSAMSCiRecType) &&
                                    (app.Admission_Process__c == ApplicationsDAO.ADMISSION_PROCESS_RTN_DEFER ||
                                    app.Admission_Process__c == ApplicationsDAO.ADMISSION_PROCESS_RTN_QTAC) &&
                                    app.Offer_Status__c == ApplicationsDAO.STATUS_OFFERED &&
                                    app.Offered_Program_Plan__r.Availability_Start_Date__c != null &&
                                    nurturingTrackWithOffSetDaysMap.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL) &&
                                    app.Offered_Program_Plan__r.Availability_Start_Date__c.addDays(-(Integer) nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL)?.Key_Date_Offset_Days__c) <= System.today() &&
                                    app.Offered_Program_Plan__r.Availability_Start_Date__c >= System.today();
            if (isCriteriaMet) {
                contactHasApplicationForEntry.add(app.hed__Applicant__c);
            }
        }
    }

    private static void processDomesticAcceptanceToEnrollmentExitCriteria(
        hed__Application__c app,
        String methodName,
        Set<Id> contactHasApplicationForExit
    ) {
        Boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
        Boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        Boolean hasCalculatedCadence =
            (app.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED) ||
            (app.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL);
        Boolean isProgramEnrollmentAdmitted = app.Program_Enrollment__r?.Enrollment_Status__c =='Admitted';
        Boolean isDeferredDeclined = app.Offer_Status__c == 'Deferred' || app.Offer_Status__c == 'Declined';
        Boolean isWithdrawn = app.Application_Status__c == ApplicationsDAO.STATUS_WITHDRAWN;
        Boolean isExiting = (
            (isSAMSLegacyRecType || isSAMSCiRecType) &&
            hasCalculatedCadence &&
            (isProgramEnrollmentAdmitted || isDeferredDeclined || isWithdrawn)
        );
        if (methodName == DOMESTIC_ACCEPTANCE_TO_ENROLLMENT && isExiting) {
            contactHasApplicationForExit.add(app.hed__Applicant__c);
        }
    }

    private static void processDomesticDeferredOfferToAcceptanceExitCriteria(
        hed__Application__c app,
        String methodName,
        Set<Id> contactHasApplicationForExit
    ) {
        Set<String> applicationOfferStatus = new Set<String>{'Accepted', 'Declined', 'Rescinded', 'Lapsed','Unoffered'};
        boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
        boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
        Boolean hasCalculatedCadence =
                app.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL;
        if (methodName == DOMESTIC_DEFFERED_OFFER_TO_ACCEPTANCE) {
            if (
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                applicationOfferStatus.contains(app.Offer_Status__c) &&
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED
        );

        List<Contact> contactToUpdateListAutomated = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL
        );

        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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

        List<hed__Application__c> filteredApplicationList = new List<hed__Application__c>();
        List<hed__Course_Enrollment__c> courseEnrollmentList = CourseConnectionsDAO.newInstance().getCourseConnectionByProgramEnrollmentIds(filteredProgramEnrollmentIds, 'USER_MODE');
        for(hed__Course_Enrollment__c courseEnrollment : courseEnrollmentList){
            if(contactFromAppWithProgramEnrollmentMap.containsKey(courseEnrollment.hed__Contact__c) && courseEnrollment.Enrollment_Status__c != 'Enrolled'){
                filteredApplicationList.add(contactFromAppWithProgramEnrollmentMap.get(courseEnrollment.hed__Contact__c));
            }
        }

        return filteredApplicationList;
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
        Set<String> completedCadencesCopy = new Set<String>();
        Set<Id> applicationProgramUnderGrad = getapplicationProgramUnderGrad(applicationList);
        Map<String,String> contactWithNoCurrentProgramEnrollmentMap = new Map<String,String>();
        Map<String,String> contactWithNoCurrentAdmittedProgramEnrollmentMap = new Map<String,String>();
        Set<Id> contactWithProgramEnrollments = new Set<Id>();
		
        List<hed__Program_Enrollment__c> contactProgramEnrollments = getRelatedContactProgramEnrollments(domesticEntryContactMap.keySet());
        checkContactWithValidProgramEnrollmentAndQtac(contactProgramEnrollments, contactWithNoCurrentProgramEnrollmentMap,contactWithNoCurrentAdmittedProgramEnrollmentMap);

        
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED },
            applicantIdsWithCompletedCadence
        );
        // To group Automated and Manual Application
        for (hed__Application__c application : applicationList) {
            
            boolean isApplicationProgramUnderGrad = applicationProgramUnderGrad.contains(application.Id);
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            boolean isValidRecordType = application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isValidAdmissionProcess =   application.Admission_Process__c != ApplicationsDAO.ADMISSION_PROCESS_RTN_DEFER &&
                                                application.Admission_Process__c != ApplicationsDAO.ADMISSION_PROCESS_RTN_QTAC;
            boolean isContactWithNoCurrentOrNoProgramEnrollmentAtAll = application.Related_QTAC_Application__c != null && !contactWithProgramEnrollments.contains(application.hed__Applicant__c);


            boolean isContactWithProgramEnrollmentNotAdmittedORWithQtact = (application.Related_QTAC_Application__c != null || 
                                                                            isContactWithNoCurrentOrNoProgramEnrollmentAtAll) ||
                                                                           (application.Related_QTAC_Application__c == null &&
                                                                           contactWithNoCurrentAdmittedProgramEnrollmentMap.containsKey(application.hed__Applicant__c));

            boolean isAppForEntry = isValidRecordType &&
                                    domesticEntryContactMap.containsKey(application.hed__Applicant__c) &&
                                    application.Offer_Status__c == ApplicationsDAO.STATUS_OFFERED &&
                                    isValidAdmissionProcess &&
                                    application.hed__Application_Date__c != null &&
                                    isContactWithProgramEnrollmentNotAdmittedORWithQtact &&
                                    //make sure that there are no completed cadence against any succeeding cadence
                                    //this should return true if one of the succeeding cadence is already in completedCadencesCopy
                                    !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_FIRST_OFFER) &&
                                    isApplicationProgramUnderGrad;
        
            if (isAppForEntry) {

                Boolean hasAutomatedCompletedCadence = filteredApplicantIdsWithCompletedCadence.containsKey(application.hed__Applicant__c);

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

        Set<String> offerStatus = new Set<String>{ 'Accepted', 'Declined', 'Deferred', 'Lapsed', 'Admitted'};

        for (hed__Application__c application : applicationList) {
            boolean isSAMSLegacyRecType =
                application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType =
                application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            Boolean hasCalculatedCadence =
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED) ||
                (application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_MANUAL);
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

        // tactical fix - by removing this condition manual cadence doesn't depend on a completed automated cadence
        // if (hasAutomatedCompletedCadence){
            domesticFirstOffertoAcceptanceManual.put(application.Id, application); // Group Manual Application
        // } else {
        //     domesticFirstOffertoAcceptanceAutomated.put(application.Id, application); // Group Automated Application
        // }
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED
        );

        // Check and Update Contacts Cadence Name
        List<Contact> completedManualCadenceByContactId = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
        // tactical fix - by removing this condition manual cadence doesn't depend on a completed automated cadence
        // Check Contact and Cadence Name if Automated is already Completed
        // Map<Id, Set<String>> applicantIdsWithCompletedCadenceAutomated = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
        //     domesticEntryContactMap.keySet(),
        //     new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED },
        //     applicantIdsWithCompletedCadence
        // );

        //Map<Id, hed__Application__c> latesetApplicationForManualCadence = new Map<Id, hed__Application__c>();

        // Get only the contact application that needs to be inserted if Automated is Completed
        // for (Id applicationId : latestApplicationManual.keySet()) {
        //     hed__Application__c application = latestApplicationManual.get(applicationId);

        //     if (applicantIdsWithCompletedCadenceAutomated.containsKey(application.hed__Applicant__c)) {
        //         latesetApplicationForManualCadence.put(applicationId, application);
        //     }
        // }

        // Check Contact and Cadence Name if Manual is already Completed
        Map<Id, Set<String>> applicantIdsWithCompletedCadenceManual = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_MANUAL },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            NurtureTrackConfigurationsDAO.DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_MANUAL
        );

        // Check and Update Contacts Cadence Name
        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            applicantIdsWithCompletedCadenceManual,
            //latesetApplicationForManualCadence.values(),
            latestApplicationManual.values(),
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
        Double offsetDays = nurturingTrackWithOffSetDaysMap.get(NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL)?.Key_Date_Offset_Days__c;
        Map<Id, hed__Application__c> internationalApplicantsToOffer = new Map<Id, hed__Application__c>();
        Set<String> completedCadencesCopy = new Set<String>();
        for (hed__Application__c application : applicationList) {
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)):new Set<String>();

            Boolean withinOffSetDays = false;
            if(
                offsetDays != null &&
                application.Calculated_Intake_Date__c  != null
            ){
                withinOffSetDays = setwithinOffSetDays(application, offsetDays);
            }
            if (checkAppInternationalApplicationToOffer(application) &&
                internationalEntryContactMap.containsKey(application.hed__Applicant__c) &&
                withinOffSetDays &&
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_APP_TO_OFFER)
            ) {
            	internationalApplicantsToOffer.put(application.Id, application);
            }
        }
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            '',
            NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
            internationalApplicantsToOffer.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description Update entering international application to offer DIRECT automated applications
     * @param Map<Id, Contact> internationEntryContactMap a map of ids to entry international contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryInternationalApplicationToOfferDirectAutomated(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Map<Id, hed__Application__c> directApplicantsToOffer = new Map<Id, hed__Application__c>();
        Set<String> completedCadencesCopy = new Set<String>();
        for(hed__Application__c application : applicationList) {
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c) ?
                new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)) : new Set<String>();
            Boolean isPassedCriteria = 
                (application.Calculated_Intake_Date__c != null && application.Calculated_Intake_Date__c > Date.today()) &&
                (application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID) &&
                (ApplicationsDAO.INTL_ENTRY_APPLICATION_TO_OFFER_STATUSES_FOR_STUDYLINK.contains(application.Application_Status__c)) &&
                (application.Is_Agent_Assisted__c == false) &&
                (!completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_APPLICATION_TO_OFFER_AUTO));
            if(isPassedCriteria) {
                directApplicantsToOffer.put(application.Id, application);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED,
            null
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence, 
            directApplicantsToOffer.values(), 
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description Update exiting international application to offer DIRECT automated applications
     * @param Map<Id, Contact> internationalExitContactMap - A map of ids to exit international contact records
     * @return Map<Id, Contact> A map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getExitInternationalApplicationToOfferDirectAutomated(
        Map<Id, Contact> internationalExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdating = new Map<Id, Contact>();
        for(hed__Application__c application : applicationList) {
            if(
                application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED &&
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                ApplicationsDAO.EXIT_STATUSES_INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTO.contains(application.Application_Status__c)
            ) {
                contactsForUpdating.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }

        return contactsForUpdating;
    }

    /**
     * @description Update entering international application to offer AGENT automated applications
     * @param Map<Id, Contact> internationEntryContactMap a map of ids to entry international contact records
     * @return Map<Id, Contact> map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getEntryInternationalApplicationToOfferAgentAutomated(
        Map<Id, Contact> internationalEntryContactMap
    ) {
        Map<Id, hed__Application__c> directApplicantsToOffer = new Map<Id, hed__Application__c>();
        Set<String> completedCadencesCopy = new Set<String>();
        for(hed__Application__c application : applicationList) {
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(application.hed__Applicant__c) ?
                new Set<String>(applicantIdsWithAllCompletedCadence.get(application.hed__Applicant__c)) : new Set<String>();
            Boolean isPassedCriteria = 
                (application.Calculated_Intake_Date__c != null && application.Calculated_Intake_Date__c > Date.today()) &&
                (application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID) &&
                (ApplicationsDAO.INTL_ENTRY_APPLICATION_TO_OFFER_STATUSES_FOR_STUDYLINK.contains(application.Application_Status__c)) &&
                (application.Is_Agent_Assisted__c == true) &&
                (!completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_APPLICATION_TO_OFFER_AUTO));
            if(isPassedCriteria) {
                directApplicantsToOffer.put(application.Id, application);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED,
            null
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence, 
            directApplicantsToOffer.values(), 
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description Update exiting international application to offer DIRECT automated applications
     * @param Map<Id, Contact> internationalExitContactMap - A map of ids to exit international contact records
     * @return Map<Id, Contact> A map of id to updated contact records for batch processing
     */
    private static Map<Id, Contact> getExitInternationalApplicationToOfferAgentAutomated(
        Map<Id, Contact> internationalExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdating = new Map<Id, Contact>();
        for(hed__Application__c application : applicationList) {
            if(
                application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED &&
                internationalExitContactMap.containsKey(application.hed__Applicant__c) &&
                ApplicationsDAO.EXIT_STATUSES_INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTO.contains(application.Application_Status__c)
            ) {
                contactsForUpdating.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }

        return contactsForUpdating;
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
        Set<Id> existingContactIdOnApplication = getContactOnApplicationForDomesticStrongInterestPreApplicationEntryFilter(applicationListForStrongInterest,domesticEntryContactMap.keySet());
        Set<Id> existingCaseFromContact = getCaseRecordsFromContact(domesticEntryContactMap.keySet());
        Set<Id> contactIdsWithApplication = getContactIdsWithApplication(applicationList);
        Set<String> completedCadencesCopy = new Set<String>();
        Map<Id, Set<String>> contactsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            applicantIdsWithCompletedCadence
        );

        Map<Id, Set<String>> contactsWithCompletedCadenceManual = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL },
            applicantIdsWithCompletedCadence
        );

        for (Contact contact : domesticEntryContactMap.values()){
            Boolean contacHasExistingApplication = contactIdsWithApplication.contains(contact.Id);
            Boolean hasInActiveApplication = existingContactIdOnApplication.contains(contact.Id);
            Boolean hasExistingCaseFromContact = existingCaseFromContact.contains(contact.Id);
            Boolean hasExistingCompletedCadence = contactsWithCompletedCadence.containsKey(contact.Id);
            Boolean hasExistingCompletedCadenceManual = contactsWithCompletedCadenceManual.containsKey(contact.Id);

            Decimal threshold = NurturingTrackService.selectThreshold(
                nurturingTrackWithThresholdForEntry, 
                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                hasExistingCompletedCadence
            );

            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(contact.Id)?new Set<String>(applicantIdsWithAllCompletedCadence.get(contact.Id)):new Set<String>();
            
            Boolean isCriteriaMet = (!contacHasExistingApplication || hasInActiveApplication) &&
                                    hasExistingCaseFromContact &&
                                    !hasExistingCompletedCadenceManual &&
                                    contact.Lead_Score__c >= threshold && // ... has a lead score above threshold...
                                    //make sure that there are no completed cadence against any succeeding cadence
                                    //this should return true if one of the succeeding cadence is already in completedCadencesCopy
                                    !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_STRONG_INTEREST);
            if (isCriteriaMet)
            {
                contactToUpdateMap.put(
                        contact.Id,
                        new Contact(
                            Id = contact.Id,
                            Calculated_Cadence__c = hasExistingCompletedCadence ?
                                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL :
                                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
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
        Set<String> completedCadencesCopy = new Set<String>();
        Set<Id> applicationProgramUnderGrad = getapplicationProgramUnderGrad(applicationList);
        Map<String,String> contactWithNoCurrentProgramEnrollmentMap = new Map<String,String>();
        Map<String,String> contactWithNoCurrentAdmittedProgramEnrollmentMap = new Map<String,String>();
        Set<Id> contactWithProgramEnrollments = new Set<Id>();
        
        List<hed__Program_Enrollment__c> contactProgramEnrollments = getRelatedContactProgramEnrollments(domesticEntryContactMap.keySet());
        
        checkContactWithValidProgramEnrollmentAndQtac(contactProgramEnrollments,contactWithNoCurrentProgramEnrollmentMap,contactWithNoCurrentAdmittedProgramEnrollmentMap);

        for (hed__Application__c app : applicationList) {
            
            Boolean isSAMSApplication = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            Boolean isProgramEnrollmentAdmitted = (app.Program_Enrollment__c != NULL && String.isNotBlank(app.Program_Enrollment__r.Enrollment_Status__c));
            Boolean isSAMSLatestApplication = (app.Calculated_Intake_Date__c != NULL && app.Calculated_Intake_Date__c >= Date.today());
            boolean isApplicationProgramUnderGrad = applicationProgramUnderGrad.contains(app.Id);
            boolean isContactWithProgramEnrollmentNotAdmittedORWithQtact = (app.Related_QTAC_Application__c != null &&
                                                                            app.Related_QTAC_Application__r.Offer_Status__c == 'Accepted') ||
                                                                           (app.Related_QTAC_Application__c == null &&
                                                                            contactWithNoCurrentAdmittedProgramEnrollmentMap.containsKey(app.hed__Applicant__c));

            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(app.hed__Applicant__c)?new Set<String>(applicantIdsWithAllCompletedCadence.get(app.hed__Applicant__c)):new Set<String>();

            boolean isAppForEntry = isSAMSApplication &&
                                    domesticEntryContactMap.containsKey(app.hed__Applicant__c) &&
                                    isProgramEnrollmentAdmitted &&
                                    isSAMSLatestApplication &&
                                    app.Program_Enrollment__r.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED &&
                                    isContactWithProgramEnrollmentNotAdmittedORWithQtact &&
                                    //make sure that there are no completed cadence against any succeeding cadence
                                    //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                                    !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_ACCEPTED_ADMITTED) &&
                                    isApplicationProgramUnderGrad;
            if (isAppForEntry) {
                domesticAcceptedApplicants.put(app.Id, app);
            }
        }

        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL
        );

        List<Contact> contactToUpdateList = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
            domesticAcceptedApplicants.values(),
            cadenceWrapper
        );

        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>(contactToUpdateList);
        return contactToUpdateMap;
    }

    /**
     * @description  Update contact with the “Domestic Accepted and Admitted” when the entry criteria is fulfilled.
     * @param Map<Id, Contact> domesticExitContactMap
     * @return Map<Id, Contact> map of id to contact for batch processing
     */
    private static Map<Id, Contact> getExitDomesticAcceptedAndAdmitted(
        Map<Id, Contact> domesticExitContactMap
    ) {
        Map<Id, Contact> contactsForUpdatingMap = new Map<Id, Contact>();
        Set<Id> contactIdWithAcceptedAndAdmittedCadence = checkContactsWithAcceptedAndAdmittedCadence(domesticExitContactMap.values());
        Set<String> offerStatus = new Set<String>{'Deferred'};

        for (hed__Application__c application : applicationList) {
            boolean isSAMSLegacyRecType = application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isContactIdWithAcceptedAndAdmittedCadence = contactIdWithAcceptedAndAdmittedCadence.contains(application.hed__Applicant__c);
            boolean isProgramEnrollmentWithdrawn = ProgramEnrollmentsDAO.ENROLLMENT_STATUSES_WITHDRAWN.contains(application.Program_Enrollment__r.Enrollment_Status__c);
            boolean isExiting = (
                domesticExitContactMap.containsKey(application.hed__Applicant__c) &&
                (isSAMSLegacyRecType || isSAMSCiRecType) &&
                isContactIdWithAcceptedAndAdmittedCadence && (           
                    offerStatus.contains(application.Offer_Status__c) ||
                    isProgramEnrollmentWithdrawn
                )
            );
            if (isExiting) {
                contactsForUpdatingMap.put(
                    application.hed__Applicant__c,
                    new Contact(Id = application.hed__Applicant__c, Calculated_Cadence__c = '')
                );
            }
        }
        return contactsForUpdatingMap;
    }

    private static Set<Id> checkContactsWithAcceptedAndAdmittedCadence(List<Contact> contacts){
        Set<Id> contactIdWithAcceptedAndAdmittedCadence = new Set<Id>();
        for(Contact con : contacts){
            if(con.Calculated_Cadence__c != null && con.Calculated_Cadence__c == DOMESTIC_ACCEPTED_AND_ADMITTED){
                contactIdWithAcceptedAndAdmittedCadence.add(con.Id);
            }
        }

        return contactIdWithAcceptedAndAdmittedCadence;
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
        Set<Id> existingContactIdOnApplicationToExit = new Set<Id>();
        List<String> cadenceNames = new List<String>{
            NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
            NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL
        };

        if(!applicationList.isEmpty()){
            existingContactIdOnApplicationToExit.addAll(getContactOnApplicationForDomesticStrongInterestPreApplicationExitFilter(
                applicationListForStrongInterest
            ));
        }
        for (Id contactId : domesticExitContactMap.keySet()) {
            Boolean hasExistingApplicationToExit = existingContactIdOnApplicationToExit.contains(
                contactId
            );
            //check if current contact is in domestic strong interest cadence
            if ( cadenceNames.contains(domesticExitContactMap.get(contactId).Calculated_Cadence__c) &&
                (hasExistingApplicationToExit || domesticExitContactMap.get(contactId).HasOptedOutOfEmail)) {
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            applicantIdsWithCompletedCadence
        );
        for (hed__Application__c app : applicationList) {
            boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            if(isSAMSLegacyRecType || isSAMSCiRecType){
                processSamsDomesticStrongInterestPreApplicationEntryCriteria(app,contactHasApplicationForEntry,filteredApplicantIdsWithCompletedCadence.containsKey(app.hed__Applicant__c));
            }
            else if(isQTACRecType){
                processQtacDomesticStrongInterestPreApplicationEntryCriteria(app,contactHasApplicationForEntry,filteredApplicantIdsWithCompletedCadence.containsKey(app.hed__Applicant__c));
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
            (app.CreatedDate.Date() <= Date.Today() && app.CreatedDate.Date() >= Date.Today().addYears(-3))
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
            (app.CreatedDate.Date() <= Date.Today() && app.CreatedDate.Date() >= Date.Today().addYears(-3))
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = new Map<Id, Set<String>>();

        if(nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED)){
            filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
                domesticEntryContactMap.keySet(),
                new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
                applicantIdsWithCompletedCadence
            );
            caseList = CasesDAO.newInstance().getCasesByContactIds(contactIds, AccessLevel.SYSTEM_MODE);
        }

        for(Case caseRec : caseList){
            if(!filteredApplicantIdsWithCompletedCadence.containsKey(caseRec.ContactId) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromContactIds.add(caseRec.ContactId);
            }
            else if(filteredApplicantIdsWithCompletedCadence.containsKey(caseRec.ContactId) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromContactIds.add(caseRec.ContactId);
            }
        }
        return caseFromContactIds;
    }

    private static boolean checkCaseCreatedDate(Case caseRec){
        return (caseRec.CreatedDate.Date() <= Date.Today() && caseRec.CreatedDate.Date() >= Date.Today().addMonths(-3) && caseRec.Category__c != null);
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
            // Check if today's date is greater than the application last admission date
            Boolean isTodayGreaterThanLastAdmissionDate = Date.today() >= application.Applied_Intake_Study_Period__r.Last_Admission_Date__c;

            if (
                isSAMSApplicant &&
                hasDomesticOfferLapsedCadence &&
                domesticExitContactMap.containsKey(application.hed__Applicant__c) &&
                application.Offer_Status__c != 'Lapsed' &&
                isTodayGreaterThanLastAdmissionDate
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
                application.hed__Applicant__r.Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL &&
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
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ DOMESTIC_OFFER_LAPSED_AUTOMATED },
            applicantIdsWithCompletedCadence
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
                filteredApplicantIdsWithCompletedCadence.containsKey(application.hed__Applicant__c)
            ) {
                applicantManual.put(application.Id, application);
            }
        }
    }

    private static void processApplicantAutomated(
        Map<Id, hed__Application__c> applicantAutomated,
        Map<Id, Contact> contactsToUpdateMap
    ) {
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ DOMESTIC_OFFER_LAPSED_AUTOMATED },
            applicantIdsWithCompletedCadence
        );
        NurturingTrackService.CadenceWrapper cadenceWrapperAutomated = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            DOMESTIC_OFFER_LAPSED_AUTOMATED,
            null
        );
        List<Contact> contactToUpdateListAutomated = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
            applicantAutomated.values(),
            cadenceWrapperAutomated
        );
        contactsToUpdateMap.putAll(new Map<Id, Contact>(contactToUpdateListAutomated));
    }

    private static void processApplicantManual(
        Map<Id, hed__Application__c> applicantManual,
        Map<Id, Contact> contactsToUpdateMap
    ) {
        Map<Id, Set<String>> filteredApplicantIdsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryContactMap.keySet(),
            new List<String>{ DOMESTIC_OFFER_LAPSED_MANUAL },
            applicantIdsWithCompletedCadence
        );
        NurturingTrackService.CadenceWrapper cadenceWrapperManual = new NurturingTrackService.CadenceWrapper(
            Contact.getSObjectType(),
            null,
            DOMESTIC_OFFER_LAPSED_MANUAL
        );
        List<Contact> contactToUpdateListManual = (List<Contact>) NurturingTrackService.populateCalculatedCadenceSingle(
            filteredApplicantIdsWithCompletedCadence,
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
        Map<Id, Set<String>> contactIdsWithCmpltdCadenceSet = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED},
            applicantIdsWithCompletedCadence
        );
        Set<String> completedCadencesCopy = new Set<String>();
        Set<Id> contactIdsWithRestricted = getCitizenshipCountryIsRestricted(internationalEntryContactMap.values());
        Set<String> leadSourceCategory = new Set<String>{ContactsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCE};

        // Check Contact and Cadence Name if Manual is already Completed
        Set<Id> completedManualCadenceByContactId = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryContactMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            applicantIdsWithCompletedCadence
        ).keySet();

        Map<Id, List<String>> contactIdToCaseCategoriesMap = NurturingTrackService.getApplicantIdToRelatedCaseCategoriesMap(internationalEntryContactMap.keySet(), 3);
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for(Contact internationalEntryContact : internationalEntryContactMap.values()) {
            boolean isPartnerSourced = leadSourceCategory.contains(internationalEntryContact.Lead_Source_Category__c);
            boolean hasContactIdsWithRestricted = contactIdsWithRestricted.contains(internationalEntryContact.Id);
            boolean shouldContinueProcessing = contactIdsWithCmpltdCadenceSet.containsKey(internationalEntryContact.Id) && contactIdsWithCmpltdCadenceSet.get(internationalEntryContact.Id).size() >= 2;
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(internationalEntryContact.Id)?new Set<String>(applicantIdsWithAllCompletedCadence.get(internationalEntryContact.Id)):new Set<String>();

            if (shouldContinueProcessing ||
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_STRONG_INTEREST)) {
                continue;
            }

            Boolean isManual = !completedManualCadenceByContactId.contains(internationalEntryContact.Id);
            Decimal threshold = NurturingTrackService.selectThreshold(
                intlEntryStrongInterestPreAppConfigs,
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                isManual
            );
            List<String> l1Categories = NurturingTrackService.selectL1Categories(
                intlEntryStrongInterestPreAppConfigs,
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                isManual
            );
            List<String> relatedCaseCategories = contactIdToCaseCategoriesMap.get(internationalEntryContact.Id);
            boolean isCriteriaMet = isContactWithNoActiveStudyLinkAppforXYears(internationalEntryContact, 3) &&
                                    internationalEntryContact.Lead_Score__c > threshold &&  
                                    NurturingTrackService.isRelatedCaseCategoriesContainsL1Categories(l1Categories,relatedCaseCategories) &&
                                    !hasContactIdsWithRestricted &&
                                    !isPartnerSourced;
            if(isCriteriaMet) {

                contactsToUpdate.put(
                    internationalEntryContact.Id,
                    new Contact(
                        Id = internationalEntryContact.Id,
                        Calculated_Cadence__c = !isManual ?
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL:
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
                    )
                );
            }
        }
        return contactsToUpdate;
    }

    /**
     * Retrieves international exit contacts sourced through partner for pre-application nurturing.
     * Checks if the contact's cadence is within specified types and if they have an active application 
     * within the last three years or have opted out of email communication. Contacts meeting these 
     * criteria are prepared for update with the calculated cadence field reset.
     * 
     * @param internationalExitContactMap A map of Contact Ids to Contact records representing 
     *                                    international exit contacts.
     * @return Map<Id, Contact> A map of Contact Ids to Contact records ready for update.
     */    
    private static Map<Id, Contact> getExitInternationalPreApplicationPartnerSourced(Map<Id, Contact> internationalExitContactMap) {
        List<String> cadenceNames = new List<String>{
            NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
            NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED
        };
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        
        // Iterate through the list of applications
        for(hed__Application__c application : applicationListForStrongInterest) {
            
            if(!internationalExitContactMap.containsKey(application.hed__Applicant__c)){
                continue;
            }
            
            // Check if the application falls under specific record types
            Boolean isStudylinkORSamsRecType = application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
                application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID ||
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            
            // Check if the application was created within the specified time range
            Boolean isInitiallyCreatedWithinTimeRange =
                application.CreatedDate.Date() <= Date.Today() &&
                application.CreatedDate.Date() >= Date.Today().addYears(-3);
            
            // get contact related to application
            Contact relatedContact = internationalExitContactMap.get(application.hed__Applicant__c);
            
            // If the application meets both criteria, add the associated contact ID to the set
            if(
                isStudylinkORSamsRecType &&
                cadenceNames.contains(relatedContact.Calculated_Cadence__c) && 
                isInitiallyCreatedWithinTimeRange &&
                application.Application_Status__c =='Submitted'
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

    private static Set<Id> getapplicationProgramUnderGrad(List<hed__Application__c> applications){
        Set<Id> applicationWithProgramLevelUnderGradIdSet = new Set<Id>();
        for(hed__Application__c app : applications){
            if(app.Offered_Program_Plan__c != null && app.Offered_Program_Plan__r.Program_Level__c == 'Undergraduate'){
                applicationWithProgramLevelUnderGradIdSet.add(app.Id);
            }
        }
        return applicationWithProgramLevelUnderGradIdSet;
    }

    private static Map<Id, Contact> getExitInternationalStrongInterestPreApplication(Map<Id, Contact> internationalExitContactMap) {
        List<String> cadenceNames = new List<String>{
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL
        };
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for(hed__Application__c application : applicationListForStrongInterest) {
            Contact relatedContact = internationalExitContactMap.get(application.hed__Applicant__c);

            Boolean isActiveApplication = 
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Application_Status__c != null && 
                !ApplicationsDAO.STUDYLINK_TERMINAL_STATUSES.contains(application.Application_Status__c);

            if(
                relatedContact != null &&
                cadenceNames.contains(relatedContact.Calculated_Cadence__c) && 
                (isActiveApplication || relatedContact.HasOptedOutOfEmail)
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
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL},
            'SYSTEM_MODE'
        )) {
            if(config.Criteria_Type__c == 'Entry') {
                configsMap.put(config.Cadence_Name__c, config);
            }
        }
        return configsMap;
    }

    private static Set<Id> getCitizenshipCountryIsRestricted(List<Contact> conList){
        Set<Id> contactIdsWithRestrictedSet = new Set<Id>();
        for(Contact contact : conList){
            if(!InternationalTierRestrictedMap.isEmpty() && InternationalTierRestrictedMap.containsKey(contact.Citizenship_Country__c)){
                contactIdsWithRestrictedSet.add(contact.Id);
            }
        }
        return contactIdsWithRestrictedSet;
    }
    private static void checkContactWithValidProgramEnrollmentAndQtac(List<hed__Program_Enrollment__c> programEnrollments,
                                                                      Map<String,String> contactWithNoCurrentProgramEnrollmentMap, 
                                                                      Map<String,String> contactWithNoCurrentAdmittedProgramEnrollmentMap
                                                                     ){
        if(!programEnrollments.isEmpty()){
            
            Set<String> programEnrollmentAdmittedEnrollmentStatus = new Set<String>{'Admitted','Leave of Absence'};
            
            for(hed__Program_Enrollment__c programEnrollment : programEnrollments){
                
                if(ProgramEnrollmentsDAO.ENROLLMENT_STATUS.contains(programEnrollment.Enrollment_Status__c) &&
                    programEnrollment.Enrollment_Status_Date__c != null && 
                    DateService.isDateLessThanAYear(programEnrollment.Enrollment_Status_Date__c)){
                        
                        contactWithNoCurrentProgramEnrollmentMap.put(programEnrollment.hed__Contact__c,programEnrollment.Enrollment_Status__c);
                }
                
                if(programEnrollmentAdmittedEnrollmentStatus.contains(programEnrollment.Enrollment_Status__c) &&
                   programEnrollment.hed__Admission_Date__c != null &&
                   DateService.isDateLessThanAYear(programEnrollment.hed__Admission_Date__c)){
                       
                       contactWithNoCurrentAdmittedProgramEnrollmentMap.put(programEnrollment.hed__Contact__c,programEnrollment.Enrollment_Status__c);
                }                
            }
        }
    }

    private static List<hed__Program_Enrollment__c> getRelatedContactProgramEnrollments(Set<Id> contactIds){ 
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();
        if(!contactIds.isEmpty()){
            programEnrollments = ProgramEnrollmentsDAO.newInstance().getAllProgramEnrollmentsByContactId(contactIds, AccessLevel.SYSTEM_MODE);
        }
        return programEnrollments;
    }

   /**
    * This method checks for contacts associated with applications that fall under specific record types 
    * (Studylink or Sams) and were created within a certain time range specified by the input parameter years. 
    * It returns a set of contact IDs that meet these criteria.
    * 
    * @param years The number of years back from today's date within which the application must have been created.
    * @return A set of contact IDs associated with applications that meet the specified criteria.
    */
    private static Set<Id> getContactWithApplicationsforXYears(Integer years) {
        
        // Initialize a set to store contact IDs
        Set<Id> contactIds = new Set<Id>();
        
        // Iterate through the list of applications
        for(hed__Application__c application : applicationListForStrongInterest) {
            
            // Check if the application falls under specific record types
            Boolean isStudylinkORSamsRecType = application.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
                application.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID ||
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            
            // Check if the application was created within the specified time range
            Boolean isInitiallyCreatedWithinTimeRange =
                application.CreatedDate.Date() <= Date.Today() &&
                application.CreatedDate.Date() >= Date.Today().addYears(-years);
            
            // If the application meets both criteria, add the associated contact ID to the set
            if(
                isStudylinkORSamsRecType &&
                isInitiallyCreatedWithinTimeRange
            ) {
                contactIds.add(application.hed__Applicant__c);
            }
        }
        // Return the set of contact IDs
        return contactIds;
    }
}