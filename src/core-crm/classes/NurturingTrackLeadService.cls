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
 */
public with sharing class NurturingTrackLeadService { //NOPMD
    private static List<hed__Application__c> applicationList;
    private static List<Case> caseList;
    private static Map<String, Nurture_Track_Configuration__c> nurturingTrackMap = NurturingTrackService.getNurturingTrackRecords();
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackWithThreshold = NurturingTrackService.getNurturingTrackRecords();
    private static Map<Id, Lead> domesticEntryLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> domesticExitLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> internationalEntryLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> internationalExitLeadMap = new Map<Id, Lead>();

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
        leadToUpdate.putAll(getEntryInternationalDirectApplicants(internationalEntryLeadMap));
        leadToUpdate.putAll(getEntryDomesticStrongInterestPreApplication(domesticEntryLeadMap));

        //Contact exit criteria to //SAMPLE METHOD ONLY
        //leadToUpdate.putAll(.getExitDomesticStrongInterestPreApplication(domesticExitLeadMap));
        leadToUpdate.putAll(getDomesticStrongInterestPreApplicationForExit(domesticExitLeadMap));
        
        return leadToUpdate.values();
    }

    /**
     * @description: Query all the required records needed for each entry and exit criteria
     *
     * @param Map<Id,Lead> mapOfLeads record to query
     */
    private static void getAllRelatedRecords(Map<Id, Lead> mapOfLeads) {
        applicationList = ApplicationsDAO.newInstance().getApplicationsByLeadIds(mapOfLeads.keySet(), 'SYSTEM_MODE');
        getLeadRecordCitizenship(mapOfLeads);
        filterNurturingTrackRecords();
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
     * @description: Checks existing application records of the contact
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
                application.Calculated_Intake_Date__c >= System.today() &&
                application.Is_Agent_Assisted__c == false
            ) {
                internationalDirectApplicants.put(application.Id, application);
            }
        }

        Map<Id, List<String>> leadsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            internationalEntryLeadMap.keySet(),
            new Set<String>{
                'International Application Submission - Direct Applicant',
                'International Application Submission - Direct Applicant (Automated)'
            },
            Lead.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Lead.getSObjectType(), 
                                                                            'International Application Submission - Direct Applicant (Automated)',
                                                                            'International Application Submission - Direct Applicant');
                                                                            
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
        Map<Id, hed__Application__c> domesticStrongInterestPreApplicationMap = new Map<Id, hed__Application__c>();
        Set<Id> existingLeadIdOnApplication = getLeadOnApplicationForDomesticStrongInterestPreApplicationEntryFilter(applicationList,domesticEntryLeadMap.keySet());

        Map<Id, List<String>> leadsWithCompletedCadenceManual = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL },
            Lead.getSObjectType()
        );
        Set<Id> existingCaseFromLead = getCaseRecordsFromLead(domesticEntryLeadMap.keySet());
        for (hed__Application__c application : applicationList) {
            Boolean hasExistingApplication = existingLeadIdOnApplication.contains(application.Lead__c);
            Boolean hasExistingCaseFromLead = existingCaseFromLead.contains(application.Lead__c);
            if (domesticEntryLeadMap.containsKey(application.Lead__c) && hasExistingApplication && hasExistingCaseFromLead && !leadsWithCompletedCadenceManual.containsKey(application.Lead__c))
            {
                domesticStrongInterestPreApplicationMap.put(application.Id, application);
            }
        }

        Map<Id, List<String>> leadsWithCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new Set<String>{
                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
            },
            Lead.getSObjectType()
        );

        NurturingTrackService.CadenceWrapper cadenceWrapper = new NurturingTrackService.CadenceWrapper(Lead.getSObjectType(), 
        NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
        NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL);
                                                                            
        List<Lead> leadToUpdateList = (List<Lead>) NurturingTrackService.populateCalculatedCadenceMultiple(
            leadsWithCompletedCadence,
            domesticStrongInterestPreApplicationMap.values(),
            cadenceWrapper
        );
        
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>(leadToUpdateList);

        return leadToUpdateMap;
    }

    /**
     * @description: Check if the contact is for Exit of Domestic Deferred Offer to Acceptance cadences
     *
     * @param Map<Id,Lead> mapOfContacts record to evaluate
     * @return Map<Id,Contact> of domestic acceptance lead
     */
    public static Map<Id, Lead> getDomesticStrongInterestPreApplicationForExit(
        Map<Id, Lead> domesticExitLeadMap
    ) {
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>();
        Set<Id> existingLeadIdOnApplicationToExit = getLeadOnApplicationForDomesticStrongInterestPreApplicationExitFilter(
            applicationList
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
        Map<Id, List<String>> existingLeadOnCompletedCadence = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            Lead.getSObjectType()
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
        if ((app.Offer_Status__c == 'Deffered' || isAppStatusValid) &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThreshold.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThreshold.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.Now() && app.hed__Application_Date__c >= System.Now().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static boolean checkSamsDomesticStrongInterestPreApplicationManual(hed__Application__c app){
        Boolean isAppStatusValid = app.Application_Status__c == 'Admitted' || app.Application_Status__c == 'Unsuccessful' || app.Application_Status__c == 'Withdrawn';
        if ((app.Offer_Status__c == 'Deffered' || isAppStatusValid) &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThreshold.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThreshold.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Lead_Score_Threshold__c &&
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
            contactHasApplicationForEntry.add(app.Lead__c);
        }
        else if(hasCompletedCadence && checkQtacDomesticStrongInterestPreApplicationManual(app)){
            contactHasApplicationForEntry.add(app.Lead__c);
        }
    }

    private static boolean checkQtacDomesticStrongInterestPreApplicationAutomated(hed__Application__c app){
        if (!app.Is_Active__c &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThreshold.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThreshold.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.today() && app.hed__Application_Date__c >= System.today().addYears(-3))
        ) {
            return true;
        }
        return false;
    }

    private static boolean checkQtacDomesticStrongInterestPreApplicationManual(hed__Application__c app){
        if (!app.Is_Active__c &&
            app.Lead__r.Lead_Score__c != null &&
            nurturingTrackWithThreshold.containsKey(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL) &&
            app.Lead__r.Lead_Score__c > nurturingTrackWithThreshold.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL).Lead_Score_Threshold__c &&
            (app.hed__Application_Date__c <= System.today() && app.hed__Application_Date__c >= System.today().addYears(-3))
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

        Map<Id, List<String>> leadsWithCompletedCadenceManualMap = NurturingTrackService.getApplicationIdsWithCompletedCadence(
            domesticEntryLeadMap.keySet(),
            new Set<String>{ NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED },
            Lead.getSObjectType()
        );

        List<Case> caseList = CasesDAO.newInstance().getCasesByLeadIds(leadIds, 'SYSTEM_MODE');

        for(Case caseRec : caseList){
            if(!leadsWithCompletedCadenceManualMap.containsKey(caseRec.Lead__c) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThreshold.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED)?.Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromLeadIds.add(caseRec.Lead__c);
            }
            else if(leadsWithCompletedCadenceManualMap.containsKey(caseRec.Lead__c) &&
                checkCaseCreatedDate(caseRec) &&
                nurturingTrackWithThreshold.get(NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL)?.Enquiry_Category_L1__c.split(';').contains(caseRec.Category__c)
            ){
                caseFromLeadIds.add(caseRec.Lead__c);
            }
        }
        return caseFromLeadIds;
    }

    private static boolean checkCaseCreatedDate(Case caseRec){
        return (caseRec.CreatedDate <= System.Now() && caseRec.CreatedDate >= System.Now().addMonths(-3) && caseRec.Category__c != null);
    }

    
    /**
     * @description: Get the nurturing Track Records and set the key to Cadence Name
     *
     */
    private static void filterNurturingTrackRecords() {
        
        for (Nurture_Track_Configuration__c nurture : nurturingTrackWithThreshold.values()) {
            if (nurture.Criteria_Type__c == 'Entry' && nurture.Enquiry_Category_L1__c != null) {
                nurturingTrackWithThreshold.put(nurture.Cadence_Name__c, nurture);
            }
        }
    }





}
