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
      | alexander.cadalin              | Oct 3, 2023           | DEPP-6814              | Fixed case detection logic for international strong interest                        |
 */
public with sharing class NurturingTrackService { //NOPMD This is a service class, abundance of public methods and high overall complexity is expected 

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
     * @param {Set<String>} cadenceNamesSet A set of cadence names to filter through completed cadences via SOQL
     * @param {SObjectType} objectType Needed to identify whether this method is used for leads or contacts
     * @return {Map<Id, Set<String>>} a set of application ids that has a related completed cadence record
     */
    public static Map<Id, Set<String>> getApplicantIdsWithCompletedCadence(
        List<Completed_Cadence__c> completedCadenceList,
        SObjectType objectType,
        Boolean allStatuses
    ) {
        Map<Id, Set<String>> completedCadencesByApplicantId = new Map<Id, Set<String>>();

        for (Completed_Cadence__c completedCadence : completedCadenceList) {
            String completedCadenceApiName = (String) OBJECT_TO_FIELD_MAP.get(objectType)
                .get('CompletedCadence');

            if(!allStatuses && CompletedCadencesDAO.completedCadenceStatuses.contains(completedCadence.Completed_Cadence_Status__c)){
                continue;
            }

            if (
                !completedCadencesByApplicantId.containsKey(
                    (Id) completedCadence.get(completedCadenceApiName)) 
            ) {
                completedCadencesByApplicantId.put(
                    (Id) completedCadence.get(completedCadenceApiName),
                    new Set<String>()
                );
            }

            completedCadencesByApplicantId.get((Id) completedCadence.get(completedCadenceApiName))
            .add(completedCadence.Nurture_Track_Configuration__r.Cadence_Name__c);
        }
        return completedCadencesByApplicantId;
    }

    //get relevant for auto/manual detection
    //checks for applications ids first
    public static Map<Id, Set<String>> getApplicantIdsWithCompletedCadence(
        Set<Id> applicationIds,
        List<Completed_Cadence__c> completedCadenceList
    ) {
        Map<Id, Set<String>> applicationIdsWithCompletedCadences = new Map<Id, Set<String>>();
        for(Completed_Cadence__c completedCadence : completedCadenceList) {
            if(
                !applicationids.contains(completedCadence.Application__c) ||
                CompletedCadencesDAO.completedCadenceStatuses.contains(completedCadence.Completed_Cadence_Status__c)
            ) {
                continue;
            }
            if(!applicationIdsWithCompletedCadences.containsKey(completedCadence.Contact__c)) {
                applicationIdsWithCompletedCadences.put(completedCadence.Contact__c, new Set<String>());
            }
            applicationIdsWithCompletedCadences.get(completedCadence.Contact__c).add(completedCadence.Nurture_Track_Configuration__r.Cadence_Name__c);
        }
        return applicationIdsWithCompletedCadences;
    }

    //get all for anti-backtrack
    public static Map<Id, Set<String>> getApplicationIdsWithCompletedCadence(
        List<Completed_Cadence__c> completedCadenceList
    ) {
        Map<Id, Set<String>> applicationIdsWithCompletedCadences = new Map<Id, Set<String>>();
        for(Completed_Cadence__c completedCadence : completedCadenceList) {
            if(!applicationIdsWithCompletedCadences.containsKey(completedCadence.Application__c)) {
                applicationIdsWithCompletedCadences.put(completedCadence.Application__c, new Set<String>());
            }
            applicationIdsWithCompletedCadences.get(completedCadence.Application__c).add(completedCadence.Nurture_Track_Configuration__r.Cadence_Name__c);
        }
        return applicationIdsWithCompletedCadences;
    }

    /**
     * @description Generate a map between applicant ids (either contact or lead) and a list of
     *              the cadence names of their completed cadences regardless of the status if they have.
     * @param {Set<Id>} applicantIdsSet A set of ids containing either contacts or leads to find completed cadences with
     * @param {Set<String>} cadenceNamesSet A set of cadence names to filter through completed cadences via SOQL
     * @param {SObjectType} objectType Needed to identify whether this method is used for leads or contacts
     * @return {Map<Id, Set<String>>} a set of application ids that has a related completed cadence record
     */
    // public static Map<Id, Set<String>> getApplicantIdsWithAllCompletedCadence(
    //     Set<Id> applicantIdsSet, // Ids contact/lead
    //     List<Completed_Cadence__c> completedCadenceList,
    //     SObjectType objectType
    // ) {
    //     Map<Id, Set<String>> completedCadencesByApplicantId = new Map<Id, Set<String>>();

    //     for (Completed_Cadence__c completedCadence : completedCadenceList) {
    //         String completedCadenceApiName = (String) OBJECT_TO_FIELD_MAP.get(objectType)
    //             .get('CompletedCadence');
    //         if (
    //             !completedCadencesByApplicantId.containsKey(
    //                 (Id) completedCadence.get(completedCadenceApiName)
    //             )
    //         ) {
    //             completedCadencesByApplicantId.put(
    //                 (Id) completedCadence.get(completedCadenceApiName),
    //                 new Set<String>()
    //             );
    //         }
    //         completedCadencesByApplicantId.get((Id) completedCadence.get(completedCadenceApiName))
    //             .add(completedCadence.Nurture_Track_Configuration__r.Cadence_Name__c);
    //     }
    //     return completedCadencesByApplicantId;
    // }

    /**
     * @description Generate a map between applicant ids (either contact or lead) and a list of
     *              the cadence names of their completed cadences if they have.
     * @param {Set<Id>} applicantIdsSet A set of ids containing either contacts or leads to find completed cadences with
     * @param {List<String>} cadenceNamesSet A set of cadence names to filter through completed cadences(maximum of 2 names only)
     * @param {Map<Id, Set<String>>} applicantIdsWithCompletedCadence all completed cadences related to the contact/lead 
     * @return {Map<Id, Set<String>>} a map of application ids that has a related completed cadence record filtered by cadenceNamesSet
     */
    public static Map<Id, Set<String>> getFilteredApplicantWithCompletedCadence(
        Set<Id> applicantIdsSet,
        List<String> cadenceNamesSet,
        Map<Id, Set<String>> applicantIdsWithCompletedCadence
        
    ){
        Map<Id, Set<String>> completedCadencesByApplicantId = new Map<Id, Set<String>>();

        for(Id applicantId: applicantIdsSet){
            if(!applicantIdsWithCompletedCadence.containsKey(applicantId)){
                continue;
            }
            //it is expected that there are only maximum of 2 cadence names in the set
            //used cadenceNamesSet[0] and cadenceNamesSet[1] to avoid a for loop and reduce code complexity
            if(applicantIdsWithCompletedCadence.get(applicantId).contains(cadenceNamesSet[0])){
                if(!completedCadencesByApplicantId.containsKey(applicantId)){
                    completedCadencesByApplicantId.put(applicantId,new Set<String>());
                }
                completedCadencesByApplicantId.get(applicantId).add(cadenceNamesSet[0]);
            }
            if(cadenceNamesSet.size() == 2 && applicantIdsWithCompletedCadence.get(applicantId).contains(cadenceNamesSet[1])){
                if(!completedCadencesByApplicantId.containsKey(applicantId)){
                    completedCadencesByApplicantId.put(applicantId,new Set<String>());
                }
                completedCadencesByApplicantId.get(applicantId).add(cadenceNamesSet[1]);
            }
        }

        return completedCadencesByApplicantId;
    }

    public static List<SObject> populateCalculatedCadenceMultiple(
        Map<Id, Set<String>> completedCadenceByApplicantId,
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
                                  : wrapper.cadenceNameAutomated,
                              Cadence_Application__c = (Id) application.get('Id')
                          )
                        : (SObject) new Lead(
                              Id = (Id) application.get(applicantApiName),
                              Calculated_Cadence__c = (length == 1)
                                    ? wrapper.cadenceNameManual
                                    : wrapper.cadenceNameAutomated,
                              Cadence_Application__c = (Id) application.get('Id')
                          )
                );
            }
        }

        return objectForUpdatingMap.values();
    }

    public static List<SObject> populateCalculatedCadenceSingle(
        Map<Id, Set<String>> completedCadenceByApplicantId,
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
                              Calculated_Cadence__c =  (wrapper.cadenceNameManual != null) ? wrapper.cadenceNameManual : wrapper.cadenceNameAutomated,
                              Cadence_Application__c = (Id) application.get('Id')
                          )
                        : (SObject) new Lead(
                              Id = (Id) application.get(applicantApiName),
                              Calculated_Cadence__c =  (wrapper.cadenceNameManual != null) ? wrapper.cadenceNameManual : wrapper.cadenceNameAutomated,
                              Cadence_Application__c = (Id) application.get('Id')
                          )
                );
            }
        }

        return objectForUpdatingMap.values();
    }

    /**
     * @description Generate a map between applicant (contact or lead) id to a list of categories from all related cases.
     * This specific method takes a parameter, months, where it checks if the related case records were created within
     * the last three months.
     * @param Set<Id> contactOrLeadIds - A set of contact or lead ids to look up cases for.
     * @param Integer months - The amount of months to check if the cases are created from.
     * @return Map<Id, List<String>>
     */
    public static Map<Id, List<String>> getApplicantIdToRelatedCaseCategoriesMap(Set<Id> contactOrLeadIds, Integer months) {
    	Date checkDate = System.today().addMonths(-months);
    	List<Case> relatedCases = CasesDAO.newInstance().getCasesByContactOrLeadIds(contactOrLeadIds, AccessLevel.SYSTEM_MODE);
    	Map<Id, List<String>> applicantIdToCategories = new Map<Id, List<String>>();
        for(Case relatedCase : relatedCases) {
            if(relatedCase.CreatedDate >= checkDate && relatedCase.Category__c != null) {
                putToApplicantIdToCategoriesMap(applicantIdToCategories, relatedCase);
            }
        }
        return applicantIdToCategories;
    }

    private static void putToApplicantIdToCategoriesMap(Map<Id, List<String>> applicantIdToCategories, Case relatedCase) {
        if(relatedCase.ContactId != null) {
            List<String> categoriesToAdd = applicantIdToCategories.get(relatedCase.ContactId) == null ?
                new List<String>() : applicantIdToCategories.get(relatedCase.ContactId);
            categoriesToAdd.add(relatedCase.Category__c);
            applicantIdToCategories.put(relatedCase.ContactId, categoriesToAdd);
        }
        if(relatedCase.Lead__c != null) {
            List<String> categoriesToAdd = applicantIdToCategories.get(relatedCase.Lead__c) == null ?
                new List<String>() : applicantIdToCategories.get(relatedCase.Lead__c);
            categoriesToAdd.add(relatedCase.Category__c);
            applicantIdToCategories.put(relatedCase.Lead__c, categoriesToAdd);
        }
    }
    
    public static Boolean isRelatedCaseCategoriesContainsL1Categories(List<String> l1Categories, List<String> relatedCaseCategories) {
        Boolean isContains = false;
        if(l1Categories.isEmpty()) { 
            isContains = true; // bypass. empty l1categories mean don't check
        } else if(relatedCaseCategories != null) {
            for(String l1Category : l1Categories) {
                if(relatedCaseCategories.contains(l1Category)) {
                    isContains = true;
                    break;
                }
            }
        }
        return isContains;
    }

    public static Map<String,International_Tier__c> getAllRestrictedCountry(){
        Map<String,International_Tier__c> restrictedCountryMap = new Map<String,International_Tier__c>();
        for(International_Tier__c it : InternationalTiersDAO.newInstance().getActiveInternationalTiers(AccessLevel.SYSTEM_MODE)){
            if(it.Tier_Subcategory__c == InternationalTiersDAO.UNTIERED_SUBCATEGORY_RESTRICTED){
                restrictedCountryMap.put(it.Country_Name__c,it);
            }
        }
        return restrictedCountryMap;
    }
    
    private static Integer getLength(Map<Id, Set<String>> completedCadenceByApplicantId, String applicantApiName,SObject application){
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
        if(isManual) {
            return 
                configurationPair.containsKey(nurtureTrackName) &&
                String.isNotBlank((String) configurationPair.get(nurtureTrackName).get('Enquiry_Category_L1__c')) ? 
                ((String) configurationPair.get(nurtureTrackName).get('Enquiry_Category_L1__c')).split(';') : 
            	new List<String>();
        } else {
            return
                configurationPair.containsKey(nurtureTrackName + ' (Automated)') &&
                String.isNotBlank((String) configurationPair.get(nurtureTrackName + ' (Automated)').get('Enquiry_Category_L1__c')) ? 
                ((String) configurationPair.get(nurtureTrackName + ' (Automated)').get('Enquiry_Category_L1__c')).split(';') : 
            	new List<String>();
        }
    }
    
    public class CadenceWrapper{
        SObjectType objectType;
        String cadenceNameAutomated;
        String cadenceNameManual;

        public CadenceWrapper(SObjectType stype, String automatedCadence, String manualCadence){
            objectType = stype;
            cadenceNameAutomated = automatedCadence;
            cadenceNameManual = manualCadence;
        }
    }
}