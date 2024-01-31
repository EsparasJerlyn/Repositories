/**
 * @description helper class for NurturingTrackLeadService 
 * @see NurturingTrackLeadBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                      |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------|
      | mark.j.mahilum                 | July 18, 2023         | DEPP-6105              | Created file                                                        |
      | arsenio.jr.dayrit              | September 07, 2023    | DEPP-5652              | Added handling for Domestic Strong Interest Pre-Application         |
      | mark.j.mahilum                 | Sept 07, 2023         | DEPP-6479              | Updated methods to replace Term Intake Date to                      |
      |                                |                       |                        | Calculated Intake Date on application records                       |
      | mark.j.mahilum                 | Sept 08, 2023         | DEPP-6479              | Remove method call to getCurrentIntakePeriod as it's no longer used |
      | alexander.cadalin              | Oct 3, 2023           | DEPP-6814              | Fixed case detection logic for international strong interest        |
      | mark.j.mahilum                 | Oct 04, 2023          | DEPP-6682              | Added new entry criteria for Domestic Lead Admitted Application     |
      | arsenio.jr.dayrit              | October 06, 2023      | DEPP-6853              | Update handling for Domestic Strong Interest Pre Application        | 
 */
public with sharing class NurturingTrackLeadService { //NOPMD 
    private static List<hed__Application__c> applicationListForStrongInterest = new List<hed__Application__c>();
    private static List<hed__Application__c> applicationList = new List<hed__Application__c>();
    private static List<Case> caseList;
    private static Map<String, Nurture_Track_Configuration__c> nurturingTrackMap = new Map<String, Nurture_Track_Configuration__c>();
    private static Map<String, Nurture_Track_Configuration__c> nurturingTrackWithThresholdForEntry = new Map<String, Nurture_Track_Configuration__c>();
    private static Map<Id, Set<String>> applicantIdsWithCompletedCadence = new Map<Id, Set<String>>(); 
    private static Map<Id, Set<String>> applicantIdsWithAllCompletedCadence = new Map<Id, Set<String>>();
    private static Map<Id, Lead> domesticEntryLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> domesticExitLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> internationalEntryLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> internationalExitLeadMap = new Map<Id, Lead>();
    private static final Map<String, Date> CURRENT_INTAKE_PERIOD = NurturingTrackService.getCurrentIntakePeriod();
    private static final Set<String> ALL_CADENCES = new Set<String>{
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED,
        NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
        NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
        NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
    };

    /**
     * @description: process All leads for Entry and Exit in Cadences assignment
     *
     * @param void
     * @return List<Lead> return the list of lead to update
     */
    public static List<Lead> processLeadForEntryAndExit(Map<Id, Lead> leadMap) {
        Map<Id, Lead> leadToUpdate = new Map<Id, Lead>();

        //query all the related records required for each entry/exit criteria
        getAllRelatedRecords(leadMap);

        //CALL YOUR ENTRY AND EXIT METHOD HERE PASS ONLY THE REQUIRED DATA e.g. (See below)

        //Lead entry criteria to process //SAMPLE METHOD ONLY
        //leadToUpdate.putAll(getEntryDomesticStrongInterestPreApplication(domesticEntryLeadMap));
        leadToUpdate.putAll(getEntryDomesticStrongInterestPreApplication(domesticEntryLeadMap));
        leadToUpdate.putAll(getEntryInternationalStrongInterestPreApplication(internationalEntryLeadMap));
        leadToUpdate.putAll(getEntryInternationalDirectApplicants(internationalEntryLeadMap));
        leadToUpdate.putAll(getEntryDomesticAcceptedAndAdmitted(domesticEntryLeadMap));

        //Lead exit criteria to //SAMPLE METHOD ONLY
        //leadToUpdate.putAll(.getExitDomesticStrongInterestPreApplication(domesticExitLeadMap));
        leadToUpdate.putAll(getDomesticStrongInterestPreApplicationForExit(domesticExitLeadMap));
        leadToUpdate.putAll(getExitInternationalStrongInterestPreApplication(internationalExitLeadMap));

        return leadToUpdate.values();
    }

    /**
     * @description: Query all the required records needed for each entry and exit criteria
     *
     * @param Map<Id,Lead> mapOfLeads record to query
     */
    private static void getAllRelatedRecords(Map<Id, Lead> mapOfLeads) {
        applicationListForStrongInterest = ApplicationsDAO.newInstance().getApplicationsByLeadIds(mapOfLeads.keySet(), 'SYSTEM_MODE');
        getLeadRecordCitizenship(mapOfLeads);
        getAppsWithLatestCalculatedIntakeDatePerLead(mapOfLeads.keySet());
        getFilteredNurturingTrackRecords();

        List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance().getCompletedCadenceByTargetIds(mapOfLeads.keySet(),ALL_CADENCES,'SYSTEM_MODE');

        //get all related completed cadences related to the lead
        applicantIdsWithCompletedCadence = NurturingTrackService.getApplicantIdsWithCompletedCadence(
            mapOfLeads.keySet(),
            completedCadenceList,
            Lead.getSObjectType()
        );

        //get all completed cadences regardless of the status related to the contact
        applicantIdsWithAllCompletedCadence = NurturingTrackService.getApplicantIdsWithAllCompletedCadence(
            mapOfLeads.keySet(),
            completedCadenceList,
            Lead.getSObjectType()
        );
    }

    private static void getAppsWithLatestCalculatedIntakeDatePerLead(Set<Id> leadIds){
        
        Map<String, hed__Application__c> leadToOnePerApplicationRTMap = new Map<String, hed__Application__c>();
        for(hed__Application__c app : ApplicationsDAO.newInstance()
        .getAppsWithLatestCalculatedIntakeDateByApplicantIds(leadIds, 'SYSTEM_MODE')){
            //gets the lead id + app recordtype string combo
            //make this string combo the key
            //this ensures that application list will only have 1 per lead and app record type
            String leadToAppRTCombo = (String)app.Lead__c + (String)app.RecordTypeId;
            if(!leadToOnePerApplicationRTMap.containsKey(leadToAppRTCombo)){
                leadToOnePerApplicationRTMap.put(leadToAppRTCombo,app);
            }
        }
        //add all application with unique lead and app recordtype
        applicationList.addAll(leadToOnePerApplicationRTMap.values());
    }

    /**
     * @description Separate the leads for international or domestic
     * @param Map<Id,Lead> mapOfLeads
     */
    private static void getLeadRecordCitizenship(Map<Id, Lead> mapOfLeads) {
        for (Id key : mapOfLeads.keySet()) {
            Lead ld = mapOfLeads.get(key);
            Boolean isInternationalLead = (ld.Marketing_Segmentation__r.My_Citizenship_Status__c ==
            'International Student');
            if (String.isEmpty(ld.Calculated_Cadence__c)) {
                if (isInternationalLead) {
                    internationalEntryLeadMap.put(key, ld);
                } else {
                    domesticEntryLeadMap.put(key, ld);
                }
            } else {
                if (isInternationalLead) {
                    internationalExitLeadMap.put(key, ld);
                } else {
                    domesticExitLeadMap.put(key, ld);
                }
            }
        }
    }

    /**
     * @description: Checks existing application records of the lead
     *
     * @param Set<Id> leadIds to evaluate
     */
    private static List<hed__Application__c> getApplicationRecords(Set<Id> leadIds) {
        List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance()
            .getApplicationsByLeadIds(leadIds, 'SYSTEM_MODE');
        return existingApplicationList;
    }

    /**
     * @description Update international direct applicant leads based on entry criteria
     * @param Map<Id, Leads> internationEntryLeadMap a map of ids to entry international lead records
     * @return Map<Id, Leads> map of id to updated lead records for batch processing
     */
    private static Map<Id, Lead> getEntryInternationalDirectApplicants(
        Map<Id, Lead> internationalEntryLeadMap
    ) {
        Map<Id, hed__Application__c> internationalDirectApplicants = new Map<Id, hed__Application__c>();
        Set<String> newOrUnsubmittedStatus = new Set<String>{ 'New', 'Unsubmitted' };
        for (hed__Application__c application : applicationList) {
            if (
                internationalEntryLeadMap.containsKey(application.Lead__c) &&
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                newOrUnsubmittedStatus.contains(application.Application_Status__c) &&
                application.Calculated_Intake_Date__c !=NULL &&
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

        Map<Id, Set<String>> leadsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryLeadMap.keySet(),
            new List<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL,
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED
            },
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Lead.getSObjectType(), 
                                                                            NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED,
                                                                            NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL);
                                                                            
        List<Lead> leadToUpdateList = (List<Lead>) NurturingTrackService.populateCalculatedCadenceMultiple(
            leadsWithCompletedCadence,
            internationalDirectApplicants.values(),
            cadenceWrapper
        );
        
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>(leadToUpdateList);

        return leadToUpdateMap;
    }

    /**
     * @description Update Domestic Strong Interest Pre-Application leads based on entry criteria
     * @param Map<Id, Leads> domesticEntryLeadMap a map of ids to entry domestic lead records
     * @return Map<Id, Leads> map of id to updated lead records for batch processing
     */
    private static Map<Id, Lead> getEntryDomesticStrongInterestPreApplication(
        Map<Id, Lead> domesticEntryLeadMap
    ) {
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>();
        Set<Id> existingLeadIdOnApplication = getLeadOnApplicationForDomesticStrongInterestPreApplicationEntryFilter(applicationListForStrongInterest,domesticEntryLeadMap.keySet());
        Set<Id> existingCaseFromLead = getCaseRecordsFromLead(domesticEntryLeadMap.keySet());
        Set<Id> leadIdsWithApplication = getLeadIdsWithApplication(applicationListForStrongInterest);
        Set<String> completedCadencesCopy = new Set<String>();

        Map<Id, Set<String>> leadsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            applicantIdsWithCompletedCadence
        );

        Map<Id, Set<String>> leadsWithCompletedCadenceManual = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL },
            applicantIdsWithCompletedCadence
        );

        for (Lead lead : domesticEntryLeadMap.values()){
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(lead.Id)?new Set<String>(applicantIdsWithAllCompletedCadence.get(lead.Id)):new Set<String>();

            Boolean leadHasExistingApplication = leadIdsWithApplication.contains(lead.Id);
            Boolean hasInActiveApplication = existingLeadIdOnApplication.contains(lead.Id);
            Boolean hasExistingCaseFromLead = existingCaseFromLead.contains(lead.Id);
            Boolean hasExistingCompletedCadence = leadsWithCompletedCadence.containsKey(lead.Id);
            Boolean hasExistingCompletedCadenceManual = leadsWithCompletedCadenceManual.containsKey(lead.Id);
            Decimal threshold = NurturingTrackService.selectThreshold(
                nurturingTrackWithThresholdForEntry, 
                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                hasExistingCompletedCadence
            );
            if ((!leadHasExistingApplication || hasInActiveApplication) && 
            hasExistingCaseFromLead && 
            !hasExistingCompletedCadenceManual &&
            lead.Lead_Score__c >= threshold && // ... has a lead score above threshold...
            //make sure that there are no completed cadence against any succeeding cadence
            //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
            !completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.DOMESTIC_TRACK_SUCCEEDING_STRONG_INTEREST))
            {
                leadToUpdateMap.put(
                        lead.Id, 
                        new Lead(
                            Id = lead.Id,
                            Calculated_Cadence__c = hasExistingCompletedCadence ?
                            NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL :
                            NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
                        )
                    );
            }
        }

        return leadToUpdateMap;
    }

    /**
     * @description Update lead with the “Domestic Accepted and Admitted” when the entry criteria is fulfilled.
     * @param Map<Id, Leads> domesticEntryLeadMap a map of ids to entry domestic lead records
     * @return Map<Id, Leads> map of id to updated lead records for batch processing
     */
    private static Map<Id, Lead> getEntryDomesticAcceptedAndAdmitted(
        Map<Id, Lead> domesticEntryLeadMap
    ) {
        Map<Id, hed__Application__c> domesticAcceptedApplicants = new Map<Id, hed__Application__c>();
        for (hed__Application__c app : applicationList) {
            
            Boolean isSAMSApplication = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            Boolean isProgramEnrollmentAdmitted = (app.Program_Enrollment__c != NULL && String.isNotBlank(app.Program_Enrollment__r.Enrollment_Status__c));
            Boolean isSAMSLatestApplication = (app.Calculated_Intake_Date__c != NULL && app.Calculated_Intake_Date__c > Date.today());
    
            if (isSAMSApplication &&
                domesticEntryLeadMap.containsKey(app.Lead__c) &&
                isProgramEnrollmentAdmitted &&
                isSAMSLatestApplication &&
                app.Program_Enrollment__r.Enrollment_Status__c =='Admitted'
            ) {
                domesticAcceptedApplicants.put(app.Id, app);
            }
        }
    
        Map<Id, Set<String>> leadsWithCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new List<String>{NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL},
            applicantIdsWithCompletedCadence
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(
            Lead.getSObjectType(),
            null,
            NurtureTrackConfigurationsDAO.DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL
        );
        
        List<Lead> leadToUpdateList = (List<Lead>) NurturingTrackService.populateCalculatedCadenceSingle(
            leadsWithCompletedCadence,
            domesticAcceptedApplicants.values(),
            cadenceWrapper
        );
        
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>(leadToUpdateList);
        return leadToUpdateMap;
    }

    /**
     * @description: Check if the lead is for Exit of Domestic Deferred Offer to Acceptance cadences
     *
     * @param Map<Id,Lead> mapOfLeads record to evaluate
     * @return Map<Id,Lead> of domestic acceptance lead
     */
    public static Map<Id, Lead> getDomesticStrongInterestPreApplicationForExit(
        Map<Id, Lead> domesticExitLeadMap
    ) {
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>();
        Set<Id> existingLeadIdOnApplicationToExit = getLeadOnApplicationForDomesticStrongInterestPreApplicationExitFilter(
            applicationListForStrongInterest
        );
        
        for (Id leadId : domesticExitLeadMap.keySet()) {
            Boolean hasExistingApplicationToExit = existingLeadIdOnApplicationToExit.contains(
                leadId
            );
            
            if (hasExistingApplicationToExit || domesticExitLeadMap.get(leadId).HasOptedOutOfEmail) {
                leadToUpdateMap.put(
                    leadId,
                    new Lead(id = leadId, Calculated_Cadence__c = '')
                );
            }
        }
        return leadToUpdateMap;
    }

    private static Set<Id> getLeadOnApplicationForDomesticStrongInterestPreApplicationEntryFilter(
        List<hed__Application__c> applicationList,
        Set<Id> leadIdSet
    ) {
        Set<Id> leadHasApplicationForEntry = new Set<Id>();
        Map<Id, Set<String>> existingLeadOnCompletedCadence = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            applicantIdsWithCompletedCadence
        );
        for (hed__Application__c app : applicationList) {
            boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            if(isSAMSLegacyRecType || isSAMSCiRecType){
                processSamsDomesticStrongInterestPreApplicationEntryCriteria(app,leadHasApplicationForEntry,existingLeadOnCompletedCadence.containsKey(app.Lead__c));
            }
            else if(isQTACRecType){
                processQtacDomesticStrongInterestPreApplicationEntryCriteria(app,leadHasApplicationForEntry,existingLeadOnCompletedCadence.containsKey(app.Lead__c));
            }
        }
        return leadHasApplicationForEntry;
    }

    private static void processSamsDomesticStrongInterestPreApplicationEntryCriteria(
        hed__Application__c app,
        Set<Id> leadHasApplicationForEntry,
        boolean existingLeadOnCompletedCadence
    ) {

        if(!existingLeadOnCompletedCadence && checkSamsDomesticStrongInterestPreApplicationAutomated(app)){
            leadHasApplicationForEntry.add(app.Lead__c);
        }
        else if(existingLeadOnCompletedCadence && checkSamsDomesticStrongInterestPreApplicationManual(app)){
            leadHasApplicationForEntry.add(app.Lead__c);
        }
    }

    private static boolean checkSamsDomesticStrongInterestPreApplicationAutomated(hed__Application__c app){
        Boolean isAppStatusValid = app.Application_Status__c == 'Admitted' || app.Application_Status__c == 'Unsuccessful' || app.Application_Status__c == 'Withdrawn';
        if ((app.Offer_Status__c == 'Deferred' || isAppStatusValid) &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.Now() && app.hed__Application_Date__c >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static boolean checkSamsDomesticStrongInterestPreApplicationManual(hed__Application__c app){
        Boolean isAppStatusValid = app.Application_Status__c == 'Admitted' || app.Application_Status__c == 'Unsuccessful' || app.Application_Status__c == 'Withdrawn';
        if ((app.Offer_Status__c == 'Deferred' || isAppStatusValid) &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.Now() && app.hed__Application_Date__c >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static void processQtacDomesticStrongInterestPreApplicationEntryCriteria(
        hed__Application__c app,
        Set<Id> leadHasApplicationForEntry,
        boolean hasCompletedCadence) {
        if(!hasCompletedCadence && checkQtacDomesticStrongInterestPreApplicationAutomated(app)){
            leadHasApplicationForEntry.add(app.Lead__c);
        }
        else if(hasCompletedCadence && checkQtacDomesticStrongInterestPreApplicationManual(app)){
            leadHasApplicationForEntry.add(app.Lead__c);
        }
    }

    private static boolean checkQtacDomesticStrongInterestPreApplicationAutomated(hed__Application__c app){
        if (!app.Is_Active__c &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Lead_Score_Threshold__c &&
            (app.CreatedDate <= System.Now() && app.CreatedDate >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static boolean checkQtacDomesticStrongInterestPreApplicationManual(hed__Application__c app){
        if (!app.Is_Active__c &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Lead_Score_Threshold__c &&
            (app.CreatedDate <= System.Now() && app.CreatedDate >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static Set<Id> getLeadOnApplicationForDomesticStrongInterestPreApplicationExitFilter(List<hed__Application__c> applicationList){
        Set<Id> leadtHasApplicationForExit = new Set<Id>();
        for (hed__Application__c app : applicationList) {
            boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCiRecType = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            if(app.Application_Status__c == 'Submitted' && (isSAMSLegacyRecType || isSAMSCiRecType || isQTACRecType)){
                leadtHasApplicationForExit.add(app.Lead__c);
            }   
        }
        return leadtHasApplicationForExit;
    }


    private static Set<Id> getCaseRecordsFromLead(Set<Id> leadIds){
        Set<Id> caseFromLeadIds = new Set<Id>();
        Map<Id, Set<String>> leadsWithCompletedCadenceManualMap = new  Map<Id, Set<String>>();
        List<Case> caseList = new List<Case>();

        if(nurturingTrackWithThresholdForEntry.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED)){

            leadsWithCompletedCadenceManualMap = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
                domesticEntryLeadMap.keySet(),
                new List<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
                applicantIdsWithCompletedCadence
            );
            caseList = CasesDAO.newInstance().getCasesByLeadIds(leadIds, AccessLevel.SYSTEM_MODE);
        }


        for(Case caseRec : caseList){
            if(!leadsWithCompletedCadenceManualMap.containsKey(caseRec.Lead__c) &&
                checkCaseCreatedDate(caseRec) && 
                nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED)?.Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromLeadIds.add(caseRec.Lead__c);
            }
            else if(leadsWithCompletedCadenceManualMap.containsKey(caseRec.Lead__c) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThresholdForEntry.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL)?.Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromLeadIds.add(caseRec.Lead__c);
            }
        }
        return caseFromLeadIds;
    }

    private static boolean checkCaseCreatedDate(Case caseRec){
        return (caseRec.CreatedDate <= System.Now() && caseRec.CreatedDate >= System.Now().addMonths(-3) && caseRec.Category__c != null);
    }

    private static Set<Id> getLeadIdsWithApplication(List<hed__Application__c> applications){
        Set<Id> applicationLeadIds = new Set<Id>();
        for(hed__Application__c app : applications){
            applicationLeadIds.add(app.Lead__c);
        }

        return applicationLeadIds;
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
            if(nurture.Lead_Score_Threshold__c != null){
                nurturingTrackMap.put(nurture.Cadence_Name__c, nurture);
            }
        }
    }

    private static Map<Id, Lead> getEntryInternationalStrongInterestPreApplication(Map<Id, Lead> internationalEntryLeadMap) {
        Set<String> completedCadencesCopy = new Set<String>();

        Map<Id, Set<String>> leadIdsWithCmpltdCadenceSet = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryLeadMap.keySet(),
            new List<String>{NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED},
            applicantIdsWithCompletedCadence
        );
        
        Set<Id> completedManualCadenceByLeadId = NurturingTrackService.getFilteredApplicantWithCompletedCadence(
            internationalEntryLeadMap.keySet(),
            new List<String>{ NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            applicantIdsWithCompletedCadence
        ).keySet();
        
        Map<Id, List<String>> leadIdToCaseCategoriesMap = NurturingTrackService.getApplicantIdToRelatedCaseCategoriesMap(internationalEntryLeadMap.keySet(), 3);
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
        for(Lead internationalEntryLead : internationalEntryLeadMap.values()) {
            
            boolean shouldContinueProcessing = leadIdsWithCmpltdCadenceSet.containsKey(internationalEntryLead.Id) && leadIdsWithCmpltdCadenceSet.get(internationalEntryLead.Id).size() >= 2;       
            //get a copy of completed cadences related to the contact regardless of status
            completedCadencesCopy = applicantIdsWithAllCompletedCadence.containsKey(internationalEntryLead.Id)?new Set<String>(applicantIdsWithAllCompletedCadence.get(internationalEntryLead.Id)):new Set<String>();
    
            if (shouldContinueProcessing || 
                //make sure that there are no completed cadence against any succeeding cadence
                //this should return true if one of the succeeding cadence is already in compeltedCadencesCopy
                completedCadencesCopy.removeAll(NurtureTrackConfigurationsDAO.INTERNATIONAL_TRACK_SUCCEEDING_STRONG_INTEREST)) {
                continue;
            }
            
            Boolean isManual = !completedManualCadenceByLeadId.contains(internationalEntryLead.Id);
            Decimal threshold = NurturingTrackService.selectThreshold(
                nurturingTrackMap, 
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                isManual
            );
            List<String> l1Categories = NurturingTrackService.selectL1Categories(
                nurturingTrackMap, 
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                isManual
            );
            //pass an empty list if not found in map
            List<String> relatedCaseCategories = leadIdToCaseCategoriesMap.containsKey(internationalEntryLead.Id)?leadIdToCaseCategoriesMap.get(internationalEntryLead.Id): new List<String>();

            if( // ... the lead...
                isLeadWithNoActiveStudyLinkAppforXYears(internationalEntryLead, 3) && // ... has any inactive studylink only (must have no active)...
                internationalEntryLead.Lead_Score__c > threshold &&  (                    // ... has a lead score above threshold...
                    NurturingTrackService.isRelatedCaseCategoriesContainsL1Categories(        // ... has a related case with a certain category...
                        l1Categories, 
                        relatedCaseCategories
                    ))
            ) {
                leadsToUpdate.put(
                    internationalEntryLead.Id, 
                    new Lead(
                        Id = internationalEntryLead.Id,
                        Calculated_Cadence__c = !isManual ?
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL :
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
                    )
                );
            }
            
        }
        return leadsToUpdate;
    }

    private static Map<Id, Lead> getExitInternationalStrongInterestPreApplication(Map<Id, Lead> internationalExitLeadMap) {
        List<String> cadenceNames = new List<String>{
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED, 
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL
        };
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
        for(hed__Application__c application : applicationListForStrongInterest) {
            Lead relatedLead = internationalExitLeadMap.get(application.Lead__c);

            Boolean isActiveApplication = 
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID &&
                application.Application_Status__c != null && 
                !ApplicationsDAO.STUDYLINK_TERMINAL_STATUSES.contains(application.Application_Status__c);
                
            if(
                relatedLead != null &&
                cadenceNames.contains(relatedLead.Calculated_Cadence__c) &&                 
                (isActiveApplication || relatedLead.HasOptedOutOfEmail)
            ) {
                leadsToUpdate.put(
                    relatedLead.Id,
                    new Lead(
                        Id = relatedLead.Id,
                        Calculated_Cadence__c = ''
                    )
                );
            }
        }

        getLeadHasOptedOutOfEmail(internationalExitLeadMap, leadsToUpdate, cadenceNames);

        return leadsToUpdate;
    }

    private static void getLeadHasOptedOutOfEmail(Map<Id, Lead> internationalExitLeadMap, Map<Id, Lead> leadsToUpdate, List<String> cadenceNames) {
        for(Id leadId : internationalExitLeadMap.keySet()) {
            Lead leadDetail = internationalExitLeadMap.get(leadId);
            if (
                cadenceNames.contains(leadDetail.Calculated_Cadence__c) &&
                leadDetail.HasOptedOutOfEmail == true &&
                leadsToUpdate.get(leadDetail.Id) == null
            ) {
                leadsToUpdate.put(
                    leadDetail.Id,
                    new Lead(
                        Id = leadDetail.Id,
                        Calculated_Cadence__c = ''
                    )
                );
            }
        }
    }

    private static Boolean isLeadWithNoActiveStudyLinkAppforXYears(Lead internationalEntryLead, Integer years) {
        Boolean hasActiveApplication = false;
        for(hed__Application__c application : applicationList) {
            Boolean isLeadStudylinkApplication = 
                application.Lead__c == internationalEntryLead.Id && 
                application.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            Boolean isInitiallyCreatedWithinTimeRange = 
                application.hed__Initial_Creation_Date__c <= System.today() &&
                application.hed__Initial_Creation_Date__c >= System.today().addYears(-years);
            Boolean isActiveApplication = !ApplicationsDAO.STUDYLINK_TERMINAL_STATUSES.contains(application.Application_Status__c);
            if(
                isLeadStudylinkApplication &&
                isInitiallyCreatedWithinTimeRange &&
                isActiveApplication
            ) {
                hasActiveApplication = true;
                break;
            }
        }
        return !hasActiveApplication;
    }

}