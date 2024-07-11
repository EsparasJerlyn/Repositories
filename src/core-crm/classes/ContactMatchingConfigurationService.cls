/**
 * @description Service class for noise removal logic.
 *              Removes specified characters from specific fields in contact records based on configuration.
 *              The noise removal configuration is stored in Contact Matching Configuration records.
 *              Only removes noise characters from string fields.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */
public inherited sharing class ContactMatchingConfigurationService {
    // Map to map field API names to their corresponding attributes in MatchingAttributes class
    private static final Map<String, String> FIELD_TO_REMOVE_NOISE_MAP = new Map<String, String>{
        'FirstName' => 'firstName',
        'LastName' => 'lastName',
        'BirthDate' => 'birthDate',
        'Email' => 'email',
        'Mobile Number' => 'mobilePhone'
    };

    private static final Set<String> ALPHABETIC_FIELDS = new Set<String>{ 'firstName', 'lastName' };

    /**
     * Processes noise removal for a list of matching records based on configured noise removal rules.
     *
     * @param matchingRecords - The list of matching records to process noise removal for.
     */
    public static void processNoiseRemoval(
        Map<String, ContactMatchingService.MatchingAttributes> matchingRecordsMap
    ) {
        // Query Contact Matching Configuration records with non-null Field_Name__c and Noise_String__c
        List<Contact_Matching_Configuration__c> contactMatchingConfigRecords = ContactMatchingConfigurationsDAO.newInstance()
            .getContactMatchingConfigurationRecords(AccessLevel.SYSTEM_MODE);

        String noiseString = '';
        String fieldName = '';

        // Iterate over each matching record
        for (
            ContactMatchingService.MatchingAttributes matchingRecord : matchingRecordsMap.values()
        ) {
            validateMobile(matchingRecord);
            //remove non alphabetical characters of field in ALPHABETICAL_FIELDS.
            removeNonAlphabeticalCharacters(matchingRecord);

            // Iterate over each Contact Matching Configuration record to apply noise removal rules
            for (
                Contact_Matching_Configuration__c contactMatchingConfig : contactMatchingConfigRecords
            ) {
                // Get the noise string from the configuration
                noiseString = contactMatchingConfig.Noise_String__c;

                if (FIELD_TO_REMOVE_NOISE_MAP.containsKey(contactMatchingConfig.Field_Name__c)) {
                    //Get the field to apply noise removal
                    fieldName = FIELD_TO_REMOVE_NOISE_MAP.get(contactMatchingConfig.Field_Name__c);
                    // Remove noise from the specified field
                    removeStringNoise(noiseString, fieldName, matchingRecord);
                }

                //Check if noise removal configuration is for all fields
                if (contactMatchingConfig.Field_Name__c == 'All') {
                    //loop through all the fields and apply noise removal
                    for (String field : FIELD_TO_REMOVE_NOISE_MAP.values()) {
                        removeStringNoise(noiseString, field, matchingRecord);
                    }
                }
            }
        }
    }

    /**
     * Removes noise characters from a specified field in a matching record.
     *
     * @param stringToRemove - The string representing the characters to remove.
     * @param fieldName - The API name of the field from which to remove noise.
     * @param matchingRecord - The matching record from which to remove noise.
     */
    private static void removeStringNoise(
        String stringToRemove,
        String fieldName,
        ContactMatchingService.MatchingAttributes matchingRecord
    ) {
        // the matching record is not null
        if (matchingRecord == null) {
            return;
        }

        // Retrieve the current value of the specified field
        String fieldValue = matchingRecord.get(fieldName);

        // Check if the field value is not null and contains the noise string to remove
        if (String.isNotBlank(fieldValue) && fieldValue.contains(stringToRemove)) {
            // Remove the noise string from the field value and update the field in the matching record
            matchingRecord.set(fieldName, fieldValue.remove(stringToRemove));
        }
    }

    /**
     * Removes non-alphabetical characters from the specified MatchingAttributes record.
     * If the record is null or any of the specified fields are blank, the method returns without making any changes.
     *
     * @param matchingRecord The MatchingAttributes record from which to remove non-alphabetical characters.
     */
    private static void removeNonAlphabeticalCharacters(
        ContactMatchingService.MatchingAttributes matchingRecord
    ) {
        // Check if the matching record is not null
        if (matchingRecord == null) {
            return;
        }

        // Regular expression pattern to match non-alphabetical characters
        String regexPattern = '[^a-zA-Z]';

        // Variables to store field value and cleaned string
        String fieldValue = '';
        String cleanString = '';

        // Loop through the fields that should only contain alphabetic characters
        for (String fieldName : ALPHABETIC_FIELDS) {
            fieldValue = matchingRecord.get(fieldName);
            if (String.isNotBlank(fieldValue)) {
                // Remove non-alphabetical characters from the field value
                cleanString = fieldValue.replaceAll(regexPattern, '');
                // Update the field value with the cleaned string
                matchingRecord.set(fieldName, cleanString);
            }
        }
    }

    /**
     * Validates the mobile phone number to ensure it meets the required criteria.
     * If the mobile number is provided and its length is not more than 6 characters,
     * it is considered invalid and will be reset to an empty string.
     *
     * @param matchingRecord The MatchingAttributes record from which to validate the mobilePhone.
     *
     */
    private static void validateMobile(ContactMatchingService.MatchingAttributes matchingRecord) {
        String mobile = matchingRecord.get('mobilePhone');
        if (String.isNotBlank(mobile) && mobile.length() < 7) {
            // If the mobile number is less than 7 characters, reset it to an empty string
            matchingRecord.set('mobilePhone', '');
        }
    }
}
