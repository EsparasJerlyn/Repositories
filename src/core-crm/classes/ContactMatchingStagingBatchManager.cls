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
            ContactMatchingStagingsDAO.newInstance()
                .updateRecords(conMatchingStagings, false, AccessLevel.USER_MODE);
        }
    }

    /**
     * Processes the matching results and updates or inserts contact records accordingly.
     * This method evaluates the matching results for each Contact Matching Staging record,
     * updates existing contact records, inserts new contact records, and upserts addresses.
     *
     * @param conMatchingStagings List of Contact Matching Staging records.
     * @param matchingResults Map containing matching result keys mapped to MatchingResult objects.
     * @param contactMatchingToMatchingResultKey Map mapping staging record IDs to matching result keys.
     */
    private static void processMatchingResult(
        List<Contact_Matching_Staging__c> conMatchingStagings,
        Map<String, MatchingResult> matchingResults,
        Map<Id, String> contactMatchingToMatchingResultKey
    ) {
        // Maps to store contacts to update, insert, and addresses to upsert
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Contact> contactsToInsert = new Map<Id, Contact>();
        Map<String, hed__Address__c> addressToUpsert = new Map<String, hed__Address__c>();
        Id contactIdMatch;
        MatchingResult result;
        Contact newContact;

        // Iterate through each Contact Matching Staging record
        for (Contact_Matching_Staging__c conMatchingStage : conMatchingStagings) {
            // Get the matching result key for the staging record
            String stagingUniqueKey = contactMatchingToMatchingResultKey.get(conMatchingStage.Id);
            // Get the matching result for the key
            result = matchingResults.get(stagingUniqueKey);

            // Check matching types and errors
            boolean isSystemKeyMatch =
                !result.error && result.matchingType == 'System Key Matching';
            boolean isNonSystemKeyMatch = !result.error && String.isNotBlank(result.matchingType);
            boolean isError = result.error && String.isNotBlank(result.errorMessage);

            if (isSystemKeyMatch) {
                // Handle system key match
                contactIdMatch = result.contactIds.iterator().next();
                contactsToUpdate.put(
                    contactIdMatch,
                    ContactMatchingStagingService.buildContactRecord(
                        false,
                        contactIdMatch,
                        conMatchingStage
                    )
                );
                conMatchingStage.Contact__c = contactIdMatch;
                ContactMatchingStagingService.buildAddressMapping(
                    false,
                    addressToUpsert,
                    conMatchingStage
                );
            } else if (isNonSystemKeyMatch) {
                // Handle non-system key match
                contactIdMatch = result.contactIds.iterator().next();
                contactsToUpdate.put(
                    contactIdMatch,
                    ContactMatchingStagingService.buildContactRecord(
                        true,
                        contactIdMatch,
                        conMatchingStage
                    )
                );
                conMatchingStage.Contact__c = contactIdMatch;
                ContactMatchingStagingService.buildAddressMapping(
                    true,
                    addressToUpsert,
                    conMatchingStage
                );
            } else if (isError) {
                // Log error message
                Logger.error(JSON.serializePretty(result), conMatchingStage.Id);
            } else {
                // Insert new contact record
                newContact = ContactMatchingStagingService.buildContactRecord(
                    false,
                    null,
                    conMatchingStage
                );
                contactsToInsert.put(conMatchingStage.Id, newContact);
                ContactMatchingStagingService.buildAddressMapping(
                    false,
                    addressToUpsert,
                    conMatchingStage
                );
            }
        }

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

        // link the contact to address and staging
        ContactMatchingStagingService.linkContactAddressAndStagingRecords(
            contactsToInsert,
            conMatchingStagings,
            addressToUpsert
        );
    }
}