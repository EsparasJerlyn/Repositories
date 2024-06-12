/**
 * @description Validator class responsible for matching contact records when the birth date (DOB) is not available.
 *              Matches are based on a subset of attributes, excluding birth date, such as first name, last name, email, and mobile phone.
 *              This class provides methods to check for matches, process matching records, and build a map of contacts grouped by matching attribute values.
 *
 *              The class offers functionality to check if contacts with the same attributes exist, process matching records to identify single matches,
 *              and build a map of existing contacts grouped by their matching attribute values for efficient matching operations.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */
public inherited sharing class NoDOBMatchingValidator {
    /**
     * @description List of fields required for matching with email.
     */
    private static final List<String> NO_DOB_FIELDS_WITH_EMAIL = new List<String>{
        'firstName',
        'lastName',
        'email'
    };

    /**
     * @description List of fields required for matching with mobile phone.
     */
    private static final List<String> NO_DOB_FIELDS_WITH_MOBILE = new List<String>{
        'firstName',
        'lastName',
        'mobilePhone'
    };

    // Matching type variables
    private static final String NO_DOB_MATCHING_TYPE = 'No DOB Matching';

    /**
     * @description Checks if a given contact record matches any existing contact when the birth date is not available.
     * @param matchingRecord - The record to be matched.
     * @param noDOBMatchingMap - A map containing existing contacts grouped by their matching attributes.
     * @return Boolean - Returns true if a match is found, otherwise returns false.
     */
    public static boolean isNoDOBMatch(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> noDOBMatchingMap
    ) {
        if (String.isNotBlank(matchingRecord.get('birthDate'))) {
            return false;
        }

        String uniqueKeyForEmail = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NO_DOB_FIELDS_WITH_EMAIL
        );

        String uniqueKeyForMobile = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NO_DOB_FIELDS_WITH_MOBILE
        );

        return noDOBMatchingMap.containsKey(uniqueKeyForEmail) ||
            noDOBMatchingMap.containsKey(uniqueKeyForMobile);
    }

    /**
     * @description Processes matching for a given contact record when the birth date is not available.
     * @param matchingRecord - The record to be matched.
     * @param noDOBMatchingMap - A map containing existing contacts grouped by their matching attributes.
     * @return Contact - Returns the matching contact if a single match is found, otherwise returns null.
     */
    public static MatchingResult processNoDOBMatching(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> noDOBMatchingMap
    ) {
        Set<Contact> matchingContacts = new Set<Contact>();

        String uniqueKeyForEmail = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NO_DOB_FIELDS_WITH_EMAIL
        );

        String uniqueKeyForMobile = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NO_DOB_FIELDS_WITH_MOBILE
        );

        if (noDOBMatchingMap.containsKey(uniqueKeyForEmail)) {
            matchingContacts.addAll(noDOBMatchingMap.get(uniqueKeyForEmail));
        }

        if (noDOBMatchingMap.containsKey(uniqueKeyForMobile)) {
            matchingContacts.addAll(noDOBMatchingMap.get(uniqueKeyForMobile));
        }

        return new MatchingResult(matchingContacts, NO_DOB_MATCHING_TYPE);
    }

    /**
     * Builds a map of contacts without a Date of Birth (DOB) to corresponding contacts from a single existing contact.
     *
     * @param existingContact The existing contact from which to extract contacts without a Date of Birth.
     * @param noDOBMatchingMap The map to populate with contacts without a Date of Birth and corresponding contacts.
     */
    public static void buildNoDOBMatchingMap(
        Contact existingContact,
        Map<String, List<Contact>> noDOBMatchingMap
    ) {
        if (!hasRequiredNoDOBFields(existingContact)) {
            // Skip contacts without necessary matching attributes
            return;
        }

        for (String fieldApiName : ContactMatchingService.KEY_FIELDS_ON_CONTACT) {
            buildUniqueNoDOBContactMap(fieldApiName, existingContact, noDOBMatchingMap);
        }
    }

    /**
     * @description Checks if a contact has the required fields for matching when the birth date is not available.
     * @param contact - The contact to check.
     * @return Boolean - Returns true if the contact has non-null values for FirstName and LastName; otherwise, returns false.
     */
    private static Boolean hasRequiredNoDOBFields(Contact contact) {
        boolean isEmailOrMobilePhonePopulated =
            contact.Email != null ||
            contact.QUT_Staff_Email__c != null ||
            contact.QUT_Learner_Email__c != null ||
            contact.Work_Email__c != null ||
            contact.MobilePhone != null;

        return contact.Matching_Firstname__c != null &&
            contact.Matching_Lastname__c != null &&
            isEmailOrMobilePhonePopulated;
    }

    /**
     * @description Generates a unique key for a contact based on specific field values when the birth date is not available.
     * @param fieldApiName - The API name of the field to include in the unique key.
     * @param contact - The contact record.
     * @param noDOBMatchingMap - A map to store the generated unique key and corresponding contacts.
     */
    private static void buildUniqueNoDOBContactMap(
        String fieldApiName,
        Contact contact,
        Map<String, List<Contact>> noDOBMatchingMap
    ) {
        if (contact.get(fieldApiName) == null) {
            return; // Skip if the field value is null
        }

        // Generate the unique key for the contact based on specified field values
        String uniqueKey = '';

        uniqueKey += contact.Matching_Firstname__c;
        uniqueKey += contact.Matching_Lastname__c;
        uniqueKey += String.valueOf(contact.get(fieldApiName));

        uniqueKey = uniqueKey.toLowerCase();

        // Add the contact to the corresponding list in the map based on the generated unique key
        if (!noDOBMatchingMap.containsKey(uniqueKey)) {
            noDOBMatchingMap.put(uniqueKey, new List<Contact>());
        }
        noDOBMatchingMap.get(uniqueKey).add(contact);
    }
}
