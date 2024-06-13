/**
 * @description Class for performing natural key matching on contact records.
 *              Natural key matching involves matching contacts based on a combination
 *              of attributes such as first name, last name, birth date, email, and mobile phone.
 *              This class provides methods to validate and process natural key matches, as well as
 *              build a map of natural keys to corresponding contacts.
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */

public inherited sharing class NaturalKeyMatchingValidator {
    // List of MatchingAttributes fields required for natural key matching.
    private static final List<String> NATURAL_KEY_FIELDS = new List<String>{
        'firstName',
        'lastName',
        'birthDate'
    };

    //List of MatchingAttributes fields required for natural key matching with email.
    private static final List<String> NATURAL_KEY_FIELDS_WITH_EMAIL = new List<String>{
        'firstName',
        'lastName',
        'birthDate',
        'email'
    };

    // List of MatchingAttributes fields required for natural key matching with mobile.
    private static final List<String> NATURAL_KEY_FIELDS_WITH_MOBILE = new List<String>{
        'firstName',
        'lastName',
        'birthDate',
        'mobilePhone'
    };

    // Matching type variables
    private static final String NATURAL_KEY_STEM_MATCHING_TYPE = 'Natural Key Matching';

    /**
     * Checks if a given contact record matches any existing contact based on natural keys.
     * @param matchingRecord - The record to be matched.
     * @param naturalKeyMatchingMap - A map containing existing contacts grouped by their natural keys.
     * @return Boolean - Returns true if a match is found, otherwise returns false.
     */
    public static boolean isNaturalKeyMatch(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> naturalKeyMatchingMap
    ) {
        // if any of the firstname, lastname or birthdate is blank
        // no natural key match
        for (String fieldName : NATURAL_KEY_FIELDS) {
            if (String.isBlank(matchingRecord.get(fieldName))) {
                return false;
            }
        }

        // Generate unique keys for natural key for base matching, email, and mobile
        String uniqueKey = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NATURAL_KEY_FIELDS
        );

        // Check if generated keys exists in the map
        // this means FirstName + LastName + Birthdate matched to an existing contact
        return naturalKeyMatchingMap.containsKey(uniqueKey);
    }

    /**
     * Processes natural key matching for a given contact record.
     * @param matchingRecord - The record to be matched.
     * @param naturalKeyMatchingMap - A map containing existing contacts grouped by their natural keys.
     * @return Contact - Returns the matching contact if a single match is found, otherwise returns null.
     */
    public static MatchingResult processNaturalKeyMatching(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> naturalKeyMatchingMap
    ) {
        // Initialize variables
        Set<Contact> matchingContacts = new Set<Contact>();

        // Generate unique keys for natural key
        String uniqueKey = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NATURAL_KEY_FIELDS
        );
        String uniqueKeyForEmail = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NATURAL_KEY_FIELDS_WITH_EMAIL
        );
        String uniqueKeyForMobile = ContactMatchingService.generateUniqueKey(
            matchingRecord,
            NATURAL_KEY_FIELDS_WITH_MOBILE
        );

        boolean isEmailPopulated = String.isNotBlank(matchingRecord.get('email'));
        boolean isMobilePhonePopulated = String.isNotBlank(matchingRecord.get('mobilePhone'));
        boolean isEmailOrMobilePopulated = isEmailPopulated || isMobilePhonePopulated;

        // if email or mobile is not populated in the payload
        if (!isEmailOrMobilePopulated) {
            //return the matching contacts
            matchingContacts.addAll(naturalKeyMatchingMap.get(uniqueKey));
            return new MatchingResult(matchingContacts, NATURAL_KEY_STEM_MATCHING_TYPE);
        }

        // Add contacts matching the natural key with email
        if (isEmailPopulated && naturalKeyMatchingMap.containsKey(uniqueKeyForEmail)) {
            matchingContacts.addAll(naturalKeyMatchingMap.get(uniqueKeyForEmail));
        }
        // Add contacts matching the natural key with mobile phone
        if (isMobilePhonePopulated && naturalKeyMatchingMap.containsKey(uniqueKeyForMobile)) {
            matchingContacts.addAll(naturalKeyMatchingMap.get(uniqueKeyForMobile));
        }

        // if contact(s) were found by email or mobile matching, return matching results
        if(!matchingContacts.isEmpty()){
            return new MatchingResult(matchingContacts, NATURAL_KEY_STEM_MATCHING_TYPE);
        }

        String emailPayload = matchingRecord.get('email');
        String mobilePhonePayload = matchingRecord.get('mobilePhone');

        //If still no contact(s) found
        //loop through all contacts matching through natural key
        for (Contact con : naturalKeyMatchingMap.get(uniqueKey)) {
            
            // if any of the existing contact emails are populated and not equal to payload email
            boolean isEmailMismatch =
                String.isNotBlank(emailPayload) &&
                ((con.Email != null && con.Email != emailPayload) ||
                (con.QUT_Learner_Email__c != null && con.QUT_Learner_Email__c != emailPayload) ||
                (con.QUT_Staff_Email__c != null && con.QUT_Staff_Email__c != emailPayload) ||
                (con.Work_Email__c != null && con.Work_Email__c != emailPayload));
            
            // if mobilephone is populated and not equal to payload mobile phone
            boolean isMobilePhoneMismatch = String.isNotBlank(mobilePhonePayload) && con.MobilePhone != null && con.MobilePhone != mobilePhonePayload;

            boolean isConfirmationRuleFailed = isEmailMismatch || isMobilePhoneMismatch;

            if (isConfirmationRuleFailed) {
                return new MatchingResult(
                    NATURAL_KEY_STEM_MATCHING_TYPE,
                    'Contact Record does not match email and/or mobile provided'
                );
            }

            //if existing contact emails and mobile phone are null 
            //or if one of the emails matched with the payload email
            //or if mobilephone matched with the payload mobilephone
            matchingContacts.add(con);
        }

        return new MatchingResult(matchingContacts, NATURAL_KEY_STEM_MATCHING_TYPE);
    }

    /**
     * Builds a map of natural keys to corresponding contacts from a single existing contact.
     *
     * @param existingContact The existing contact for which to build the natural key map.
     * @param naturalKeyMatchingMap The map to populate with natural keys and corresponding contacts.
     */
    public static void buildNaturalKeyMatchingMap(
        Contact existingContact,
        Map<String, List<Contact>> naturalKeyMatchingMap
    ) {
        // Skip the contact if it doesn't have necessary natural key fields
        if (!hasRequiredNaturalKeyFields(existingContact)) {
            return;
        }

         // Generate unique natural keys for base fields of the contact and add them to the map
         buildUniqueNaturalKeyContactMap('', existingContact, naturalKeyMatchingMap);

         // Generate unique natural keys for Email or Mobile fields of the contact and add them to the map
         for (String fieldApiName : ContactMatchingService.KEY_FIELDS_ON_CONTACT) {
             buildUniqueNaturalKeyContactMap(fieldApiName, existingContact, naturalKeyMatchingMap);
         }
    }

    /**
     * Checks if a contact has the required fields for a natural key.
     *
     * @param contact The contact to check.
     * @return Boolean Returns true if the contact has non-null values for FirstName, LastName, and Birthdate; otherwise, returns false.
     */
    private static Boolean hasRequiredNaturalKeyFields(Contact contact) {
        return contact.Matching_Firstname__c != null &&
            contact.Matching_Lastname__c != null &&
            contact.Birthdate != null;
    }

    /**
     * Generates a unique natural key for a contact based on specific field values.
     * @param fieldApiName - The API name of the field to include in the natural key.
     * @param contact - The contact record.
     * @param naturalKeyMatchingMap - A map to store the generated natural key and corresponding contacts.
     */
    private static void buildUniqueNaturalKeyContactMap(
        String fieldApiName,
        Contact contact,
        Map<String, List<Contact>> naturalKeyMatchingMap
    ) {
        // Generate the unique natural key for the contact based on specified field values
        String uniqueKey = '';

        uniqueKey += contact.Matching_Firstname__c;
        uniqueKey += contact.Matching_Lastname__c;
        uniqueKey += String.valueOf(contact.Birthdate);

        if  (String.isNotBlank(fieldApiName) &&  contact.get(fieldApiName) == null){
            return;
        }

        if (String.isNotBlank(fieldApiName) && contact.get(fieldApiName) != null) {
            uniqueKey += String.valueOf(contact.get(fieldApiName));
        }

        uniqueKey = uniqueKey.toLowerCase();

        // Add the contact to the corresponding list in the map based on the generated natural key
        if (!naturalKeyMatchingMap.containsKey(uniqueKey)) {
            naturalKeyMatchingMap.put(uniqueKey, new List<Contact>());
        }
        naturalKeyMatchingMap.get(uniqueKey).add(contact);
    }
}
