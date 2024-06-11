/**
 * @description Validator class responsible for performing partial natural key matching on contact records.
 *              Partial natural key matching involves matching contacts based on a subset of attributes, such as last name, birth date, email, and mobile phone.
 *              This class provides methods to check for matches, process matching records, and build a map of contacts grouped by partial natural key values.
 *
 *              The class offers functionality to check if contacts with the same partial natural key values exist, process matching records to identify single matches,
 *              and build a map of existing contacts grouped by their partial natural key values for efficient matching operations.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */
public inherited sharing class PartialNaturalKeyMatchingValidator {
    /**
     * @description List of fields required for partial natural key matching with email.
     */
    private static final List<String> PARTIAL_NATURAL_KEY_FIELDS_WITH_EMAIL = new List<String>{
        'lastName',
        'birthDate',
        'email'
    };

    /**
     * @description List of fields required for partial natural key matching with mobile phone.
     */
    private static final List<String> PARTIAL_NATURAL_KEY_FIELDS_WITH_MOBILE = new List<String>{
        'lastName',
        'birthDate',
        'mobilePhone'
    };

    // Matching type variables
    private static final String PARTIAL_NATURAL_KEY_MATCHING_TYPE = 'Partial Natural Key Matching';

    /**
     * @description Checks if a given contact record matches any existing contact based on partial natural keys.
     * @param matchingRecord - The record to be matched.
     * @param partialNaturalKeyMatchingMap - A map containing existing contacts grouped by their partial natural keys.
     * @return Boolean - Returns true if a match is found, otherwise returns false.
     */
    public static boolean isPartialNaturalKeyMatch(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> partialNaturalKeyMatchingMap
    ) {
        if (String.isNotBlank(matchingRecord.get('firstName'))) {
            return false;
        }

        String uniqueKeyForEmail = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            PARTIAL_NATURAL_KEY_FIELDS_WITH_EMAIL
        );
        String uniqueKeyForMobile = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            PARTIAL_NATURAL_KEY_FIELDS_WITH_MOBILE
        );

        matchingRecord.set('uniqueKeyForEmail', uniqueKeyForEmail);
        matchingRecord.set('uniqueKeyForMobile', uniqueKeyForMobile);

        return partialNaturalKeyMatchingMap.containsKey(uniqueKeyForEmail) ||
            partialNaturalKeyMatchingMap.containsKey(uniqueKeyForMobile);
    }

    /**
     * @description Processes partial natural key matching for a given contact record.
     * @param matchingRecord - The record to be matched.
     * @param partialNaturalKeyMatchingMap - A map containing existing contacts grouped by their partial natural keys.
     * @return Contact - Returns the matching contact if a single match is found, otherwise returns null.
     */
    public static MatchingResult processPartialNaturalKeyMatching(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> partialNaturalKeyMatchingMap
    ) {
        Set<Contact> matchingContacts = new Set<Contact>();

        String uniqueKeyForEmail = matchingRecord.get('uniqueKeyForEmail');
        String uniqueKeyForMobile = matchingRecord.get('uniqueKeyForMobile');

        if (partialNaturalKeyMatchingMap.containsKey(uniqueKeyForEmail)) {
            matchingContacts.addAll(partialNaturalKeyMatchingMap.get(uniqueKeyForEmail));
        }

        if (partialNaturalKeyMatchingMap.containsKey(uniqueKeyForMobile)) {
            matchingContacts.addAll(partialNaturalKeyMatchingMap.get(uniqueKeyForMobile));
        }

        return new MatchingResult(matchingContacts, PARTIAL_NATURAL_KEY_MATCHING_TYPE);
    }

    /**
     * Builds a map of partial natural keys to corresponding contacts from a single existing contact.
     *
     * @param existingContact The existing contact for which to build the partial natural key map.
     * @param partialNaturalKeyMatchingMap The map to populate with partial natural keys and corresponding contacts.
     */
    public static void buildPartialNaturalKeyMatchingMap(
        Contact existingContact,
        Map<String, List<Contact>> partialNaturalKeyMatchingMap
    ) {
        // Skip the contact if it doesn't have necessary partial natural key fields
        if (!hasRequiredPartialNaturalKeyFields(existingContact)) {
            return;
        }

        // Generate unique partial natural keys for each key field of the contact and add them to the map
        for (String fieldApiName : ContactMatchingService.KEY_FIELDS_ON_CONTACT) {
            buildUniquePartialNaturalKeyContactMap(
                fieldApiName,
                existingContact,
                partialNaturalKeyMatchingMap
            );
        }
    }

    /**
     * @description Checks if a contact has the required fields for a partial natural key.
     * @param contact - The contact to check.
     * @return Boolean - Returns true if the contact has non-null values for LastName and Birthdate; otherwise, returns false.
     */
    private static Boolean hasRequiredPartialNaturalKeyFields(Contact contact) {
        boolean isEmailOrMobilePhonePopulated =
            contact.Email != null ||
            contact.QUT_Staff_Email__c != null ||
            contact.QUT_Learner_Email__c != null ||
            contact.Work_Email__c != null ||
            contact.MobilePhone != null;

        return contact.Matching_Lastname__c != null &&
            contact.Birthdate != null &&
            isEmailOrMobilePhonePopulated;
    }

    /**
     * @description Generates a unique partial natural key for a contact based on specific field values.
     * @param fieldApiName - The API name of the field to include in the partial natural key.
     * @param contact - The contact record.
     * @param partialNaturalKeyMatchingMap - A map to store the generated partial natural key and corresponding contacts.
     */
    private static void buildUniquePartialNaturalKeyContactMap(
        String fieldApiName,
        Contact contact,
        Map<String, List<Contact>> partialNaturalKeyMatchingMap
    ) {
        if (contact.get(fieldApiName) == null) {
            return; // Skip if the field value is null
        }

        // Generate the unique partial natural key for the contact based on specified field values
        String uniqueKey = '';

        uniqueKey += contact.Matching_Lastname__c;
        uniqueKey += String.valueOf(contact.Birthdate);
        uniqueKey += String.valueOf(contact.get(fieldApiName));

        uniqueKey = uniqueKey.toLowerCase();

        // Add the contact to the corresponding list in the map based on the generated partial natural key
        if (!partialNaturalKeyMatchingMap.containsKey(uniqueKey)) {
            partialNaturalKeyMatchingMap.put(uniqueKey, new List<Contact>());
        }
        partialNaturalKeyMatchingMap.get(uniqueKey).add(contact);
    }
}
