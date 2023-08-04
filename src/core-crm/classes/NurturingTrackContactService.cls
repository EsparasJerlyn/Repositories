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
    private static List<Case> caseList;
    private static Map<Id, Contact> domesticEntryContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> domesticExitContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> internationalEntryContactMap = new Map<Id, Contact>();
    private static Map<Id, Contact> internationalExitContactMap = new Map<Id, Contact>();

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

        //Contact exit criteria to //SAMPLE METHOD ONLY
        contactToUpdate.putAll(getExitInternationalDirectApplicants(internationalExitContactMap));
        contactToUpdate.putAll(getExitInternationalAcceptanceDepositNotPaid(internationalExitContactMap));

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
}
