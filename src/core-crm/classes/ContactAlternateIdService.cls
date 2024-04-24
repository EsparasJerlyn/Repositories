/**
 * @description  Service class for logic involving Contact Alternate IDs.
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 01, 2024        | DEPP-7986              | Created file                 |
 */
public inherited sharing class ContactAlternateIdService {

    // Map to store mapping between system key type and field API name
    public static Map<String,String> SYSTEM_KEY_FIELDS_ON_CONTACT = new Map<String,String>{
        'QUT Employee ID' => 'QUT_Employee_ID__c',
        'QUT Student ID' => 'QUT_Student_ID__c'
    };

    /**
     * @description Map of system key ID fields to its ID Type used for system key contact matching.
     *              Add additional fields here if needed.
     */
    public static Map<String,String> SYSTEM_KEY_TO_TYPE_MAP = new Map<String,String>{
        'qutEmployeeId' => 'QUT Employee ID',
        'qutStudentId' => 'QUT Student ID',
        'studyLinkApplicantId' => 'StudyLink Applicant ID',
        'qtacApplicantId'=> 'QTAC Applicant ID'
    };

    /**
     * Retrieves contact alternate IDs based on matching attributes.
     * @param matchingRecords A list of MatchingAttributes containing matching record attributes.
     * @return A list of Contact_Alternate_ID__c records matching the specified matching attributes.
     */
    public static List<Contact_Alternate_ID__c> retrieveContactAlternateIdsBySystemKeyId(
        List<ContactMatchingService.MatchingAttributes> matchingRecords
    ) {
        // Initialize a set to store unique alternate IDs
        Set<String> systemKeyIdsSet = new Set<String>();
        
        // Populate set with alternate IDs from matching records
        for (ContactMatchingService.MatchingAttributes matchingRecord : matchingRecords) {
            //this loops through all the system key fields of the matching attribute and gets its value
            //e.g qutEmployeeId
            for(String systemKeyField: SYSTEM_KEY_TO_TYPE_MAP.keySet()){
                String systemKeyFieldValue = matchingRecord.get(systemKeyField);
                if(String.isNotBlank(systemKeyFieldValue)){
                    systemKeyIdsSet.add(systemKeyFieldValue);
                }
            }
        }

        //return the contact alternate id records with the same system key ids
        return ContactAlternateIdsDAO.newInstance().getContactAlternateIdsBySystemKeyIdSet(systemKeyIdsSet,AccessLevel.SYSTEM_MODE);
    }

    /**
     * Retrieves Contact Alternate IDs grouped by Contact Id and System Key Type.
     * 
     * @param matchingResults A list of ContactMatchingService.MatchingResult objects containing matching results.
     * @return A Map where keys are concatenated strings of Contact Id and Alternate Id Type, and values are Contact_Alternate_ID__c objects.
     */
    public static Map<String, Contact_Alternate_ID__c> retrieveCAIGroupedByContactIdAndSystemKeyType(
        List<MatchingResult> matchingResults
    ) {
        // Initialize a map to store Contact Alternate IDs grouped by Contact Id and System Key Type
        Map<String, Contact_Alternate_ID__c> conSystemKeyCAIMap = new Map<String, Contact_Alternate_ID__c>();
        
        // Initialize a set to store unique Contact Ids
        Set<Id> contactIdSet = new Set<Id>();
        
        // Iterate through matching results to find non-system key matches and collect Contact Ids
        for (MatchingResult matchingResult : matchingResults) {
            boolean isContactNonSystemKeyMatch =    !matchingResult.error && 
                                                    matchingResult.matchingType != 'System Key Matching' &&
                                                    matchingResult.contactIds.size() == 1;
            if (isContactNonSystemKeyMatch) {
                contactIdSet.add(matchingResult.contactIds.iterator().next());
            }
        }

        // Get existing Contact Alternate IDs related to the collected Contact Ids
        List<Contact_Alternate_ID__c> existingConAltIds = ContactAlternateIdsDAO.newInstance().getContactAlternateIdsByContactIdSet(contactIdSet, AccessLevel.SYSTEM_MODE);
        
        // Group Contact Alternate IDs by Contact Id + System Key Type
        for (Contact_Alternate_ID__c contactAltId : existingConAltIds) {
            String uniqueKey = '' + contactAltId.Contact__c + contactAltId.Alternate_Id_Type__c;
            conSystemKeyCAIMap.put(uniqueKey, contactAltId);
        }

        // Return the map containing Contact Alternate IDs grouped by Contact Id and System Key Type
        return conSystemKeyCAIMap;
    }

    /**
     * Creates Contact Alternate ID records for matching records and returns the list of inserted records.
     * This method processes non-system key matches and generates Contact Alternate ID records accordingly.
     * 
     * @param matchingRecordsMap The map of matching records containing unique keys and corresponding attributes.
     * @param matchingResults The map of matching results containing the result of each record's matching process.
     * @return The list of inserted Contact Alternate ID records.
     */
    public static List<Contact_Alternate_ID__c> createCAIRecordsByMatchingResults(
        Map<String, ContactMatchingService.MatchingAttributes> matchingRecordsMap,
        Map<String, MatchingResult> matchingResults
    ){

        List<Contact_Alternate_ID__c> conAltListToInsert = new List<Contact_Alternate_ID__c>();

        // Collect matches that are not through system key matching
        for (String uniqueKey : matchingResults.keySet()) {
            MatchingResult matchingResult = matchingResults.get(uniqueKey);
            boolean isContactNonSystemKeyMatch =    matchingRecordsMap.containsKey(uniqueKey) && 
                                                    !matchingResult.error && 
                                                    matchingResult.matchingType != 'System Key Matching' &&
                                                    matchingResult.contactIds.size() == 1;
                                                    
            if(!isContactNonSystemKeyMatch){
                continue;
            }
            
            ContactMatchingService.MatchingAttributes matchingRecord = matchingRecordsMap.get(uniqueKey);

            // Iterate over system key fields and create Contact Alternate ID records
            for(String systemKeyField: SYSTEM_KEY_TO_TYPE_MAP.keySet()){
                if(matchingRecord.get(systemKeyField) != null && String.isNotBlank(matchingRecord.get(systemKeyField))){
                    conAltListToInsert.add(new Contact_Alternate_ID__c(
                        Contact_Alternate_Id__c = matchingRecord.get(systemKeyField),
                        Alternate_Id_Status__c = 'Active',
                        Alternate_Id_Type__c = SYSTEM_KEY_TO_TYPE_MAP.get(systemKeyField),
                        Start_Date__c = System.Today(),
                        Contact__c = matchingResult.contactIds.iterator().next()
                    ));

                }
            }
        }
        // Insert Contact Alternate ID records
        if(!conAltListToInsert.isEmpty()){
            ContactAlternateIdsDAO.newInstance().insertRecords(conAltListToInsert,false,AccessLevel.SYSTEM_MODE);
        }
        
        return conAltListToInsert;

    }

    /**
     * Updates Contact and Contact Alternate ID records based on inserted Contact Alternate ID records and existing Contact Alternate ID records.
     * This method processes the Contact Alternate ID records and updates existing records with new status and end date.
     * It also updates Contact records with QUT Employee ID and QUT Student ID.
     * 
     * @param insertedContactAlternateIds The list of inserted Contact Alternate ID records.
     * @param existingConAltIdsMap The map of existing Contact Alternate ID records.
     */
    public static void updateContactAndContactAlternateIds(
        List<Contact_Alternate_ID__c> insertedContactAlternateIds, 
        Map<String, Contact_Alternate_ID__c> existingConAltIdsMap
    ){
        List<Contact_Alternate_ID__c> conAltListToUpdate = new List<Contact_Alternate_ID__c>();
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();

        // Process inserted Contact Alternate ID records
        for(Contact_Alternate_ID__c conAltId: insertedContactAlternateIds){
            String conAltIdUniqueKey = conAltId.Contact__c + conAltId.Alternate_Id_Type__c;

            // Update existing Contact Alternate ID records with superseded status and end date
            if(existingConAltIdsMap.containsKey(conAltIdUniqueKey)){
                conAltListToUpdate.add(new Contact_Alternate_ID__c(
                    Id = existingConAltIdsMap.get(conAltIdUniqueKey).Id,
                    Succeeding_Id__c = conAltId.Id,
                    Alternate_Id_Status__c = 'Superseded',
                    End_Date__c = System.Today()
                ));
            }

            if(!SYSTEM_KEY_FIELDS_ON_CONTACT.containsKey(conAltId.Alternate_Id_Type__c)){
                continue;
            }
  
            // Create a new instance of contact
            if(!contactsToUpdateMap.containsKey(conAltId.Contact__c)){
                contactsToUpdateMap.put(conAltId.Contact__c, new Contact(Id = conAltId.Contact__c));
            }
            
            // Update Contact's QUT_Employee_ID__c or QUT_Student_ID__c
            contactsToUpdateMap.get(conAltId.Contact__c).put(
                SYSTEM_KEY_FIELDS_ON_CONTACT.get(conAltId.Alternate_Id_Type__c),
                conAltId.Contact_Alternate_ID__c
            );
        }

        // Update Contact Alternate ID records and Contact records
        if(!conAltListToUpdate.isEmpty()){
            ContactAlternateIdsDAO.newInstance().updateRecords(conAltListToUpdate,false,AccessLevel.SYSTEM_MODE);
        }
        
        if(!contactsToUpdateMap.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contactsToUpdateMap.values(),false,AccessLevel.SYSTEM_MODE);
        }
    }
}
