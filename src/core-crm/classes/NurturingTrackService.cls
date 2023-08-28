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
        for (Completed_Cadence__c completedCadence : [
                                                        SELECT Id, Contact__c,Lead__c,Nurture_Track_Configuration__c
                                                        FROM Completed_Cadence__c
                                                        WHERE
                                                            (Contact__c IN :applicantIdsSet
                                                            OR Lead__c IN :applicantIdsSet)
                                                            AND Nurture_Track_Configuration__r.Cadence_Name__c IN :candenceNamesSet
                                                            AND Completed_Cadence_Status__c !='Unsuccessful'
                                                        WITH SYSTEM_MODE
        ]) {
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

    /**
     * @description Get the current intake period
     * @return Map<String, Date> key-value pair, start date and end date
     */
    public static Map<String, Date> getCurrentIntakePeriod() {
        Map<String, Date> universityTermMap = new Map<String, Date>{
            'START_DATE' => null,
            'END_DATE' => null
        };

        for (hed__Term__c term : [
            SELECT Id, hed__Start_Date__c, hed__End_Date__c
            FROM hed__Term__c
            WHERE
                Location__r.Name = 'U'
                AND Study_Period_Type_Code__c IN ('SEM-1', 'SEM-2', 'SUM')
                AND hed__Start_Date__c > :System.today()
            WITH SYSTEM_MODE
            ORDER BY hed__Start_Date__c ASC
            LIMIT 1
        ]) {
            universityTermMap.put('START_DATE', term.hed__Start_Date__c);
            universityTermMap.put('END_DATE', term.hed__End_Date__c);
        }

        return universityTermMap;
    }

    /**
     * @description Check if a date is within the range of two dates
     * @param Date dateToCheck
     * @param Date lowerDate
     * @param Date upperDate
     * @return Boolean true if the date is within the two other dates, false otherwise
     */
    public static Boolean isDateWithinRange(Date dateToCheck, Date lowerDate, Date upperDate) {
        // just in case, to prevent unnecessary behavior, swap if lowerDate is later than upperDate

        Boolean isNotNull = false; // Boolean variable to track if both lowerDate and upperDate are not null
        if (lowerDate != null && upperDate != null) {
            isNotNull = true;
        }
        if (isNotNull && (lowerDate > upperDate)) {
            Date tempDate = lowerDate;
            lowerDate = upperDate;
            upperDate = tempDate;
        }

        return isNotNull ? dateToCheck >= lowerDate && dateToCheck <= upperDate : false;
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