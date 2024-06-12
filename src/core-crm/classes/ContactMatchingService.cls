/**
 * @description Service class responsible for matching contact records and facilitating notification escalation for human intervention.
 *              This class provides methods for comparing incoming records against existing contacts, identifying matches based on predefined key fields,
 *              and logging errors when multiple matches are found for a single record.
 *
 *              The class offers functionality to process contact matching for a list of records, returning a map of matching contacts where keys are unique concatenated matching fields.
 *              Matches are determined based on predefined key fields, and error logging is employed to handle scenarios where more than one match is found for a single record.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */
public without sharing class ContactMatchingService {
    // Maps to store contacts grouped by different matching criteria
    private static Map<String, List<Contact>> systemKeyMatchingMap;
    private static Map<String, List<Contact>> naturalKeyMatchingMap;
    private static Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap;
    private static Map<String, List<Contact>> partialNaturalKeyMatchingMap;
    private static Map<String, List<Contact>> noDOBMatchingMap;
    private static Set<String> excludedIds = new Set<String>();

    /**
     * @description List of optional contact fields considered in the key matching process.
     *              Add contact fields here if needed.
     */
    public static final List<String> KEY_FIELDS_ON_CONTACT = new List<String>{
        'Email',
        'Work_Email__c',
        'QUT_Learner_Email__c',
        'QUT_Staff_Email__c',
        'MobilePhone'
    };

    /**
     * Processes contact matching for a list of records and returns a map of matching contacts.
     * Matches are determined based on predefined key fields.
     * If more than one match is found for any record, logs an error and excludes the record from the result.
     * After matching, it processes key changes and updates Contact and Contact Alternate ID records accordingly.
     *
     * @param matchingRecords The list of matching records containing attributes for each record.
     * @return A map where keys are unique concatenated matching fields and values are matching results.
     */
    public static Map<String, MatchingResult> processContactMatchingWithKeyChange(
        List<MatchingAttributes> matchingRecords
    ) {
        // Create a map of matching attributes, the keys should retain the noise
        Map<String, MatchingAttributes> matchingRecordsMap = generateMatchingAttributeMap(
            matchingRecords
        );
        // Process contact matching to get initial results
        Map<String, MatchingResult> matchingResults = processContactMatching(matchingRecords);
        // Process key change to create or update  Contact Alternate Id and update Contact Records
        processKeyChange(matchingRecordsMap, matchingResults);
        return matchingResults;
    }

    /**
     * Processes contact matching for a list of records and returns a map of matching contacts.
     * Matches are determined based on predefined key fields.
     * If more than one match is found for any record, logs an error and excludes the record from the result.
     *
     * @param matchingRecords The list of records to match with existing contacts.
     * @return A map where keys are unique concatenated matching fields and values are matching results.
     */
    public static Map<String, MatchingResult> processContactMatching(
        List<MatchingAttributes> matchingRecords
    ) {
        // generate a matching attributes map where the key is the concatenated attributes with the noise
        Map<String, MatchingAttributes> matchingRecordsMap = generateMatchingAttributeMap(
            matchingRecords
        );
        // Remove noise from matching attributes fields before processing matching
        ContactMatchingConfigurationService.processNoiseRemoval(matchingRecordsMap);
        // Build relevant data structures for matching
        prepareDataStructureForMatching(matchingRecordsMap.values());
        // Initialize map to store matched contacts
        Map<String, MatchingResult> matchingResultMap = new Map<String, MatchingResult>();

        MatchingResult result;

        // Loop through the records to match with existing contacts
        for (String matchingRecordKey : matchingRecordsMap.keySet()) {
            // Initialize the result with default values
            result = new MatchingResult('', '');

            MatchingAttributes matchingRecord = matchingRecordsMap.get(matchingRecordKey);

            //checks if payload information is enough
            if (isPayloadNotEnough(matchingRecord)) {
                result = new MatchingResult('', 'Insufficient information to match');
            } else {
                // do criteria based matching
                result = processCriteriaBasedMatching(matchingRecord);
            }

            // Add the matched contact to the map using the matchingRecordKey
            // matchingRecordKey is the concatenated string with the noise
            // this would help the caller map the matching result to its respective data source
            matchingResultMap.put(matchingRecordKey, result);
        }

        return matchingResultMap;
    }

    /**
     * overload processContactMatching to set excluded contact ids
     *
     * @param matchingRecords The list of records to match with existing contacts.
     * @param contactIds set of contact ids to be excluded for contact matching
     * @return A map where keys are unique concatenated matching fields and values are matching results.
     */
    public static Map<String, MatchingResult> processContactMatching(
        List<MatchingAttributes> matchingRecords,
        Set<String> contactIds
    ) {
        excludedIds = contactIds;
        return processContactMatching(matchingRecords);
    }

    /**
     * Processes the matching criteria based on the provided MatchingAttributes and returns the MatchingResult.
     *
     * @param matchingRecord The MatchingAttributes containing the record to be matched.
     * @return The MatchingResult indicating whether a match was found or not, along with the matched Contact record.
     */
    private static MatchingResult processCriteriaBasedMatching(MatchingAttributes matchingRecord) {
        // Initialize the result with default values
        MatchingResult result = new MatchingResult('', '');

        // Process matching based on criteria and retrieve the matched contact or return an error as result
        if (SystemKeyMatchingValidator.isSystemKeyMatch(matchingRecord, systemKeyMatchingMap)) {
            result = SystemKeyMatchingValidator.processSystemKeyMatching(
                matchingRecord,
                systemKeyMatchingMap
            );
        } else if (
            PartialNaturalKeyMatchingValidator.isPartialNaturalKeyMatch(
                matchingRecord,
                partialNaturalKeyMatchingMap
            )
        ) {
            result = PartialNaturalKeyMatchingValidator.processPartialNaturalKeyMatching(
                matchingRecord,
                partialNaturalKeyMatchingMap
            );
        } else if (NoDOBMatchingValidator.isNoDOBMatch(matchingRecord, noDOBMatchingMap)) {
            result = NoDOBMatchingValidator.processNoDOBMatching(matchingRecord, noDOBMatchingMap);
        } else if (
            NaturalKeyMatchingValidator.isNaturalKeyMatch(matchingRecord, naturalKeyMatchingMap)
        ) {
            result = NaturalKeyMatchingValidator.processNaturalKeyMatching(
                matchingRecord,
                naturalKeyMatchingMap
            );
        } else if (
            MaidenFirstNameStemMatchingValidator.isMaidenOrFirstNameStemMatch(
                matchingRecord,
                maidenOrFirstNameStemMatchingMap
            )
        ) {
            result = MaidenFirstNameStemMatchingValidator.processMaidenOrFirstNameStemMatching(
                matchingRecord,
                maidenOrFirstNameStemMatchingMap
            );
        }

        return result;
    }

    /**
     * Processes key change for matching records and updates Contact and Contact Alternate ID records accordingly.
     * This method takes a list of matching records and a map of matching results.
     * It creates Contact Alternate ID records for non-system key matches and updates existing Contact Alternate ID records.
     *
     * @param matchingRecords The map of matching records containing attributes for each record.
     * @param matchingResults The map of matching results containing the result of each record's matching process.
     */
    public static void processKeyChange(
        Map<String, MatchingAttributes> matchingRecordsMap,
        Map<String, MatchingResult> matchingResults
    ) {
        Map<String, Contact_Alternate_ID__c> existingConAltIdsMap = ContactAlternateIdService.retrieveCAIGroupedByContactIdAndSystemKeyType(
            matchingResults.values()
        );
        List<Contact_Alternate_ID__c> insertedContactAlternateIds = ContactAlternateIdService.createCAIRecordsByMatchingResults(
            matchingRecordsMap,
            matchingResults
        );
        // Update Contact and Contact Alternate ID records based on the created and existing Contact Alternate ID records
        ContactAlternateIdService.updateContactAndContactAlternateIds(
            insertedContactAlternateIds,
            existingConAltIdsMap,
            true
        );
    }

    /**
     * Generates a unique concatenated key for a matching record based on specified field values.
     * This method concatenates non-null field values from the matching record using the provided field API names.
     *
     * @param record The matching record for which to generate the unique key.
     * @param fieldApiNames The list of API names of fields to include in the unique key generation.
     * @return String The unique concatenated key for the record.
     */
    public static String generateUniqueKey(MatchingAttributes record, List<String> fieldApiNames) {
        StringBuilder uniqueKeyBuilder = new StringBuilder();

        // Concatenate non-null field values using the specified field API names
        for (String fieldName : fieldApiNames) {
            if (String.isNotBlank(record.get(fieldName))) {
                uniqueKeyBuilder.append(String.valueOf(record.get(fieldName)));
            }
        }

        return uniqueKeyBuilder.build().toLowerCase();
    }

    /**
     * Determines if the payload provided in the MatchingAttributes object is not sufficient for matching.
     *
     * @param matchingRecord A MatchingAttributes object representing the payload to be evaluated.
     * @return true if the payload is not sufficient for matching, false otherwise.
     */
    private static boolean isPayloadNotEnough(MatchingAttributes matchingRecord) {
        // Check if any system key fields is populated
        boolean isForSystemKey =
            String.isNotBlank(matchingRecord.get('qutEmployeeId')) ||
            String.isNotBlank(matchingRecord.get('qutStudentId')) ||
            String.isNotBlank(matchingRecord.get('studyLinkApplicantId')) ||
            String.isNotBlank(matchingRecord.get('qtacApplicantId'));

        // Check if either email or mobile is populated but not all name and birthdate fields
        boolean isForPartialKey =
            String.isBlank(matchingRecord.get('firstName')) &&
            String.isNotBlank(matchingRecord.get('lastName')) &&
            String.isNotBlank(matchingRecord.get('birthDate')) &&
            (String.isNotBlank(matchingRecord.get('email')) ||
            String.isNotBlank(matchingRecord.get('mobilePhone')));

        // Check if either email or mobile is populated along with both name fields
        boolean isForNoDOB =
            String.isNotBlank(matchingRecord.get('firstName')) &&
            String.isNotBlank(matchingRecord.get('lastName')) &&
            (String.isNotBlank(matchingRecord.get('email')) ||
            String.isNotBlank(matchingRecord.get('mobilePhone')));

        // Check if all name and birthdate fields are populated
        boolean isForNaturalKey =
            String.isNotBlank(matchingRecord.get('firstName')) &&
            String.isNotBlank(matchingRecord.get('lastName')) &&
            String.isNotBlank(matchingRecord.get('birthDate'));

        // Return true if none of the conditions match
        return !isForSystemKey && !isForPartialKey && !isForNoDOB && !isForNaturalKey;
    }

    /**
     * Generates a map of MatchingAttributes keyed by a unique identifier.
     * Unique identifier are in lowercase
     *
     * @param matchingRecords A list of MatchingAttributes objects representing matching records.
     * @return A Map where keys are unique identifiers generated based on MatchingAttributes values, and values are MatchingAttributes objects.
     */
    public static Map<String, MatchingAttributes> generateMatchingAttributeMap(
        List<MatchingAttributes> matchingRecords
    ) {
        // Map to store matching records by unique key
        Map<String, MatchingAttributes> matchingRecordsMap = new Map<String, MatchingAttributes>();

        // Iterate through matching records to create a map with unique keys
        for (MatchingAttributes matchingRecord : matchingRecords) {
            // Generate a unique key for the matching record
            String uniqueKey = generateUniqueKey(
                matchingRecord,
                new List<String>(matchingRecord.fieldValues.keySet())
            );

            // Store the matching record in the map with the unique key
            matchingRecordsMap.put(uniqueKey, matchingRecord);
        }

        // Return the map containing matching records keyed by unique identifiers
        return matchingRecordsMap;
    }

    /**
     * Builds relevant data structures for contact matching based on the provided list of matching records.
     * Retrieves existing contacts and contact alternate id
     * Populates various maps used for different types of matching.
     *
     * @param matchingRecords A list of MatchingAttributes representing records to be matched with existing contacts.
     */
    private static void prepareDataStructureForMatching(List<MatchingAttributes> matchingRecords) {
        systemKeyMatchingMap = new Map<String, List<Contact>>();
        naturalKeyMatchingMap = new Map<String, List<Contact>>();
        maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>();
        partialNaturalKeyMatchingMap = new Map<String, List<Contact>>();
        noDOBMatchingMap = new Map<String, List<Contact>>();

        // retrieve relevent data for building matching records
        List<Contact> existingContacts = retrievePotentialContactMatches(matchingRecords);
        List<Contact_Alternate_ID__c> contactAlternateIds = ContactAlternateIdService.retrieveContactAlternateIdsBySystemKeyId(
            matchingRecords
        );

        // build data structure for matching
        systemKeyMatchingMap = SystemKeyMatchingValidator.buildSystemKeyMatchingMap(
            contactAlternateIds
        );
        for (Contact existingContact : existingContacts) {
            NaturalKeyMatchingValidator.buildNaturalKeyMatchingMap(
                existingContact,
                naturalKeyMatchingMap
            );
            MaidenFirstNameStemMatchingValidator.buildMaidenOrFirstNameStemMatchingMap(
                existingContact,
                maidenOrFirstNameStemMatchingMap
            );
            PartialNaturalKeyMatchingValidator.buildPartialNaturalKeyMatchingMap(
                existingContact,
                partialNaturalKeyMatchingMap
            );
            NoDOBMatchingValidator.buildNoDOBMatchingMap(existingContact, noDOBMatchingMap);
        }
    }

    /**
     * Retrieves potential contact matches based on matching attributes.
     * @param matchingRecords A list of MatchingAttributes containing matching record attributes.
     * @return A list of Contact records matching the specified matching attributes.
     */
    private static List<Contact> retrievePotentialContactMatches(
        List<MatchingAttributes> matchingRecords
    ) {
        // Initialize map of set of string to store unique first names, last names, mobile phones, and emails
        Map<String, Set<String>> fieldSetMap = new Map<String, Set<String>>{
            'firstName' => new Set<String>(),
            'lastName' => new Set<String>(),
            'mobilePhone' => new Set<String>(),
            'email' => new Set<String>(),
            'excludedIds' => excludedIds
        };

        Set<Date> birthDateSet = new Set<Date>();
        Set<String> fieldNames = new Set<String>{
            'firstName',
            'lastName',
            'birthDate',
            'mobilePhone',
            'email'
        };

        // by looping through the field names
        // Populate sets with attributes from matching records
        for (ContactMatchingService.MatchingAttributes matchingRecord : matchingRecords) {
            for (String fieldName : fieldNames) {
                if (fieldName == 'birthDate' && String.isNotBlank(matchingRecord.get(fieldName))) {
                    birthDateSet.add(Date.valueOf(matchingRecord.get(fieldName)));
                } else if (String.isNotBlank(matchingRecord.get(fieldName))) {
                    fieldSetMap.get(fieldName).add(matchingRecord.get(fieldName));
                }
            }
        }

        return ContactsDAO.newInstance()
            .getContactsByMatchingAttributes(fieldSetMap, birthDateSet, AccessLevel.SYSTEM_MODE);
    }

    /**
     * Invocable method to process contact matching based on provided attributes.
     * @param attributes List of FlowMatchingAttributes containing contact attributes
     * @return List of FlowMatchingResult indicating matching results for each attribute set
     */
    @InvocableMethod(label='Process Contact Matching')
    public static List<FlowMatchingResult> processContactMatchingInFlows(
        List<FlowMatchingAttributes> attributes
    ) {
        List<MatchingAttributes> matchingRecords = new List<MatchingAttributes>();
        Map<String, MatchingResult> matchingResult = new Map<String, MatchingResult>();
        MatchingResult result;
        List<FlowMatchingResult> flowMatchingResults = new List<FlowMatchingResult>();

        // Processing each FlowMatchingAttributes
        for (FlowMatchingAttributes attribute : attributes) {
            // Building formatted mobile phone if available
            String mobilePhone = String.isNotBlank(attribute.mobileLocale) &&
                String.isNotBlank(attribute.mobileNoLocale) &&
                attribute.mobileNoLocale.length() > 6
                ? MobileLoqateValidationService.buildMobile(
                      attribute.mobileNoLocale,
                      attribute.mobileLocale
                  )
                : '';

            // Creating map of attributes
            Map<String, String> attributesMap = new Map<String, String>{
                'firstName' => attribute.firstName,
                'lastName' => attribute.lastName,
                'mobilePhone' => mobilePhone,
                'email' => attribute.email
            };

            // Adding attributes to matching records
            matchingRecords.add(new MatchingAttributes(attributesMap));
        }

        // Processing contact matching
        matchingResult = processContactMatching(matchingRecords);

        // Creating FlowMatchingResults based on matching results
        for (String resultKey : matchingResult.keySet()) {
            result = matchingResult.get(resultKey);
            boolean error = !result.contactIds.isEmpty();
            flowMatchingResults.add(new FlowMatchingResult(error, resultKey));
        }

        return flowMatchingResults;
    }

    /**
     * Inner class representing attributes for contact matching in flows.
     */
    public class FlowMatchingAttributes {
        @InvocableVariable
        public String firstName;
        @InvocableVariable
        public String lastName;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String mobileLocale;
        @InvocableVariable
        public String mobileNoLocale;
    }

    /**
     * Inner class representing result of contact matching for flows.
     */
    public class FlowMatchingResult {
        @InvocableVariable
        public boolean error;
        @InvocableVariable
        public String uniqueKey;

        /**
         * Constructor to initialize FlowMatchingResult.
         * @param error Indicates if there's an error in matching
         * @param uniqueKey Unique identifier for the result
         */
        public FlowMatchingResult(boolean error, String uniqueKey) {
            this.error = error;
            this.uniqueKey = uniqueKey;
        }
    }

    /**
     * Represents a set of attributes used for matching records.
     * The keys used for initialization can/should include:
     * - 'firstName'
     * - 'lastName'
     * - 'email'
     * - 'birthDate'
     * - 'mobilePhone'
     * - 'qutEmployeeId'
     * - 'qutStudentId'
     * - 'studyLinkApplicantId'
     * - 'qtacApplicantId'
     */
    public class MatchingAttributes {
        // Map to store field values dynamically
        public Map<String, String> fieldValues = new Map<String, String>();

        /**
         * Constructor to initialize field values.
         * @param fieldValues A map containing field names as keys and corresponding values.
         */
        public MatchingAttributes(Map<String, String> fieldValues) {
            this.fieldValues.putAll(fieldValues);
        }

        /**
         * Returns the value of the specified field.
         * @param fieldName The API name of the field.
         * @return The value of the field.
         */
        public String get(String fieldName) {
            return fieldValues.get(fieldName);
        }

        /**
         * Sets the value of the specified field.
         * @param fieldName The API name of the field.
         * @param value The value to set.
         */
        public void set(String fieldName, String value) {
            fieldValues.put(fieldName, value);
        }
    }

    /**
     * Custom StringBuilder class for efficient string concatenation.
     */
    private class StringBuilder {
        // Internal buffer to store concatenated strings
        private String buffer;

        /**
         * Constructs a new StringBuilder with an empty buffer.
         */
        private StringBuilder() {
            buffer = '';
        }

        /**
         * Appends the specified string to the end of the buffer.
         *
         * @param str The string to append.
         */
        private void append(String str) {
            buffer += str;
        }

        /**
         * Builds and returns the concatenated string from the buffer.
         *
         * @return The concatenated string.
         */
        private String build() {
            return buffer;
        }
    }
}
