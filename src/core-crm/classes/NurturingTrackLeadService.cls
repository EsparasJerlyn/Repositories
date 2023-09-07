/**
 * @description helper class for NurturingTrackLeadService
 * @see NurturingTrackLeadBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 18, 2023         | DEPP-6105              | Created file                                     |
      | mark.j.mahilum                 | Sept 07, 2023         | DEPP-6479              | Updated methods to replace Term Intake Date to   |
      |                                |                       |                        | Calculated Intake Date on application records    |
 */
public with sharing class NurturingTrackLeadService {
    private static List<hed__Application__c> applicationList;
    private static List<Case> caseList;
    private static Map<String, Nurture_Track_Configuration__c> nurturingTrackMap = NurturingTrackService.getNurturingTrackRecords();
    private static Map<Id, Lead> domesticEntryLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> domesticExitLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> internationalEntryLeadMap = new Map<Id, Lead>();
    private static Map<Id, Lead> internationalExitLeadMap = new Map<Id, Lead>();

    private static final Map<String, Date> CURRENT_INTAKE_PERIOD = NurturingTrackService.getCurrentIntakePeriod();

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

        //Contact exit criteria to //SAMPLE METHOD ONLY
        //leadToUpdate.putAll(.getExitDomesticStrongInterestPreApplication(domesticExitLeadMap));

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
}
