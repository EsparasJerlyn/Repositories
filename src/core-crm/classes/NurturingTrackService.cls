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
      | mark.j.mahilum                 | Sept 19, 2023         | DEPP-6479              | Revert methods getCurrentIntakePeriod and isDateWithinRange                         |
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
     * @description Generate a map between applicant ids (either contact or lead) and a list of
     *              the cadence names of their completed cadences if they have.
     * @param {Set<Id>} applicantIdsSet A set of ids containing either contacts or leads to find completed cadences with
     * @param {Set<String>} cadenceNamesSet A set of cadence names to filter through completed cadences
     * @param {SObjectType} objectType Needed to identify whether this method is used for leads or contacts
     * @return {Set<Id>} a set of application ids that has a related completed cadence record
     */
    public static Map<Id, List<String>> getApplicantIdsWithCompletedCadence(
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

    /**
     * @description Get cases within the last specified months that are related to a set of contact or leads
     *              While there's nothing stopping you from mixing both contact or lead ids in the parameter,
     *              be reminded that this method does not sort or separate the contact and leads from the keyset.
     * @param {Set<Id>} contactOrLeadsIds A set containing the ids of the contacts and leads you are looking for.
     * @param {Integer} months The number of months to look back when checking for case records.
     * @return {Map<Id, Case}
     */
    public static Map<Id, Case> getCasesWithinLastXMonths(Set<Id> contactOrLeadIds, Integer months) {
        Date checkDate = System.today().addMonths(-months);
        List<Case> relatedCases = CasesDAO.newInstance().getCasesByContactOrLeadIds(contactOrLeadIds, AccessLevel.SYSTEM_MODE);
        Map<Id, Case> contactIdToCaseMap = new Map<Id, Case>();
        for(Case relatedCase : relatedCases) {
            if(relatedCase.CreatedDate >= checkDate) {
                contactIdToCaseMap.put(
                    relatedCase.ContactId != null ? relatedCase.ContactId : relatedCase.Lead__c, 
                    relatedCase
                );
            }
        }
        return contactIdToCaseMap;
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

    public static Decimal selectThreshold(
        Map<String, Nurture_Track_Configuration__c> configurationPair,
        String nurtureTrackName,
        Boolean isManual
    ) {
        if (!configurationPair.containsKey(nurtureTrackName)) {
            return 0;
        }

        return isManual
            ? (Decimal) configurationPair.get(nurtureTrackName).get('Lead_Score_Threshold__c')
            : (Decimal) configurationPair.get(nurtureTrackName + ' (Automated)')
                  .get('Lead_Score_Threshold__c');
    }

    public static List<String> selectL1Categories(
        Map<String, Nurture_Track_Configuration__c> configurationPair,
        String nurtureTrackName,
        Boolean isManual
    ) {
        String manualCategs = configurationPair.containsKey(nurtureTrackName) &&
            String.isNotBlank(
                (String) configurationPair.get(nurtureTrackName).get('Enquiry_Category_L1__c')
            )
            ? (String) configurationPair.get(nurtureTrackName).get('Enquiry_Category_L1__c')
            : '';

        String autoCategs = configurationPair.containsKey(nurtureTrackName + ' (Automated)') &&
            String.isNotBlank(
                (String) configurationPair.get(nurtureTrackName + ' (Automated)')
                    .get('Enquiry_Category_L1__c')
            )
            ? (String) configurationPair.get(nurtureTrackName + ' (Automated)')
                  .get('Enquiry_Category_L1__c')
            : '';

        return isManual ? manualCategs.split(';') : autoCategs.split(';');
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