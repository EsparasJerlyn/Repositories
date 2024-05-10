/**
 * Manages the processing of Contact Matching Staging records in batch mode.
 * This class handles the logic for processing contact matching staging records
 * and updating contact records based on the matching results.
 *
 * @author Accenture
 * @history
 *    | Developer                 | Date        | JIRA     | Change Summary             |
 *    |---------------------------|-------------|----------|----------------------------|
 *    | roy.nino.s.regala         | May 01, 2024| DEPP-8676| Created File               |
 */
public inherited sharing class ContactMatchingStagingBatchManager {
    // Map of fields in Contact Matching Staging records to corresponding Contact fields
    private static final Map<String, String> FIELDS_TO_CONTACT_MAP = new Map<String, String>{
        'Birthdate__c' => 'Birthdate',
        'Citizenship_Status__c' => 'hed__Citizenship_Status__c',
        'Date_Deceased__c' => 'hed__Date_Deceased__c',
        'Deceased__c' => 'hed__Deceased__c',
        'Email__c' => 'Email',
        'FirstName__c' => 'FirstName',
        'Indigenous_Status__c' => 'ATSI_Code__c',
        'LastName__c' => 'LastName',
        'Mailing_City__c' => 'MailingCity',
        'Mailing_Country__c' => 'MailingCountry',
        'Mailing_State__c' => 'MailingState',
        'Mailing_Street__c' => 'MailingStreet',
        'Mailing_PostalCode__c' => 'MailingPostalCode',
        'MiddleName__c' => 'MiddleName',
        'Mobile_No_Locale__c' => 'Mobile_No_Locale__c',
        'MobilePhone__c' => 'MobilePhone',
        'Preferred_Given_Name__c' => 'Preferred_Given_Name__c',
        'QUT_Employee_ID__c' => 'QUT_Employee_ID__c',
        'QUT_Identity_ID__c' => 'QUT_Identity_ID__c',
        'Work_Email__c' => 'Work_Email__c',
        'QUT_Learner_Email__c' => 'QUT_Learner_Email__c',
        'QUT_Staff_Email__c' => 'QUT_Staff_Email__c',
        'QUT_Staff_Username__c' => 'QUT_Staff_Username__c',
        'QUT_Student_ID__c' => 'QUT_Student_ID__c',
        'QUT_Student_Username__c' => 'QUT_Student_Username__c',
        'Residential_City__c' => 'OtherCity',
        'Residential_Country__c' => 'OtherCountry',
        'Residential_State__c' => 'OtherState',
        'Residential_Street__c' => 'OtherStreet',
        'Residential_PostalCode__c' => 'OtherPostalCode',
        'Salutation__c' => 'Salutation',
        'Staff_End_Date__c' => 'Staff_End_Date__c',
        'External_Id__c' => 'External_Id__c',
        'External_Key__c' => 'External_Key__c',
        'Migration_Id__c' => 'Migration_Id__c',
        'Migration_Key__c' => 'Migration_Key__c'
    };

    /**
     * Processes the Contact Matching Staging records.
     * This method evaluates the contact matching staging records, performs contact matching,
     * and updates or inserts contact records based on the matching results.
     *
     * @param conMatchingStagings List of Contact Matching Staging records to process.
     */
    public static void processContactMatching(
        List<Contact_Matching_Staging__c> conMatchingStagings
    ) {
        // Initialize maps and lists to store data during processing
        Map<Id, String> contactMatchingToMatchingResultKey = new Map<Id, String>();
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        String uniqueKey = '';
        // Loop through the contact matching staging records
        for (Contact_Matching_Staging__c conMatchingStaging : conMatchingStagings) {
            // Mark the record as processed
            conMatchingStaging.Batch_Process__c = 'Processed';
            // Create a matching record from the staging record's data
            ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(
                new Map<String, String>{
                    'firstName' => conMatchingStaging.FirstName__c,
                    'lastName' => conMatchingStaging.LastName__c,
                    'birthDate' => conMatchingStaging.Birthdate__c != null
                        ? String.valueOf(conMatchingStaging.Birthdate__c)
                        : '',
                    'mobilePhone' => conMatchingStaging.MobilePhone__c,
                    'email' => conMatchingStaging.Email__c,
                    'qutStudentId' => conMatchingStaging.QUT_Student_ID__c,
                    'qutEmployeeId' => conMatchingStaging.QUT_Employee_ID__c
                }
            );
            // Add the matching record to the list
            matchingRecords.add(matchingRecord);
            // Generate a unique key for the matching result
            uniqueKey = ContactMatchingService.generateUniqueKey(
                matchingRecord,
                new List<String>(matchingRecord.fieldValues.keySet())
            );
            // Map the staging record ID to the matching result key
            contactMatchingToMatchingResultKey.put(conMatchingStaging.Id, uniqueKey);
        }

        try {
            // Process the contact matching
            Map<String, MatchingResult> matchingResults = ContactMatchingService.processContactMatching(
                matchingRecords
            );
            // Process the matching results
            processMatchingResult(
                conMatchingStagings,
                matchingResults,
                contactMatchingToMatchingResultKey
            );
        } catch (Exception e) {
            // Log any exceptions encountered during the process
            Logger.error(
                    'Exception caught in method execute in class ContactMatchingStagingBatchManager method processContactMatching.'
                )
                .setExceptionDetails(e);
        } finally {
            // Update staging records and save log if necessary
            if (!conMatchingStagings.isEmpty()) {
                ContactMatchingStagingsDAO.newInstance()
                    .updateRecords(conMatchingStagings, false, AccessLevel.USER_MODE);
            }
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * Processes the matching results and updates or inserts contact records accordingly.
     *
     * @param conMatchingStagings List of Contact Matching Staging records.
     * @param matchingResults Map of matching result keys to MatchingResult objects.
     * @param contactMatchingToMatchingResultKey Map of staging record IDs to matching result keys.
     */
    private static void processMatchingResult(
        List<Contact_Matching_Staging__c> conMatchingStagings,
        Map<String, MatchingResult> matchingResults,
        Map<Id, String> contactMatchingToMatchingResultKey
    ) {
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Contact> contactsToInsert = new Map<Id, Contact>();
        Id contactIdMatch;
        MatchingResult result;
        Contact newContact;
        for (Contact_Matching_Staging__c conMatchingStage : conMatchingStagings) {
            // Get the matching result key for the staging record
            String stagingUniqueKey = contactMatchingToMatchingResultKey.get(conMatchingStage.Id);
            // Get the matching result for the key
            result = matchingResults.get(stagingUniqueKey);

            boolean isSystemKeyMatch =
                !result.error && result.matchingType == 'System Key Matching';
            boolean isNonSystemKeyMatch = !result.error && String.isNotBlank(result.matchingType);
            boolean isError = result.error && String.isNotBlank(result.errorMessage);

            if (isSystemKeyMatch) {
                // Handle system key match
                contactIdMatch = result.contactIds.iterator().next();
                contactsToUpdate.put(
                    contactIdMatch,
                    buildContactRecords(false, contactIdMatch, conMatchingStage)
                );
                conMatchingStage.Contact__c = contactIdMatch;
            } else if (isNonSystemKeyMatch) {
                // Handle non-system key match
                contactIdMatch = result.contactIds.iterator().next();
                contactsToUpdate.put(
                    contactIdMatch,
                    buildContactRecords(true, contactIdMatch, conMatchingStage)
                );
                conMatchingStage.Contact__c = contactIdMatch;
            } else if (isError) {
                // Log error message
                Logger.error(JSON.serializePretty(result), conMatchingStage.Id);
            } else {
                // Insert new contact record
                newContact = buildContactRecords(false, null, conMatchingStage);
                contactsToInsert.put(conMatchingStage.Id, newContact);
            }
        }

        performDml(contactsToUpdate, contactsToInsert);

        linkNewContact(contactsToInsert, conMatchingStagings);
    }

    /**
     * Performs DML operations to update existing contact records and insert new contact records.
     *
     * @param contactsToUpdate Map<Id,Contact> The list of contact records to update.
     * @param contactsToInsert Nap<Id,Contact> The list of contact records to insert.
     */
    private static void performDml(Map<Id,Contact> contactsToUpdate, Map<Id,Contact> contactsToInsert) {
        // Update existing contact records
        if (!contactsToUpdate.isEmpty()) {
            ContactsDAO.newInstance()
                .updateRecords(
                    new List<Contact>(contactsToUpdate.values()),
                    false,
                    AccessLevel.USER_MODE
                );
        }

        // Insert new contact records
        if (!contactsToInsert.isEmpty()) {
            ContactsDAO.newInstance()
                .insertRecords(
                    new List<Contact>(contactsToInsert.values()),
                    false,
                    AccessLevel.USER_MODE
                );
        }
    }

    /**
     * Links new contact records with their corresponding Contact Matching Staging records.
     *
     * @param contactsToInsert Map<Id, Contact> A map containing the Ids of new contact records
     *                         to be inserted as keys and the corresponding Contact records as values.
     * @param conMatchingStagings List<Contact_Matching_Staging__c> The list of Contact Matching Staging
     *                            records to link with new contact records.
     */
    private static void linkNewContact(
        Map<Id, Contact> contactsToInsert,
        List<Contact_Matching_Staging__c> conMatchingStagings
    ) {
        for (Contact_Matching_Staging__c conMatchingStage : conMatchingStagings) {
            if (contactsToInsert.containsKey(conMatchingStage.Id)) {
                // Set the Contact__c field of Contact Matching Staging record to the Id of the corresponding new contact record
                conMatchingStage.Contact__c = contactsToInsert.get(conMatchingStage.Id).Id;
            }
        }
    }

    /**
     * Constructs a new Contact record based on the data provided from a Contact Matching Staging record.
     * @param isNonSystemKeyMatch Boolean value indicating whether the match is a non-system key match.
     * @param contactId The ID of an existing contact record if matched, or null otherwise.
     * @param conMatchingStage The Contact Matching Staging record from which to extract data.
     * @return A Contact record populated with data from the Contact Matching Staging record.
     */
    private static Contact buildContactRecords(
        Boolean isNonSystemKeyMatch,
        Id contactId,
        Contact_Matching_Staging__c conMatchingStage
    ) {
        // Initialize a new Contact object
        Contact con = new Contact();

        // Set the Contact's ID field if a contactId is provided
        con.put('Id', contactId);

        // Iterate through each field in the FIELDS_TO_CONTACT_MAP
        for (String conMatchingStagingField : FIELDS_TO_CONTACT_MAP.keySet()) {
            // Retrieve the corresponding Contact field name from the map
            String contactField = FIELDS_TO_CONTACT_MAP.get(conMatchingStagingField);

            // Check if the match is a non-system key match and the value from the Contact Matching Staging record is null
            if (isNonSystemKeyMatch && conMatchingStage.get(conMatchingStagingField) == null) {
                // Skip setting the field in the Contact object if it's a non-system key match and the value is null
                continue;
            }

            // Set the field in the Contact object using the retrieved field name and value from the Contact Matching Staging record
            con.put(contactField, conMatchingStage.get(conMatchingStagingField));
        }

        // Return the constructed Contact object
        return con;
    }
}
