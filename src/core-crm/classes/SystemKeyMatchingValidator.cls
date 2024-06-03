/**
 * @description Class responsible for performing contact matching based on system key fields.
 *              This class provides methods to check for matches, process matching records, and build a map of contacts grouped by system keys.
 *              Matches are determined based on predefined system key fields, such as QUT Employee ID, QUT Student ID, StudyLink Applicant ID, and QTAC Applicant ID.
 *
 *              The class offers functionality to check if contacts with the same system key values exist, process matching records to identify single matches,
 *              and build a map of existing contacts grouped by their system key values for efficient matching operations.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */

public inherited sharing class SystemKeyMatchingValidator {
    // Matching type variables
    private static final String SYSTEM_KEY_MATCHING_TYPE = 'System Key Matching';

    /**
     * @description Checks if contacts with the same QUT Employee Id, QUT Student Id, StudyLink Id, or QTAC Id exist.
     * @param matchingRecord - The record to match with existing contacts.
     * @param systemKeyMatchingMap - Contacts grouped by system keys.
     * @return Boolean - Returns true if a contact match is found based on any system key, otherwise returns false.
     */
    public static boolean isSystemKeyMatch(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> systemKeyMatchingMap
    ) {
        Map<String, String> systemKeyToTypeMap = ContactAlternateIdService.SYSTEM_KEY_TO_TYPE_MAP;
        // Loop through each contact ID field to check for matches
        for (String systemKeyField : systemKeyToTypeMap.keySet()) {
            //e.g. 123456QUT Employee ID
            String uniqueKey =
                matchingRecord.get(systemKeyField) + systemKeyToTypeMap.get(systemKeyField);
            // Check if the system key matching map contains the current contact ID field value
            if (
                String.isNotBlank(matchingRecord.get(systemKeyField)) &&
                systemKeyMatchingMap.containsKey(uniqueKey)
            ) {
                return true; // Contact match found based on the current system key
            }
        }

        return false;
    }

    /**
     * @description Matches the record using the system key + key type and returns the single contact match.
     *              If more than one match is found, logs an error and returns null.
     * @param matchingRecord - The record to match with existing contacts.
     * @param systemKeyMatchingMap - Contacts grouped by system keys.
     * @return Contact - Returns a contact if one match is found, or null if more than one match is found.
     */
    public static MatchingResult processSystemKeyMatching(
        ContactMatchingService.MatchingAttributes matchingRecord,
        Map<String, List<Contact>> systemKeyMatchingMap
    ) {
        Set<Contact> matchingContacts = new Set<Contact>();
        Map<String, String> systemKeyToTypeMap = ContactAlternateIdService.SYSTEM_KEY_TO_TYPE_MAP;

        // Loop through each contact ID field to check for matches
        for (String systemKeyField : systemKeyToTypeMap.keySet()) {
            if (String.isBlank(matchingRecord.get(systemKeyField))) {
                continue;
            }
            // the system key field value on the payload  e.g 123456
            String fieldValue = matchingRecord.get(systemKeyField);
            //e.g. 123456QUT Employee ID
            String uniqueKey = fieldValue + systemKeyToTypeMap.get(systemKeyField);
            // Check if the system key matching map contains the current contact ID field value + the system key type
            if (systemKeyMatchingMap.containsKey(uniqueKey)) {
                // Retrieve the list of contacts associated with the current contact ID field value + the system key type
                matchingContacts.addAll(systemKeyMatchingMap.get(uniqueKey));
            }
        }

        return new MatchingResult(matchingContacts, SYSTEM_KEY_MATCHING_TYPE);
    }

    /**
     * @description Builds a map of contacts grouped by system key values.
     *              This method iterates through the list of existing contact alternate IDs and organizes them into a map,
     *              where keys are system key values (e.g., 123456,1234567) + system key types (e.g., QUT Employee ID, QUT Student ID)
     *              and values are lists of contacts associated with the corresponding system key.
     *
     *              Contacts are grouped based on the presence of non-null system key values + system key types on the Active child Contact Alternate ID records.
     *              If a contact alternate id record has a non-null value for a specific system key field and system key type,
     *              the parent contact is added to the list corresponding to that key in the map.
     *
     * @param contactAlternateIds - The list of contact alternate IDs containing references to contacts and their related information.
     * @return Map<String, List<Contact>> - Returns a map where keys are system key values + system key types and values are lists of contacts
     *                                      associated with the corresponding system key.
     */
    public static Map<String, List<Contact>> buildSystemKeyMatchingMap(
        List<Contact_Alternate_ID__c> contactAlternateIds
    ) {
        // Initialize the map to store contacts grouped by system key values
        Map<String, List<Contact>> systemKeyMatchingMap = new Map<String, List<Contact>>();

        Contact contactRecord;
        // Iterate through the existing contact alternate IDs
        for (Contact_Alternate_ID__c alternateIdRecord : contactAlternateIds) {
            // Create a new contact record based on the information from the contact alternate ID record
            contactRecord = new Contact(
                Id = alternateIdRecord.Contact__c,
                FirstName = alternateIdRecord.Contact__r.FirstName,
                LastName = alternateIdRecord.Contact__r.LastName,
                MobilePhone = alternateIdRecord.Contact__r.MobilePhone,
                Email = alternateIdRecord.Contact__r.Email,
                QUT_Staff_Email__c = alternateIdRecord.Contact__r.QUT_Staff_Email__c,
                QUT_Learner_Email__c = alternateIdRecord.Contact__r.QUT_Learner_Email__c,
                Work_Email__c = alternateIdRecord.Contact__r.Work_Email__c,
                QUT_Student_ID__c = alternateIdRecord.Contact__r.QUT_Student_ID__c,
                QUT_Employee_ID__c = alternateIdRecord.Contact__r.QUT_Employee_ID__c
            );

            //e.g. 123456QUT Employee ID
            String uniqueKey =
                alternateIdRecord.Contact_Alternate_Id__c + alternateIdRecord.Alternate_Id_Type__c;
            // If the system key value is not already a key in the map, create a new list for it
            if (!systemKeyMatchingMap.containsKey(uniqueKey)) {
                systemKeyMatchingMap.put(uniqueKey, new List<Contact>());
            }
            // Add the contact record to the list associated with the system key value in the map
            systemKeyMatchingMap.get(uniqueKey).add(contactRecord);
        }

        return systemKeyMatchingMap;
    }
}
