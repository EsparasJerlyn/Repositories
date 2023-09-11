/**
 * @description helper class for NurturingTrackContactService
 * @see NurturingTrackContactBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                      |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                                                        |
      | mark.j.mahilum                 | Sept 08, 2023         | DEPP-6479              | Remove methods getCurrentIntakePeriod and isDateWithinRange as it is no longer used |
 */
public with sharing class NurturingTrackService {
    private static final Map<SObjectType, Map<String, String>> OBJECT_TO_FIELD_MAP = new Map<SObjectType, Map<String, String>>{
        Contact.SObjectType => new Map<String, String>{
            'ApplicantId' => 'hed__Applicant__c',
            'CompletedCadence' => 'Contact__c'
        },
        Lead.SObjectType => new Map<String, String>{
            'ApplicantId' => 'Lead__c',
            'CompletedCadence' => 'Lead__c'
        }
    };

    /**
     * @description: Get the nurturing Track Records and set the key to Cadence Name
     *
     */
    public static Map<String, Nurture_Track_Configuration__c> getNurturingTrackRecords() {
        Map<String, Nurture_Track_Configuration__c> nurturingTrackMap = new Map<String, Nurture_Track_Configuration__c>();
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance()
            .getNurtureTrackLeadScoreThreshold('SYSTEM_MODE');
        for (Nurture_Track_Configuration__c nurture : nurtureList) {
            nurturingTrackMap.put(nurture.Cadence_Name__c, nurture);
        }

        return nurturingTrackMap;
    }

    /**
     * @description From a set of applications, return a set of application ids that has a related completed
     * cadence record
     * @param Set<Id> applicantIdsSet
     * @return Set<Id> a set of application ids that has a related completed cadence record
     */
    public static Map<Id, List<String>> getApplicationIdsWithCompletedCadence(
        Set<Id> applicantIdsSet, // Ids contact/lead
        Set<String> candenceNamesSet,
        SObjectType objectType
    ) {
        Map<Id, List<String>> completedCadencesByApplicantId = new Map<Id, List<String>>();

        List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance().getCompletedCadenceByTargetIds(applicantIdsSet,candenceNamesSet,'SYSTEM_MODE');
        for (Completed_Cadence__c completedCadence : completedCadenceList) {
            String completedCadenceApiName = (String) OBJECT_TO_FIELD_MAP.get(objectType)
                .get('CompletedCadence');
            if (
                !completedCadencesByApplicantId.containsKey(
                    (Id) completedCadence.get(completedCadenceApiName)
                )
            ) {
                completedCadencesByApplicantId.put(
                    (Id) completedCadence.get(completedCadenceApiName),
                    new List<String>()
                );
            }
            completedCadencesByApplicantId.get((Id) completedCadence.get(completedCadenceApiName))
                .add((String) completedCadence.get('Nurture_Track_Configuration__c'));
        }
        return completedCadencesByApplicantId;
    }

    public static List<SObject> populateCalculatedCadenceMultiple(
        Map<Id, List<String>> completedCadenceByApplicantId,
        List<hed__Application__c> internationalDirectApplicants,
        CadenceWrapper wrapper
    ) {
        Map<Id, SObject> objectForUpdatingMap = new Map<Id, SObject>();
        for (SObject application : (List<SObject>) internationalDirectApplicants) {
            String applicantApiName = OBJECT_TO_FIELD_MAP.get(wrapper.objectType).get('ApplicantId');
            String recordId = (String) application.get(applicantApiName);

            Integer length = getLength(completedCadenceByApplicantId, applicantApiName, application);

            if (length < 2) {
                objectForUpdatingMap.put(
                    (Id) application.get(applicantApiName),
                    recordId.startsWith('003') == true
                        ? (SObject) new Contact(
                              Id = (Id) application.get(applicantApiName),
                              Calculated_Cadence__c = (length == 1)
                                  ? wrapper.cadenceNameManual
                                  : wrapper.cadenceNameAutomated
                          )
                        : (SObject) new Lead(
                              Id = (Id) application.get(applicantApiName),
                              Calculated_Cadence__c = (length == 1)
                                    ? wrapper.cadenceNameManual
                                    : wrapper.cadenceNameAutomated
                          )
                );
            }
        }

        return objectForUpdatingMap.values();
    }

    public static List<SObject> populateCalculatedCadenceSingle(
        Map<Id, List<String>> completedCadenceByApplicantId,
        List<hed__Application__c> internationalDirectApplicants,
        CadenceWrapper wrapper
    ) {
        Map<Id, SObject> objectForUpdatingMap = new Map<Id, SObject>();
        for (SObject application : (List<SObject>) internationalDirectApplicants) {
            String applicantApiName = OBJECT_TO_FIELD_MAP.get(wrapper.objectType).get('ApplicantId');
            String recordId = (String) application.get(applicantApiName);

            Integer length = getLength(completedCadenceByApplicantId, applicantApiName, application);

            if (length < 1) {
                objectForUpdatingMap.put(
                    (Id) application.get(applicantApiName),
                    recordId.startsWith('003') == true
                        ? (SObject) new Contact(
                              Id = (Id) application.get(applicantApiName),
                              Calculated_Cadence__c =  (wrapper.cadenceNameManual != null) ? wrapper.cadenceNameManual : wrapper.cadenceNameAutomated
                          )
                        : (SObject) new Lead(
                              Id = (Id) application.get(applicantApiName),
                              Calculated_Cadence__c =  (wrapper.cadenceNameManual != null) ? wrapper.cadenceNameManual : wrapper.cadenceNameAutomated
                          )
                );
            }
        }

        return objectForUpdatingMap.values();
    }

    private static Integer getLength(Map<Id, List<String>> completedCadenceByApplicantId, String applicantApiName,SObject application){
        Integer length = 0;
        if (completedCadenceByApplicantId.containsKey((Id) application.get(applicantApiName))) {
            length = completedCadenceByApplicantId.get((Id) application.get(applicantApiName)).size();
        }
        return length;
    }

    public class CadenceWrapper{
        SObjectType objectType;
        String cadenceNameManual;
        String cadenceNameAutomated;

        public CadenceWrapper(SObjectType stype, String automatedCadence, String manualCadence){
            objectType = stype;
            cadenceNameManual = manualCadence;
            cadenceNameAutomated = automatedCadence;
        }
    }
}