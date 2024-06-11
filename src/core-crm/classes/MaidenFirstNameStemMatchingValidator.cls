/**
 * @description Provides methods for matching contact records based on the stem of the first name or maiden name.
 *              Matches are based on a subset of attributes, including first name, last name, birth date, email, and mobile phone.
 *              This class offers functionality to check for matches, process matching records, and build a map of contacts grouped by matching attribute values.
 *
 *              The class includes methods to:
 *              1. Check if contacts with the same attributes exist.
 *              2. Process matching records to identify single matches.
 *              3. Build a map of existing contacts grouped by their matching attribute values for efficient matching operations.
 *
 *              Matching can be based on the stem of the first name or the entire maiden name, along with other specified attributes.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */
public inherited sharing class MaidenFirstNameStemMatchingValidator {
    // List of fields required for matching with maiden name and email
    private static final List<String> MAIDEN_NAME_FIELDS_WITH_EMAIL = new List<String>{
        'firstName',
        'birthDate',
        'email'
    };

    // List of fields required for matching with maiden name and mobile phone
    private static final List<String> MAIDEN_NAME_FIELDS_WITH_MOBILE = new List<String>{
        'firstName',
        'birthDate',
        'mobilePhone'
    };

    // List of fields required for first name stem matching with email
    private static final List<String> FIRST_NAME_STEM_FIELDS_WITH_EMAIL = new List<String>{
        'firstName',
        'lastName',
        'birthDate',
        'email'
    };

    // List of fields required for first name stem matching with mobile
    private static final List<String> FIRST_NAME_STEM_FIELDS_WITH_MOBILE = new List<String>{
        'firstName',
        'lastName',
        'birthDate',
        'mobilePhone'
    };

    // Matching type variables
    private static final String FIRST_NAME_STEM_MATCHING_TYPE = 'First Name Stem Matching';
    private static final String MAIDEN_NAME_MATCHING_TYPE = 'Maiden Name Matching';

    /**
     * Checks if the provided matching record has a match based on the maiden name or stem of the first name.
     *
     * @param matchingRecord The matching record attributes.
     * @param maidenOrFirstNameStemMatchingMap A map of existing contacts grouped by their matching attribute values.
     * @return True if a match is found based on the maiden name or stem of the first name, false otherwise.
     */
    public static boolean isMaidenOrFirstNameStemMatch(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap
    ) {
        // skip if one of the fields below is blank
        if (
            String.isBlank(matchingRecord.get('firstName')) ||
            String.isBlank(matchingRecord.get('lastName')) ||
            String.isBlank(matchingRecord.get('birthDate'))
        ) {
            return false;
        }

        String uniqueKeyForMaidenNameEmail = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            MAIDEN_NAME_FIELDS_WITH_EMAIL
        );

        String uniqueKeyForMaidenNameMobile = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            MAIDEN_NAME_FIELDS_WITH_MOBILE
        );

        String uniqueKeyForFirstNameStemEmail = generateUniqueKeyForFirstNameStem(
            matchingRecord,
            FIRST_NAME_STEM_FIELDS_WITH_EMAIL
        );

        String uniqueKeyForFirstNameStemMobile = generateUniqueKeyForFirstNameStem(
            matchingRecord,
            FIRST_NAME_STEM_FIELDS_WITH_MOBILE
        );

        matchingRecord.set('uniqueKeyForMaidenNameEmail',uniqueKeyForMaidenNameEmail);
        matchingRecord.set('uniqueKeyForMaidenNameMobile',uniqueKeyForMaidenNameMobile);
        matchingRecord.set('uniqueKeyForFirstNameStemEmail',uniqueKeyForFirstNameStemEmail);
        matchingRecord.set('uniqueKeyForFirstNameStemMobile',uniqueKeyForFirstNameStemMobile);

        return maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForMaidenNameEmail) ||
            maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForMaidenNameMobile) ||
            maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForFirstNameStemEmail) ||
            maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForFirstNameStemMobile);
    }

    /**
     * Processes the matching record to identify single matches based on the maiden name or stem of the first name.
     *
     * @param matchingRecord The matching record attributes.
     * @param maidenOrFirstNameStemMatchingMap A map of existing contacts grouped by their matching attribute values.
     * @return The single matching contact if found, otherwise null.
     */
    public static MatchingResult processMaidenOrFirstNameStemMatching(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap
    ) {
        Set<Contact> matchingContacts = new Set<Contact>();

        String uniqueKeyForMaidenNameEmail = matchingRecord.get('uniqueKeyForMaidenNameEmail');
        String uniqueKeyForMaidenNameMobile = matchingRecord.get('uniqueKeyForMaidenNameMobile');
        String uniqueKeyForFirstNameStemEmail = matchingRecord.get('uniqueKeyForFirstNameStemEmail');
        String uniqueKeyForFirstNameStemMobile = matchingRecord.get('uniqueKeyForFirstNameStemMobile');

        String matchingType = '';

        if (maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForMaidenNameEmail)) {
            matchingContacts.addAll(
                maidenOrFirstNameStemMatchingMap.get(uniqueKeyForMaidenNameEmail)
            );

            matchingType = MAIDEN_NAME_MATCHING_TYPE;
        }

        if (maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForMaidenNameMobile)) {
            matchingContacts.addAll(
                maidenOrFirstNameStemMatchingMap.get(uniqueKeyForMaidenNameMobile)
            );

            matchingType = MAIDEN_NAME_MATCHING_TYPE;
        }

        if (maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForFirstNameStemEmail)) {
            matchingContacts.addAll(
                maidenOrFirstNameStemMatchingMap.get(uniqueKeyForFirstNameStemEmail)
            );

            matchingType = FIRST_NAME_STEM_MATCHING_TYPE;
        }

        if (maidenOrFirstNameStemMatchingMap.containsKey(uniqueKeyForFirstNameStemMobile)) {
            matchingContacts.addAll(
                maidenOrFirstNameStemMatchingMap.get(uniqueKeyForFirstNameStemMobile)
            );

            matchingType = FIRST_NAME_STEM_MATCHING_TYPE;
        }

        return new MatchingResult(matchingContacts, matchingType);
    }

    /**
     * Builds a map of maiden names or first name stems to corresponding contacts from a single existing contact.
     *
     * @param existingContact The existing contact from which to extract maiden names or first name stems.
     * @param maidenOrFirstNameStemMatchingMap The map to populate with maiden names or first name stems and corresponding contacts.
     */
    public static void buildMaidenOrFirstNameStemMatchingMap(
        Contact existingContact,
        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap
    ) {
        if (!hasRequiredMaidenOrFirtsNameStemFields(existingContact)) {
            // Skip contacts without necessary matching attributes
            return;
        }

        for (String fieldApiName : ContactMatchingService.KEY_FIELDS_ON_CONTACT) {
            buildUniqueMaidenContactMap(
                fieldApiName,
                existingContact,
                maidenOrFirstNameStemMatchingMap
            );
            buildUniqueFirstNameStemContactMap(
                fieldApiName,
                existingContact,
                maidenOrFirstNameStemMatchingMap
            );
        }
    }

    /**
     * Checks if the contact has the required attributes for matching based on the maiden name or stem of the first name.
     *
     * @param contact The contact record to be checked.
     * @return True if the contact has the required attributes, false otherwise.
     */
    private static Boolean hasRequiredMaidenOrFirtsNameStemFields(Contact contact) {
        boolean isEmailOrMobilePhonePopulated =
            contact.Email != null ||
            contact.QUT_Staff_Email__c != null ||
            contact.QUT_Learner_Email__c != null ||
            contact.Work_Email__c != null ||
            contact.MobilePhone != null;

        boolean isBaseMaidenCriteriaPassed =
            contact.Matching_Firstname__c != null &&
            contact.Birthdate != null;

        boolean isBaseFirstNameStemCriteriaPassed =
            contact.Matching_Firstname__c != null &&
            contact.Matching_Firstname__c.length() > 2 &&
            contact.Matching_Lastname__c != null &&
            contact.Birthdate != null;

        return isEmailOrMobilePhonePopulated &&
            (isBaseMaidenCriteriaPassed || isBaseFirstNameStemCriteriaPassed);
    }

    /**
     * Builds a unique key for the contact based on specified field values for maiden name matching.
     *
     * @param fieldApiName The API name of the field to be used in generating the unique key.
     * @param contact The contact record from which to extract field values.
     * @param maidenOrFirstNameStemMatchingMap The map to which the contact will be added.
     */
    private static void buildUniqueMaidenContactMap(
        String fieldApiName,
        Contact contact,
        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap
    ) {
        if (contact.get(fieldApiName) == null) {
            return; // Skip if the field value is null
        }

        // Generate the unique maiden name key for the contact based on specified field values
        String uniqueKey = '';

        uniqueKey += contact.Matching_Firstname__c;
        uniqueKey += String.valueOf(contact.Birthdate);
        uniqueKey += String.valueOf(contact.get(fieldApiName));

        uniqueKey = uniqueKey.toLowerCase();

        // Add the contact to the corresponding list in the map based on the generated unique key
        if (!maidenOrFirstNameStemMatchingMap.containsKey(uniqueKey)) {
            maidenOrFirstNameStemMatchingMap.put(uniqueKey, new List<Contact>());
        }
        maidenOrFirstNameStemMatchingMap.get(uniqueKey).add(contact);
    }

    /**
     * Builds a unique key for the contact based on specified field values for stem of the first name matching.
     *
     * @param fieldApiName The API name of the field to be used in generating the unique key.
     * @param contact The contact record from which to extract field values.
     * @param maidenOrFirstNameStemMatchingMap The map to which the contact will be added.
     */
    private static void buildUniqueFirstNameStemContactMap(
        String fieldApiName,
        Contact contact,
        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap
    ) {
        // Skip if the field value is null or if the first name length is less than 3 characters
        if (contact.get(fieldApiName) == null || contact.Matching_Firstname__c.length() < 3) {
            return;
        }

        // Generate the unique first name stem key for the contact based on specified field values
        String uniqueKey = '';

        uniqueKey += contact.Matching_Firstname__c.subString(0, 3);
        uniqueKey += contact.Matching_Lastname__c;
        uniqueKey += String.valueOf(contact.Birthdate);
        uniqueKey += String.valueOf(contact.get(fieldApiName));

        uniqueKey = uniqueKey.toLowerCase();

        if (!maidenOrFirstNameStemMatchingMap.containsKey(uniqueKey)) {
            maidenOrFirstNameStemMatchingMap.put(uniqueKey, new List<Contact>());
        }
        maidenOrFirstNameStemMatchingMap.get(uniqueKey).add(contact);
    }

    /**
     * Generates a unique key based on the provided matching record attributes and specified field API names.
     * Concatenates non-null field values using the specified field API names to create a unique identifier for the record.
     * If the field name is 'firstName' and its value has a length greater than 2 characters, only the first three characters are considered.
     *
     * @param record The matching record attributes from which to extract field values.
     * @param fieldApiNames A list of field API names to be used in generating the unique key.
     * @return A string representing the unique key generated from the specified field values.
     */
    private static String generateUniqueKeyForFirstNameStem(
        ContactMatchingService.MatchingAttributes record,
        List<String> fieldApiNames
    ) {
        String uniqueKey = '';

        // Concatenate non-null field values using the specified field API names
        for (String fieldName : fieldApiNames) {
            if (String.isBlank(record.get(fieldName))) {
                continue;
            }

            if (fieldName == 'firstName' && record.get(fieldName).length() > 2) {
                uniqueKey += String.valueOf(record.get(fieldName)).subString(0, 3);
            } else {
                uniqueKey += record.get(fieldName);
            }
        }

        return uniqueKey.toLowerCase();
    }
}
