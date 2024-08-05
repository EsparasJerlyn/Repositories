/**
 * Manages the processing of Contact Matching Staging records and construction of Contact and Address records.
 * This class provides methods to build Contact and Address records based on Contact Matching Staging data,
 * map addresses to corresponding contacts, and link contact, address, and staging records.
 *
 * @author Accenture
 * @history
 *    | Developer                 | Date        | JIRA     | Change Summary             |
 *    |---------------------------|-------------|----------|----------------------------|
 *    | roy.nino.s.regala         | May 01, 2024| DEPP-8676| Created File               |
 */
public inherited sharing class ContactMatchingStagingService {
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
        'MiddleName__c' => 'MiddleName',
        'Mobile_No_Locale__c' => 'Mobile_No_Locale__c',
        'MobilePhone__c' => 'MobilePhone',
        'Phone__c' => 'Phone',
        'Preferred_Given_Name__c' => 'Preferred_Given_Name__c',
        'QUT_Employee_ID__c' => 'QUT_Employee_ID__c',
        'QUT_Identity_ID__c' => 'QUT_Identity_ID__c',
        'Work_Email__c' => 'Work_Email__c',
        'QUT_Learner_Email__c' => 'QUT_Learner_Email__c',
        'QUT_Staff_Email__c' => 'QUT_Staff_Email__c',
        'QUT_Staff_Username__c' => 'QUT_Staff_Username__c',
        'QUT_Student_ID__c' => 'QUT_Student_ID__c',
        'QUT_Student_Username__c' => 'QUT_Student_Username__c',
        'Salutation__c' => 'Salutation',
        'Staff_End_Date__c' => 'Staff_End_Date__c',
        'External_Id__c' => 'External_Id__c',
        'External_Key__c' => 'External_Key__c',
        'Migration_Id__c' => 'Migration_Id__c',
        'Migration_Key__c' => 'Migration_Key__c'
    };

    private static final Map<String, String> MAILING_TO_CONTACT_MAP = new Map<String, String>{
        'Mailing_City__c' => 'hed__MailingCity__c',
        'Mailing_Country__c' => 'hed__MailingCountry__c',
        'Mailing_State__c' => 'hed__MailingState__c',
        'Mailing_Street__c' => 'hed__MailingStreet__c',
        'Mailing_PostalCode__c' => 'hed__MailingPostalCode__c'
    };

    private static final Map<String, String> OTHER_TO_CONTACT_MAP = new Map<String, String>{
        'Residential_City__c' => 'hed__MailingCity__c',
        'Residential_Country__c' => 'hed__MailingCountry__c',
        'Residential_State__c' => 'hed__MailingState__c',
        'Residential_Street__c' => 'hed__MailingStreet__c',
        'Residential_PostalCode__c' => 'hed__MailingPostalCode__c'
    };

    private static final Map<String, Map<String, String>> ADDRESS_TYPE_MAP = new Map<String, Map<String, String>>{
        'Mailing' => MAILING_TO_CONTACT_MAP,
        'Other' => OTHER_TO_CONTACT_MAP
    };

    private static final Set<String> FIELDS_TO_NULLIFY = new Set<String>{
        'FirstName__c'
    };

    /**
     * Constructs a new Contact record based on the data provided from a Contact Matching Staging record.
     * @param isNonSystemKey Boolean indicating whether null values are copied to Contact
     * @param contactId The ID of an existing contact record if matched, or null otherwise.
     * @param conMatchingStage The Contact Matching Staging record from which to extract data.
     * @return A Contact record populated with data from the Contact Matching Staging record.
     */
    public static Contact buildContactRecord(
        Boolean isNonSystemKey,
        Id contactId,
        Contact_Matching_Staging__c conMatchingStage
    ) {
        // Initialize a new Contact object
        Contact con = new Contact();

        // Set the Contact's ID field if a contactId is provided
        con.put('Id', contactId);
        con.put('RecordTypeId', ContactsDAO.PERSON_RECORDTYPE_ID);

        // Iterate through each field in the FIELDS_TO_CONTACT_MAP
        for (String conMatchingStagingField : FIELDS_TO_CONTACT_MAP.keySet()) {
            // Retrieve the corresponding Contact field name from the map
            String contactField = FIELDS_TO_CONTACT_MAP.get(conMatchingStagingField);

            // current match is system key 
            // field is not null or field belonging to fields that can be nullified
            boolean isSystemKeyMapping =
                !isNonSystemKey &&
                (conMatchingStage.get(conMatchingStagingField) != null ||
                FIELDS_TO_NULLIFY.contains(conMatchingStagingField));
            //current match is non system key and field is not null
            boolean isNonSystemKeyMapping =
                isNonSystemKey && conMatchingStage.get(conMatchingStagingField) != null;
            //update contact if above conditions are satisfied
            boolean isUpdateContact = isSystemKeyMapping || isNonSystemKeyMapping;

            if (isUpdateContact) {
                // Set the field in the Contact object using the retrieved field name and value from the Contact Matching Staging record
                con.put(contactField, conMatchingStage.get(conMatchingStagingField));
            }
        }

        // Return the constructed Contact object
        return con;
    }

    /**
     * Builds a mapping of addresses
     *
     * @param isNonSystemKey Boolean indicating whether null values are copied
     * @param addressToUpsert A map to store addresses to upsert.
     * @param conMatchingStage The Contact Matching Staging record.
     */
    public static void buildAddressMapping(
        boolean isNonSystemKey,
        Map<String, hed__Address__c> addressToUpsert,
        Contact_Matching_Staging__c conMatchingStage
    ) {
        for (String addressType : ADDRESS_TYPE_MAP.keySet()) {
            hed__Address__c address = buildAddressRecord(
                isNonSystemKey,
                addressType,
                conMatchingStage
            );
            if (String.isNotBlank(address.hed__Address_Type__c)) {
                addressToUpsert.put(conMatchingStage.Id + addressType, address);
            }
        }
    }

    /**
     * Constructs a new Address record based on the data provided from a Contact Matching Staging record.
     *
     * @param isNonSystemKey Boolean indicating whether null values are copied to hed__Address__c
     * @param addressType The type of address ('Mailing' or 'Other').
     * @param conMatchingStage The Contact Matching Staging record containing data for the address construction.
     * @return A new Address record populated with data from the Contact Matching Staging record.
     */
    public static hed__Address__c buildAddressRecord(
        Boolean isNonSystemKey,
        String addressType,
        Contact_Matching_Staging__c conMatchingStage
    ) {
        // Initialize a new Address object
        hed__Address__c address = new hed__Address__c();

        // Retrieve the address field mapping based on the address type
        Map<String, String> addressMapping = ADDRESS_TYPE_MAP.get(addressType);

        // Iterate through each field mapping and set the corresponding field in the Address object
        for (String conMatchingStagingField : addressMapping.keySet()) {
            String addressField = addressMapping.get(conMatchingStagingField);

            // current match is system key 
            // field is not null or field belonging to fields that can be nullified
            boolean isSystemKeyMapping =
                !isNonSystemKey &&
                (conMatchingStage.get(conMatchingStagingField) != null ||
                FIELDS_TO_NULLIFY.contains(conMatchingStagingField));
            //current match is non system key and field is not null
            boolean isNonSystemKeyMapping =
                isNonSystemKey && conMatchingStage.get(conMatchingStagingField) != null;
            //update contact if above conditions are satisfied
            boolean isUpdateContact = isSystemKeyMapping || isNonSystemKeyMapping;

            if (isUpdateContact) {
                // Set the address type
                address.put('hed__Address_Type__c', addressType);
                // Set the field in the Address object using the retrieved field name and value from the Contact Matching Staging record
                address.put(addressField, conMatchingStage.get(conMatchingStagingField));
            }
        }

        // Return the constructed Address object
        return address;
    }

    /**
     * Links contact records, address records, and Contact Matching Staging records.
     *
     * @param contactsToInsert A map containing contact records to insert.
     * @param conMatchingStagings List of Contact Matching Staging records.
     * @param addressToUpsert A map containing addresses to upsert.
     */
    public static void linkContactAddressAndStagingRecords(
        Map<Id, Contact> contactsToInsert,
        List<Contact_Matching_Staging__c> conMatchingStagings,
        Map<String, hed__Address__c> addressToUpsert
    ) {
        Map<Id, Id> conIdToStaging = new Map<Id, Id>();

        for (Contact_Matching_Staging__c conMatchingStage : conMatchingStagings) {
            if (conMatchingStage.Contact__c != null) {
                conIdToStaging.put(conMatchingStage.Contact__c, conMatchingStage.Id);
            }

            if (contactsToInsert.containsKey(conMatchingStage.Id)) {
                conMatchingStage.Contact__c = contactsToInsert.get(conMatchingStage.Id).Id;
            }

            mapAddressToContact(conMatchingStage, addressToUpsert);
        }

        for (
            hed__Address__c address : AddressesDAO.newInstance()
                .getAddressesByContactIdsSet(conIdToStaging.keySet(), AccessLevel.USER_MODE)
        ) {
            String uniqueKey =
                conIdToStaging.get(address.hed__Parent_Contact__c) + address.hed__Address_Type__c;
            if (addressToUpsert.containsKey(uniqueKey)) {
                addressToUpsert.get(uniqueKey).put('Id', address.Id);
            }
        }

        // Upsert the addresses
        if (!addressToUpsert.isEmpty()) {
            AddressesDAO.newInstance()
                .upsertRecords(addressToUpsert.values(), false, AccessLevel.USER_MODE);
        }
    }

    /**
     * Maps address records to corresponding contact records.
     *
     * @param conMatchingStaging The Contact Matching Staging record.
     * @param addressToUpsert A map containing addresses to upsert.
     */
    private static void mapAddressToContact(
        Contact_Matching_Staging__c conMatchingStaging,
        Map<String, hed__Address__c> addressToUpsert
    ) {
        for (String addressType : ADDRESS_TYPE_MAP.keySet()) {
            String uniqueKey = conMatchingStaging.Id + addressType;
            // Set the parent contact IDs for the addresses
            if (conMatchingStaging.Contact__c != null && addressToUpsert.containsKey(uniqueKey)) {
                addressToUpsert.get(uniqueKey)
                    .put('hed__Parent_Contact__c', conMatchingStaging.Contact__c);
                continue;
            }

            addressToUpsert.remove(conMatchingStaging.Id + addressType);
        }
    }
}
