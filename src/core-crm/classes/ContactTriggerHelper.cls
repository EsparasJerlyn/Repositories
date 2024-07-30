/**
 * @description helper for ContactTriggerHandler
 * @see ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | roy.nino.s.regala              | June 09, 2022         | DEPP-2869              | Created file, converted flow                     |
      | roy.nino.s.regala              | Sep 10, 2022          | DEPP-4225              | updated to reparet contact and update work email | 
      | john.m.tambasen                | September 23, 2022    | DEPP-4367              | birthdate validation                             |
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Added new method to set Person Contact flag      |
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added new method to set Can Nurture flag         |
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added new method to create Marketing Segmentation|
      | mark.j.mahilum                 | Sept 22, 2023         | DEPP-6488              | Updated getContactCalculatedCadence to includes  |
      |                                |                       |                        | the automated cadences in the processSaleCadences|
      | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Updated getContactCalculatedCadence to include   |
      |                                |                       |                        |     updateCompletedCadences                      |
      | julie.jane.alegre              | Oct 27, 2023          | DEPP-6955              | Added new method updateRegisteredEmail           |
      | roy.nino.s.regala              | Nov 01, 2023          | DEPP-7105              | updated createMarketingSegmentation to future    |
      | roy.nino.s.regala              | Dec 02, 2023          | DEPP-6979              | updated contact parent child syncing flow to trigger      |
      | sebastianne.k.trias            | Dec 21, 2023          | DEPP-7182              | Add method updateSyncToMCField method from       |
      |                                |                       |                        | ContactSyncFlow                                  |
      | roy.nino.s.regala              | Feb 23, 2023          | DEPP-7738              | Updated creation of segmentation to sync         |
      | mark.j.mahilum                 | Feb 29, 2024          | DEPP-7739              | Added method to Fixed issue with Lead to Contact |
      |                                |                       |                        | conversion mapping                               |
      | mark.j.mahilum                 | March 15, 2024        | DEPP-8314              | Updated can nurture logic for partner sourced    |
      | roy.nino.s.regala              | Jun 05, 2024          | DEPP-9171              | Added contact matching logic on contact udpate   |
 */
public without sharing class ContactTriggerHelper {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business_Organization')
        .getRecordTypeId();

    /**
     * @description do fast updates and validation for contact(used in Before triggers)
     *
     * @param newItems  List of new Contact records
     * @param oldItems  Map of old Contact records
     */
    public static void fastFieldUpdateAndValidation(
        List<Contact> newItems,
        Map<Id, Contact> oldItems
    ) {
        List<Contact> contactsToRecalculate = new List<Contact>();

        for (Contact con : newItems) {
            Boolean isPerson = ContactsDAO.PERSON_RECORDTYPE_ID == con.RecordTypeId;
            //non person/person contact process start

            //validates contact birthdate
            birthDateValidation(con);
            //remove special characters from the first and last name field
            setMatchingFirstAndLastName(con, oldItems);

            //person contacts processes start
            if (!isPerson) {
                continue;
            }

            //This method check if redundant email value is duplicated in the other contact email fields.
            checkIfEmailIsAlreadyMatchOnContactLeadConversion(con, oldItems);
            //sets can nurture flag
            setCanNurtureFlag(con, contactsToRecalculate, oldItems);
            //sets QUT_Staff__c(Persona Flags) of Contact
            setQUTPersonaFlag(con);
            //updates Registered email when match with Primary Email or Work Email
            updateRegisteredEmail(con, oldItems);
            //updates sync to mc field
            updateSyncToMCField(con, oldItems);
            //updates fields dependent to Can_Nurture__c
            updateCanNurtureDependentFields(con, oldItems);

            //if contact is person on insert/update Persona Type is Personal
            con.Persona_Type__c = 'Personal';
        }

        //processes with soql and dml start
        //recalculate Can Nurture by threshold
        recalculateCanNurture(contactsToRecalculate);
    }

    /**
     * @description set the administrative account as parent account
     * @param conNew - List of Contact.Trigger.new
     */
    public static void reparentAccount(List<Contact> newItems) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> businessAccounts = new Map<Id, Account>();

        //get account ids
        for (Contact con : newItems) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
        //get account records recordtype
        if (!accountIds.isEmpty()) {
            businessAccounts = new Map<Id, Account>(
                [
                    SELECT Id
                    FROM Account
                    WHERE Id IN :accountIds AND RecordTypeId = :BUSINESS_ACC_RECTYPEID
                ]
            );
        }

        for (Contact con : newItems) {
            //set business org to primary org if RT is business_organization
            if (businessAccounts.containsKey(con.AccountId)) {
                con.hed__Primary_Organization__c = con.AccountId;
                con.AccountId = null;
            }
        }
    }

    /**
     * @description map marketing fields from MC Persona to Parent Lead/Contact
     * or Parent Contact to Chilc MC Persona
     *
     * @param newItems  List of new Contact records
     * @param oldItems  Map of old Contact records
     */
    public static void mapMarketingFields(List<Contact> newItems, Map<Id, Contact> oldItems) {
        //contact records to upsert
        List<Contact> contactsToUpsert = new List<Contact>();
        //map of person contacts to update - used a map to ensure uniqueness
        Map<Id, Contact> personContactsToUpdate = new Map<Id, Contact>();
        //lead records to update - used a map to ensure uniqueness
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
        //exsiting child mc persona contacts
        List<Contact> existingChildMCContacts = new List<Contact>();
        //person contact ids
        Set<Id> personContactIds = new Set<Id>();

        //child MC contacts grouped by Parent Contact + Persona Type
        //key (Persona Id)-> 003xxxxxxQUT Learner
        //value -> MC Contact Record
        Map<String, Contact> childMCToParentMap = new Map<String, Contact>();

        //collect person contact ids
        for (Contact con : newItems) {
            if (con.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID) {
                personContactIds.add(con.Id);
            }
        }
        boolean personContactsUpdated = !personContactIds.isEmpty() && oldItems != null;
        //get exsiting MC child personas if there are person contacts updated
        if (personContactsUpdated) {
            existingChildMCContacts = ContactsDAO.newInstance()
                .getMCPersonaContactsByParentPersonContactIds(
                    personContactIds,
                    AccessLevel.SYSTEM_MODE
                );
        }

        //group parent contacts by child MC Persona
        //this tells us if a Person contact has a work/staff/learner child mc persona
        for (Contact mcContact : existingChildMCContacts) {
            //checks if persona type is work,qut staff, or qut learner
            boolean isValidPersonaType =
                MarketingService.PERSONA_TYPES_TO_EMAIL_MAP.keySet()
                    .contains(mcContact.Persona_Type__c) &&
                mcContact.Parent_Person_Contact__c != null;

            //group parent contact by persona type
            if (isValidPersonaType) {
                childMCToParentMap.put(
                    mcContact.Parent_Person_Contact__c + mcContact.Persona_Type__c,
                    mcContact
                );
            }
        }

        //loop through the contacts triggered
        for (Contact con : newItems) {
            //collect MC Persona records to be inserted or updated
            contactsToUpsert.addAll(
                mapMarketingFieldsToChildMCContact(con, oldItems, childMCToParentMap)
            );
            //collect Parent Person records to be updated
            mapMarketingFieldsToParentPersonContact(con, oldItems, personContactsToUpdate);
            //collect Parent Lead records to be updated
            mapMarketingFieldsToParentLead(con, oldItems, leadsToUpdate);
        }

        contactsToUpsert.addAll(personContactsToUpdate.values());

        if (!contactsToUpsert.isEmpty()) {
            ContactsDAO.newInstance()
                .upsertRecords(contactsToUpsert, false, AccessLevel.SYSTEM_MODE);
        }

        if (!leadsToUpdate.isEmpty()) {
            LeadsDAO.newInstance()
                .updateRecords(leadsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description map marketing fields from MC Persona to Parent Lead
     * when marketing fields are updated
     *
     * @param con  Contact record
     * @param oldItems  Map of old Contact records
     * @param leadsToUpdate parent lead records to be updated
     */
    private static void mapMarketingFieldsToParentLead(
        Contact con,
        Map<Id, Contact> oldItems,
        Map<Id, Lead> leadsToUpdate
    ) {
        boolean isUpdate = oldItems != null;
        Lead tempLead;

        //make sure MC Persona with persona type work is updated
        //make sure specific marketing fields are updated see MarketingService static variables
        boolean isMCWorkPersonaUpdated =
            con.Parent_Person_Lead__c != null &&
            con.Persona_Type__c == 'Work' &&
            con.RecordTypeId == ContactsDAO.MC_PERSONA_RECORDTYPE_ID &&
            isUpdate &&
            isMarketingFieldsUpdated(
                MarketingService.PERSONAL_MARKETING_FIELDS,
                con,
                oldItems.get(con.Id)
            );

        //construct the lead record to be updated
        if (isMCWorkPersonaUpdated) {
            tempLead = new Lead(
                Id = con.Parent_Person_Lead__c,
                Work_Email__c = con.Email,
                Work_Email_Opt_Out__c = con.HasOptedOutOfEmail,
                Work_Email_Opt_Out_DateTime__c = con.Email_Opt_Out_DateTime__c,
                Work_Email_Opt_In_DateTime__c = con.Email_Opt_In_DateTime__c
            );
            leadsToUpdate.put(con.Parent_Person_Lead__c, tempLead);
        }
    }

    /**
     * @description map marketing fields from MC Persona to Parent Contact
     * when marketing fields are updated
     *
     * @param con  Contact record
     * @param oldItems  Map of old Contact records
     * @param personContactsToUpdate parent contact records to be updated
     */
    private static void mapMarketingFieldsToParentPersonContact(
        Contact con,
        Map<Id, Contact> oldItems,
        Map<Id, Contact> personContactsToUpdate
    ) {
        boolean isUpdate = oldItems != null;
        //make sure MC Persona is updated
        //make sure specific marketing fields are updated see MarketingService static variables
        //make sure Persona Type is valid
        boolean isMCPersonaUpdated =
            isUpdate &&
            con.Parent_Person_Contact__c != null &&
            con.RecordTypeId == ContactsDAO.MC_PERSONA_RECORDTYPE_ID &&
            isMarketingFieldsUpdated(
                MarketingService.PERSONAL_MARKETING_FIELDS,
                con,
                oldItems.get(con.Id)
            ) &&
            MarketingService.PERSONA_TYPE_TO_MARKETING_FIELDS.containsKey(con.Persona_Type__c);
        //do not proceed if above is not satisfied
        if (!isMCPersonaUpdated) {
            return;
        }

        //if person contact already exists in the contact map to update
        //only add additional field updates to the contact record and not overwrite it
        //this scenario happens when 2 or more MC child with the same Parent Person Contact is updated
        if (!personContactsToUpdate.containsKey(con.Parent_Person_Contact__c)) {
            personContactsToUpdate.put(con.Parent_Person_Contact__c, new Contact());
        }

        //set the contact record id
        personContactsToUpdate.get(con.Parent_Person_Contact__c)
            .put('Id', con.Parent_Person_Contact__c);

        //only map the updated field
        for (String field : MarketingService.PERSONAL_MARKETING_FIELDS) {
            if (con.get(field) != oldItems.get(con.Id).get(field)) {
                //get the marketing field mapping using the current persona type
                //see MarketingService static variables
                Map<String, String> marketingFieldMap = MarketingService.PERSONA_TYPE_TO_MARKETING_FIELDS.get(
                    con.Persona_Type__c
                );
                //add the new field to be updated
                personContactsToUpdate.get(con.Parent_Person_Contact__c)
                    .put(marketingFieldMap.get(field), con.get(field));
            }
        }
    }

    /**
     * @description map marketing fields from Parent Person to child MC Persona
     * when marketing fields are updated
     *
     * @param con  Contact record
     * @param oldItems  Map of old Contact records
     * @param childMCToParentMap child MC persona contact records to be upserted
     * @return contactsToUpsert - MC Contacts to be upserted
     */
    private static List<Contact> mapMarketingFieldsToChildMCContact(
        Contact con,
        Map<Id, Contact> oldItems,
        Map<String, Contact> childMCToParentMap
    ) {
        List<Contact> contactsToUpsert = new List<Contact>();
        boolean isInsert = oldItems == null;
        boolean isRecordTypeUpdated =
            !isInsert && con.RecordTypeId != oldItems.get(con.Id).RecordTypeId;

        //construct a map that contains the trigger.new and trigger.old contact
        Map<String, Contact> triggerContactMap = new Map<String, Contact>{
            'New' => con,
            'Old' => oldItems != null ? oldItems.get(con.Id) : null
        };

        //do not proceed if current contact is not a person contact
        if (con.RecordTypeId != ContactsDAO.PERSON_RECORDTYPE_ID) {
            return contactsToUpsert;
        }

        //loop through the persona types - work,qut learner, qut staff
        for (String personaType : MarketingService.PERSONA_TYPES_TO_EMAIL_MAP.keySet()) {
            //get the marketing field map
            //see MarketingService static variables
            Map<String, String> marketingFieldMap = MarketingService.PERSONA_TYPE_TO_MARKETING_FIELDS.get(
                personaType
            );

            //only upsert MC Persona if Person Work Email/QUT Learner Email/QUT Staff Email is populated
            //Person is newly inserted or
            //Contact is updated to Person or
            //Any of the Marketing fields is updated
            boolean isMCEmailNotBlank = String.isNotBlank(
                (String) con.get(MarketingService.PERSONA_TYPES_TO_EMAIL_MAP.get(personaType))
            );
            boolean isUpsertMCPersona =
                isInsert ||
                isRecordTypeUpdated ||
                isMarketingFieldsUpdated(
                    new Set<String>(marketingFieldMap.values()),
                    con,
                    oldItems.get(con.Id)
                );

                if (isMCEmailNotBlank && isUpsertMCPersona) {
                    contactsToUpsert.addAll(
                        //map the marketing fields to the MC Record
                        buildMCPersonaRecords(personaType, triggerContactMap, childMCToParentMap)
                    );
                }
        }

        return contactsToUpsert;
    }

    /**
     * @description compares contact old and new record
     * returns true if a field does not match
     *
     * @param fields - fields to be compared
     * @param newRecord -  Contact trigger.new
     * @param oldRecord -  Contact trigger.old
     */
    private static boolean isMarketingFieldsUpdated(
        Set<String> fields,
        Contact newRecord,
        Contact oldRecord
    ) {
        for (String field : fields) {
            if (newRecord.get(field) != oldRecord.get(field)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @description builds the MC Persona Contact record to be upserted
     *
     * @param personaType - current persona type of MC to create
     * @param triggerContactMap -  map of  Contact trigger.new and trigger.old
     * @param childMCToParentMap -  existing mc records grouped by person parent id + persona type
     * @return contactsToUpsert - MC Persona contacts to be upserted
     */
    private static List<Contact> buildMCPersonaRecords(
        String personaType,
        Map<String, Contact> triggerContactMap,
        Map<String, Contact> childMCToParentMap
    ) {
        Contact con = triggerContactMap.get('New');
        Contact oldCon = triggerContactMap.get('Old');

        Map<String, String> marketingFieldsMap = MarketingService.PERSONA_TYPE_TO_MARKETING_FIELDS.get(
            personaType
        );

        List<Contact> contactsToUpsert = new List<Contact>();
         //create initial new MC Persona Record
        Contact tempContact = new Contact(
            FirstName = con.FirstName,
            LastName = con.LastName,
            RecordtypeId = ContactsDAO.MC_PERSONA_RECORDTYPE_ID,
            Parent_Person_Contact__c = con.Id,
            Persona_Type__c = personaType
        );

        //map marketing fields
        //e.g Work_Email__c => Email or QUT_Staff_Email__c => Email depending of persona type
        //see MarketingService static variables
        for (String field : MarketingService.PERSONAL_MARKETING_FIELDS) {
            tempContact.put(field, con.get(marketingFieldsMap.get(field)));
        }

        //if there is an existing MC Persona and Person Contact's MC field is updated
        //update the existing MC Persona
        if (childMCToParentMap.containsKey(con.Id + personaType)) {
            //create new instance override initial tempContact
            tempContact = new Contact();
            //build contact record to update
            tempContact.put('Id', childMCToParentMap.get(con.Id + personaType).Id);

            //map the updated fields
            for (String field : MarketingService.PERSONAL_MARKETING_FIELDS) {
                String marketingField = MarketingService.PERSONA_TYPE_TO_MARKETING_FIELDS.get(
                        personaType
                    )
                    .get(field);
                if (con.get(marketingField) != oldCon.get(marketingField)) {
                    tempContact.put(field, con.get(marketingField));
                }
            }
        }
        contactsToUpsert.add(tempContact);

        return contactsToUpsert;
    }

    /***
     * @description create account contact relation records for business org and contact
     * @param conNew - trigger.new contacts
     */
    public static void createAccountContactRelationRecords(
        List<Contact> newItems,
        Map<Id, Contact> oldMap
    ) {
        //map of acrt to be inserted
        Map<String, AccountContactRelation> acrToBeUpserted = new Map<String, AccountContactRelation>();

        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Contact con : newItems) {
            if (
                (con.hed__Primary_Organization__c != null &&
                con.hed__Primary_Organization__c != con.AccountId &&
                (oldMap == null ||
                oldMap.get(con.Id).hed__Primary_Organization__c !=
                con.hed__Primary_Organization__c))
            ) {
                //store contact and account ids
                contactIds.add(con.Id);
                accountIds.add(con.hed__Primary_Organization__c);

                //build ACR Record to upsert
                acrToBeUpserted.put(
                    String.valueOf(con.hed__Primary_Organization__c) + String.valueOf(con.Id),
                    new AccountContactRelation(
                        Id = null,
                        AccountId = con.hed__Primary_Organization__c,
                        ContactId = con.Id,
                        IsActive = true
                    )
                );
                //deactivate old ACR when removed
            } else if (
                con.hed__Primary_Organization__c == null &&
                oldMap != null &&
                oldMap.get(con.Id).hed__Primary_Organization__c != con.hed__Primary_Organization__c
            ) {
                contactIds.add(con.Id);
                accountIds.add(oldMap.get(con.Id).hed__Primary_Organization__c);

                //build ACR Record to upsert
                //set previous acr to isactive false
                acrToBeUpserted.put(
                    String.valueOf(oldMap.get(con.Id).hed__Primary_Organization__c) +
                    String.valueOf(con.Id),
                    new AccountContactRelation(
                        Id = null,
                        AccountId = oldMap.get(con.Id).hed__Primary_Organization__c,
                        ContactId = con.Id,
                        IsActive = false
                    )
                );
            }
        }

        if (!acrToBeUpserted.isEmpty()) {
            acrToBeUpserted = checkForExistingACR(accountIds, contactIds, acrToBeUpserted);

            upsert acrToBeUpserted.values();

            //deactivate other ACR linked the contact
            deactivateExistingACRRecords(acrToBeUpserted.values(), contactIds);
        }
    }

    private static Map<String, AccountContactRelation> checkForExistingACR(
        Set<Id> accountIds,
        Set<Id> contactIds,
        Map<String, AccountContactRelation> acrToBeUpserted
    ) {
        //get all ACR with the same contact and account ids
        List<AccountContactRelation> existingACR = new List<AccountContactRelation>(
            [
                SELECT Id, AccountId, ContactId
                FROM AccountContactRelation
                WHERE AccountId IN :accountIds AND ContactId IN :contactIds
            ]
        );

        for (AccountContactRelation acr : existingACR) {
            if (
                acr.AccountId != null &&
                acr.ContactId != null &&
                acrToBeUpserted.containsKey(
                    String.valueOf(acr.AccountId) + String.valueOf(acr.contactId)
                )
            ) {
                //set the id of the ACR if found
                //this would set the IsActive status of existing ACR to True
                acrToBeUpserted.get(String.valueOf(acr.AccountId) + String.valueOf(acr.contactId))
                    .Id = acr.Id;
            }
        }

        return acrToBeUpserted;
    }

    private static void deactivateExistingACRRecords(
        List<AccountContactRelation> newACRs,
        Set<Id> contactIds
    ) {
        List<AccountContactRelation> acrToDeactivate = new List<AccountContactRelation>(
            [
                SELECT Id, IsActive
                FROM AccountContactRelation
                WHERE
                    ContactId IN :contactIds
                    AND Account.RecordType.Name = 'Business Organization'
                    AND Id NOT IN :newACRs
                    AND IsActive = TRUE
            ]
        );

        for (AccountContactRelation acr : acrToDeactivate) {
            acr.IsActive = false;
        }

        if (!acrToDeactivate.isEmpty()) {
            update acrToDeactivate;
        }
    }

    /**
     * @description Update Moving To Brisbane field on contact insert
     * @param newItem List of new contacts
     */
    public static void updateMovingToBrisbane(List<SObject> newItems) {
        Map<Id, Marketing_Segmentation__c> marSegMap = getMarketingSegmentationsOnContactList(
            (List<Contact>) newitems
        );
        for (Contact newItem : (List<Contact>) newItems) {
            if (newItem.Marketing_Segmentation__c != null) {
                newItem.Moving_To_Brisbane__c = marSegMap.get(newItem.Marketing_Segmentation__c)
                    .My_Moving_To_Brisbane__c;
            }
        }
    }

    /**
     * @description Update Moving To Brisbane field on contact with updated marketing segmentation
     * @param newItem Map of updated contacts and their ids
     * @param oldItem Map of outdated contacts and their ids
     */
    public static void updateMovingToBrisbane(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id, Marketing_Segmentation__c>();

        List<Contact> contactsWithMarSeg = new List<Contact>();

        //collect contacts where marketing segmentaion is updated
        for (Contact newItem : (List<Contact>) newItems.values()) {
            Contact oldItem = (Contact) oldItems.get(newItem.Id);
            if (
                newItem.Marketing_Segmentation__c != null &&
                newItem.Marketing_Segmentation__c != oldItem.Marketing_Segmentation__c
            ) {
                contactsWithMarSeg.add(newItem);
            }
        }

        //get related marketing segmentation
        if (!contactsWithMarSeg.isEmpty()) {
            marSegMap = getMarketingSegmentationsOnContactList(contactsWithMarSeg);
        }

        //update moving to brisbane field
        for (Contact newItem : contactsWithMarSeg) {
            if (marSegMap.containsKey(newItem.Marketing_Segmentation__c)) {
                newItem.Moving_To_Brisbane__c = marSegMap.get(newItem.Marketing_Segmentation__c)
                    .My_Moving_To_Brisbane__c;
            }
        }
    }

    private static Map<Id, Marketing_Segmentation__c> getMarketingSegmentationsOnContactList(
        List<Contact> contacts
    ) {
        Map<Id, Marketing_Segmentation__c> marketingSegMap = new Map<Id, Marketing_Segmentation__c>();

        Set<Id> marSegIdsInNewItems = new Set<Id>();
        for (Contact con : (List<Contact>) contacts) {
            if (!String.isBlank(con.Marketing_Segmentation__c)) {
                marSegIdsInNewItems.add(con.Marketing_Segmentation__c);
            }
        }

        if (!marSegIdsInNewItems.isEmpty()) {
            return new Map<Id, Marketing_Segmentation__c>(
                [
                    SELECT Id, My_Moving_To_Brisbane__c
                    FROM Marketing_Segmentation__c
                    WHERE Id IN :marSegIdsInNewItems
                    WITH SYSTEM_MODE
                ]
            );
        }

        return marketingSegMap;
    }

    /**
     * @description get the contactIds of the contact who's calculated cadence value is updated
     *
     * @param List<Contact> newItems
     * @param Map<Id, Contact> oldItems
     */
    public static void getContactCalculatedCadence(
        List<Contact> newItems,
        Map<Id, Contact> oldItems
    ) {
        Map<String, String> assignContactToCadenceMap = new Map<String, String>();
        Map<String, String> removeContactToCadenceMap = new Map<String, String>();

        for (Contact con : newItems) {
            if (con.RecordTypeId != ContactsDAO.PERSON_RECORDTYPE_ID) {
                continue;
            }

            Contact oldContact = oldItems.get(con.Id);
            String calculatedCadence = con.Calculated_Cadence__c;
            String oldCalculatedCadence = oldContact.Calculated_Cadence__c;

            if (calculatedCadence != oldCalculatedCadence) {
                if (String.isNotEmpty(calculatedCadence) && String.isEmpty(oldCalculatedCadence)) {
                    assignContactToCadenceMap.put(con.Id, calculatedCadence);
                } else if (
                    String.isEmpty(calculatedCadence) && String.isNotEmpty(oldCalculatedCadence)
                ) {
                    removeContactToCadenceMap.put(con.Id, oldCalculatedCadence);
                }
            }
        }

        if (!assignContactToCadenceMap.isEmpty() || !removeContactToCadenceMap.isEmpty()) {
            SalesCadenceCalloutService.processSaleCadences(
                assignContactToCadenceMap,
                removeContactToCadenceMap
            );
            SalesCadenceCalloutService.updateCreateCompletedCadenceRecords(
                assignContactToCadenceMap,
                removeContactToCadenceMap
            );
        }
    }
    /**
     * @description create a Marketing Segmentation on the newly created contact
     *
     * @param Set<Id> contactIds
     */
    public static void createMarketingSegmentation(Set<Id> contactIds) {
        List<Marketing_Segmentation__c> marketingSegToInsert = new List<Marketing_Segmentation__c>();
        Map<Id, Marketing_Segmentation__c> marketingSegMap = new Map<Id, Marketing_Segmentation__c>();

        for (
            Marketing_Segmentation__c marSeg : MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactIds(contactIds, AccessLevel.SYSTEM_MODE)
        ) {
            marketingSegMap.put(marSeg.Contact__c, marSeg);
        }

        for (Id contactId : contactIds) {
            if (!marketingSegMap.containsKey(contactId)) {
                marketingSegToInsert.add(new Marketing_Segmentation__c(Contact__c = contactId));
            }
        }
        if (!marketingSegToInsert.IsEmpty()) {
            MarketingSegmentationsDAO.newInstance()
                .insertRecords(marketingSegToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description Minimum value for Date of Birth
     * @param Contact to be evaluated
     */
    private static void birthDateValidation(Contact con) {
        Date minDOB = System.Today().addYears(-15);

        if (con.Birthdate > minDOB) {
            con.Birthdate.addError('Must be 15 years or older to register');
        }
    }

    /**
     * @description Sets the Matching_Firstname__c and Matching_Lastname__c fields
     *              on a Contact record by removing any non-letter characters from the
     *              First Name and Last Name fields, only if the first name or last name
     *              has been newly added or updated.
     * @param con The Contact record for which to set the matching first and last names.
     * @param oldItems A map containing the old versions of Contact records before the update.
     */
    private static void setMatchingFirstAndLastName(Contact con, Map<Id, Contact> oldItems) {
        // Check if the first name or last name has been newly added or updated
        boolean isFirstNameNewOrUpdated =
            oldItems == null ||
            con.FirstName != oldItems.get(con.Id).FirstName;
        boolean isLastNameNewOrUpdated =
            oldItems == null ||
            con.LastName != oldItems.get(con.Id).LastName;

        // Regular expression pattern to match any character that is not a letter
        String regexPattern = '[^a-zA-Z]';

        // Check if the first name is updated
        if (isFirstNameNewOrUpdated) {
            // Update the Matching_Firstname__c field with the cleaned first name or empty
            con.Matching_Firstname__c = String.isNotBlank(con.FirstName)
                ? con.FirstName.replaceAll(regexPattern, '')
                : '';
        }

        // Check if the last name is updated
        if (isLastNameNewOrUpdated) {
            // Update the Matching_Lastname__c field with the cleaned last name or empty
            con.Matching_Lastname__c = String.isNotBlank(con.LastName)
                ? con.LastName.replaceAll(regexPattern, '')
                : '';
        }
    }
    /**
     * @description check or uncheck and QUT_Staff based on the contact details
     *
     * @param newItems  List of new Contact records
     */
    private static void setQUTPersonaFlag(Contact con) {
        con.QUT_Staff__c = (String.isNotEmpty(con.QUT_Employee_ID__c) &&
            con.Staff_End_Date__c > SYSTEM.today())
            ? true
            : false;
    }

    /**
     * @description set can nurture flag lead score if above or below threshold
     *
     * @param Contact con - trigger.new of contact
     * @param List<Contact> contactsToRecalculate - contacts to recalculate
     * @param Map<Id, Contact> oldContacts - trigger.old of contact
     */
    private static void setCanNurtureFlag(
        Contact con,
        List<Contact> contactsToRecalculate,
        Map<Id, Contact> oldContacts
    ) {
        Boolean isInsert = oldContacts == null;
        //on insert or update
        //check if QUT Applicant is set to false on insert or update
        Boolean isQUTApplicantChanged = (!isInsert &&
        oldContacts.get(con.Id).QUT_Applicant__c != con.QUT_Applicant__c);

        //check if lead score value changed
        Boolean isLeadScoreChanged = (!isInsert &&
        oldContacts.get(con.Id).Lead_Score__c != con.Lead_Score__c);
        boolean isPartnerSourced =
            con.Lead_Source_Category__c == ContactsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCE;
        Boolean isPartnerSourcedChanged =
            (!isInsert &&
            oldContacts.get(con.Id).Lead_Source_Category__c != con.Lead_Source_Category__c) &&
            isPartnerSourced;

        if (isPartnerSourcedChanged) {
            con.Can_Nurture__c = true;
        }

        //check if contact is applicant
        if ((con.QUT_Applicant__c || isPartnerSourced) && isInsert) {
            con.Can_Nurture__c = true;
        } else if (isLeadScoreChanged || isQUTApplicantChanged) {
            contactsToRecalculate.add(con);
        }
    }

    /**
     * @description recalculate contacts and set Can_Nurture__c based on the specified criteria
     *
     * @param List<Contact> contactsToRecalculate
     */
    private static void recalculateCanNurture(List<Contact> contactsToRecalculate) {
        if (contactsToRecalculate.isEmpty()) {
            return;
        }

        Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack = new Map<String, Nurture_Track_Configuration__c>();
        Set<Id> contactWithActiveApplications = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactsToRecalculate);

        // Populate mapOfNurtureTrack with nurturing track records for Strong Interest
        populateNurtureTrackMap(mapOfNurtureTrack);

        // Populate contactWithActiveApplications with active contact IDs
        populateActiveApplicationsSet(contactWithActiveApplications, contactMap);

        if (!mapOfNurtureTrack.isEmpty() || !contactWithActiveApplications.isEmpty()) {
            for (Contact con : contactsToRecalculate) {
                Decimal minScore = getMinScore(con.hed__Citizenship_Status__c, mapOfNurtureTrack);

                // Check if the lead score is greater than or equal to the Strong Interest threshold nurture track
                // Or if the contact is linked to an active application record, then set the Can_Nurture flag to TRUE
                con.Can_Nurture__c =
                    LeadScoreService.isLeadScoreInRange(con.Lead_Score__c, minScore, null) ||
                    contactWithActiveApplications.contains(con.Id);
            }
        }
    }
    /**
     * @description get strong interest nurture track
     *
     * @param Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack)
     */
    private static void populateNurtureTrackMap(
        Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack
    ) {
        for (
            Nurture_Track_Configuration__c nurture : NurtureTrackConfigurationsDAO.newInstance()
                .getNurtureTrackLeadScoreThreshold('SYSTEM_MODE')
        ) {
            if (isStrongInterestCadence(nurture.Cadence_Name__c)) {
                mapOfNurtureTrack.put(nurture.Cadence_Name__c, nurture);
            }
        }
    }

    /**
     * @description check if cadence is strong interest
     *
     * @param String cadenceName
     */
    private static boolean isStrongInterestCadence(String cadenceName) {
        return cadenceName ==
            NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL ||
            cadenceName ==
            NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
    }

    /**
     * @description get active application of contact
     *
     * @param Set<Id> contactWithActiveApplications, Map<Id, Contact> contactMap
     */
    private static void populateActiveApplicationsSet(
        Set<Id> contactWithActiveApplications,
        Map<Id, Contact> contactMap
    ) {
        for (
            hed__Application__c app : ApplicationsDAO.newInstance()
                .getApplicationsActiveApplicants(contactMap.keySet(), 'SYSTEM_MODE')
        ) {
            contactWithActiveApplications.add(app.hed__Applicant__c);
        }
    }

    /**
     * @description set the nurture track lead score threshold
     *
     * @param String citizenshipStatus, Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack
     */
    private static Decimal getMinScore(
        String citizenshipStatus,
        Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack
    ) {
        if (citizenshipStatus == 'Domestic' || citizenshipStatus == 'International') {
            String cadenceName = (citizenshipStatus == 'International')
                ? NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL
                : NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
            return mapOfNurtureTrack.get(cadenceName)?.Lead_Score_Threshold__c;
        }
        return null;
    }

    /***
     * @description update Registered email when match to Primary Email or Work Email
     * @param newItems - trigger.new contacts
     * @param oldItems - trigger.old contacts
     */
    private static void updateRegisteredEmail(Contact newItems, Map<Id, Contact> oldItems) {
        Boolean isUpdate = oldItems != null;
        Boolean isPrimaryEmailChange =
            isUpdate && newItems.Email != oldItems.get(newItems.Id).Email;
        Boolean isWorkEmailChange =
            isUpdate && newItems.Work_Email__c != oldItems.get(newItems.Id).Work_Email__c;
        Boolean isRegisteredEmailMatchPrimaryEmail =
            isUpdate &&
            (oldItems.get(newItems.Id).Email == oldItems.get(newItems.Id).Registered_Email__c);
        Boolean isRegisteredEmailMatchWorkEmail =
            isUpdate &&
            (oldItems.get(newItems.Id).Work_Email__c ==
            oldItems.get(newItems.Id).Registered_Email__c);
        Boolean updateRegisteredEmailFromPrimary =
            isPrimaryEmailChange && isRegisteredEmailMatchPrimaryEmail;
        Boolean updateRegisteredEmailFromWork =
            isWorkEmailChange && isRegisteredEmailMatchWorkEmail;
        if (updateRegisteredEmailFromPrimary) {
            newItems.Registered_Email__c = newItems.Email;
        } else if (updateRegisteredEmailFromWork) {
            newItems.Registered_Email__c = newItems.Work_Email__c;
        }
    }

    public static void createLeadScoreDetailRecord(List<Contact> contactList) {
        List<Lead_Score_Detail__c> leadScoreDetailsToInsert = new List<Lead_Score_Detail__c>();
        for (Contact contact : contactList) {
            if (contact.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID) {
                leadScoreDetailsToInsert.add(new Lead_Score_Detail__c(Contact__c = contact.Id));
            }
        }
        if (!contactList.isEmpty()) {
            LeadScoreDetailsDAO.newInstance()
                .insertRecords(leadScoreDetailsToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /***
     * @description update Sync_To_MC__c field and Do_Not_Sync_To_MC_Override__c based from condition
     * @param newItems - trigger.new contact
     * @param oldItems - trigger.old contacts
     */
    private static void updateSyncToMCField(Contact newItems, Map<Id, Contact> oldItems) {
        Boolean isUpdate = oldItems != null;
        Boolean isDoNotSyncToMCOverrideChanged = false;
        Boolean isPrimaryEmailChanged = false;
        Boolean isMobilePhoneChanged = false;

        if (isUpdate) {
            isDoNotSyncToMCOverrideChanged =
                oldItems.get(newItems.Id).Do_Not_Sync_To_MC_Override__c !=
                newItems.Do_Not_Sync_To_MC_Override__c;
            isPrimaryEmailChanged = oldItems.get(newItems.Id).Email != newItems.Email;
            isMobilePhoneChanged = oldItems.get(newItems.Id).MobilePhone != newItems.MobilePhone;
        }
        if (
            (!isUpdate || isDoNotSyncToMCOverrideChanged) &&
            newItems.Do_Not_Sync_To_MC_Override__c == true
        ) {
            newItems.Sync_to_MC__c = false;
        }
        if (
            (!isUpdate || isPrimaryEmailChanged || isMobilePhoneChanged) &&
            (newItems.Email != null ||
            newItems.MobilePhone != null)
        ) {
            newItems.Sync_To_MC__c = true;
        }
    }

    /**
     * Checks if the email fields on a contact have been modified during lead conversion and performs actions accordingly.
     * This method ensures that redundant email information is not duplicated in the contact fields.
     *
     * @param con The Contact object representing the converted lead.
     * @param oldMap A map containing the old values of the contacts before conversion.
     */
    private static void checkIfEmailIsAlreadyMatchOnContactLeadConversion(
        Contact con,
        Map<Id, Contact> oldMap
    ) {
        if (oldMap == null) {
            return;
        }

        Boolean isEmailChanged =
            oldMap.get(con.Id).Email == null &&
            con.Email != oldMap.get(con.Id).Email;
        Boolean isWorkEmailChanged =
            oldMap.get(con.Id).Work_Email__c == null &&
            con.Work_Email__c != oldMap.get(con.Id).Work_Email__c;

        if (isEmailChanged) {
            Boolean isPersonalEmailMatch =
                con.Email == con.Work_Email__c ||
                con.Email == con.QUT_Learner_Email__c ||
                con.Email == con.QUT_Staff_Email__c;
            if (isPersonalEmailMatch) {
                con.Email = '';
            }
        }

        if (isWorkEmailChanged) {
            Boolean isWorkEmailMatch =
                con.Work_Email__c == con.Email ||
                con.Work_Email__c == con.QUT_Learner_Email__c ||
                con.Work_Email__c == con.QUT_Staff_Email__c;
            if (isWorkEmailMatch) {
                con.Work_Email__c = '';
            }
        }
    }

    /**
     * Processes system key changes on contacts.
     * This method is triggered when there are changes to a list of contacts.
     * It handles the insertion and updating of Contact Alternate IDs based on changes in system keys.
     *
     * @param newContacts List of new contacts or contacts with changes
     * @param oldMap Map of old contacts (can be null if all contacts are new)
     */
    public static void processSystemKeyChangeOnContactTrigger(
        List<Contact> newContacts,
        Map<Id, Contact> oldMap
    ) {
        // Map to store new Contact Alternate IDs to be inserted
        Map<String, Contact_Alternate_ID__c> conAltIdsToInsertMap = new Map<String, Contact_Alternate_ID__c>();
        // Set to store contact Ids for querying existing Contact Alternate IDs
        Set<Id> contactIds = new Set<Id>();
        // Set to store system key Ids for querying existing Contact Alternate IDs
        Set<String> systemKeyIds = new Set<String>();
        String uniqueContactToIdKey = '';
        String uniqueContactToIdTypeKey = '';

        // Iterate through new contacts to determine system key changes
        for (Contact con : newContacts) {
            // Check if the contact has a new QUT Student ID
            boolean isNewStudentId = oldMap == null && String.isNotBlank(con.QUT_Student_ID__c);
            // Check if the contact has a new QUT Employee ID
            boolean isNewEmployeeId = oldMap == null && String.isNotBlank(con.QUT_Employee_ID__c);
            // Check if the contact's QUT Student ID has been updated
            boolean isUpdatedStudentId =
                oldMap != null &&
                String.isNotBlank(con.QUT_Student_ID__c) &&
                oldMap.get(con.Id).QUT_Student_ID__c != con.QUT_Student_ID__c;
            // Check if the contact's QUT Employee ID has been updated
            boolean isUpdatedEmployeeId =
                oldMap != null &&
                String.isNotBlank(con.QUT_Employee_ID__c) &&
                oldMap.get(con.Id).QUT_Employee_ID__c != con.QUT_Employee_ID__c;

            // Check if system key changes are related to Student ID
            boolean isCheckStudentId = isNewStudentId || isUpdatedStudentId;
            // Check if system key changes are related to Employee ID
            boolean isCheckEmployeeId = isNewEmployeeId || isUpdatedEmployeeId;

            // Process Student ID changes
            if (isCheckStudentId) {
                uniqueContactToIdKey = con.Id + con.QUT_Student_ID__c;
                systemKeyIds.add(con.QUT_Student_ID__c);
                // Create Contact Alternate ID record for Student ID
                conAltIdsToInsertMap.put(
                    uniqueContactToIdKey,
                    new Contact_Alternate_ID__c(
                        Contact_Alternate_Id__c = con.QUT_Student_ID__c,
                        Alternate_Id_Status__c = 'Active',
                        Alternate_Id_Type__c = 'QUT Student ID',
                        Start_Date__c = System.Today(),
                        Contact__c = con.Id
                    )
                );
                contactIds.add(con.Id); // Add contact Id for querying existing Contact Alternate IDs
            }

            // Process Employee ID changes
            if (isCheckEmployeeId) {
                uniqueContactToIdKey = con.Id + con.QUT_Employee_ID__c;
                systemKeyIds.add(con.QUT_Employee_ID__c);
                // Create Contact Alternate ID record for Employee ID
                conAltIdsToInsertMap.put(
                    uniqueContactToIdKey,
                    new Contact_Alternate_ID__c(
                        Contact_Alternate_Id__c = con.QUT_Employee_ID__c,
                        Alternate_Id_Status__c = 'Active',
                        Alternate_Id_Type__c = 'QUT Employee ID',
                        Start_Date__c = System.Today(),
                        Contact__c = con.Id
                    )
                );
                contactIds.add(con.Id); // Add contact Id for querying existing Contact Alternate IDs
            }
        }

        // Get existing Contact Alternate IDs related to the collected Contact Ids
        List<Contact_Alternate_ID__c> existingConAltIds = ContactAlternateIdsDAO.newInstance()
            .getContactAlternateIdsByContactIdSet(contactIds, AccessLevel.SYSTEM_MODE);
        // Map existing Contact Alternate IDs by Contact Id + System Key Type
        // Remove existing Contact Alternate Ids by Contact Id + System key Id
        Map<String, Contact_Alternate_ID__c> conSystemKeyCAIMap = new Map<String, Contact_Alternate_ID__c>();
        for (Contact_Alternate_ID__c contactAltId : existingConAltIds) {
            uniqueContactToIdTypeKey = contactAltId.Contact__c + contactAltId.Alternate_Id_Type__c;
            uniqueContactToIdKey = contactAltId.Contact__c + contactAltId.Contact_Alternate_Id__c;

            conSystemKeyCAIMap.put(uniqueContactToIdTypeKey, contactAltId);
            conAltIdsToInsertMap.remove(uniqueContactToIdKey);
        }

        // Insert new Contact Alternate IDs if any
        if (!conAltIdsToInsertMap.isEmpty()) {
            ContactAlternateIdsDAO.newInstance()
                .insertRecords(conAltIdsToInsertMap.values(), false, AccessLevel.SYSTEM_MODE);
        }

        // Update existing Contact Alternate IDs
        ContactAlternateIdService.updateContactAndContactAlternateIds(
            conAltIdsToInsertMap.values(),
            conSystemKeyCAIMap,
            false
        );
    }

    /**
     * Processes contact matching when the contact trigger is fired.
     *
     * @param newContacts The list of new contacts
     * @param oldContactsMap The map of old contacts
     */
    public static void processContactMatchingOnContactTrigger(
        List<Contact> newContacts,
        Map<Id, Contact> oldContactsMap
    ) {
        // Initialize maps and lists to store data during processing
        Map<Id, String> contactMatchingToMatchingResultKey = new Map<Id, String>();
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactsToMatch = new List<Contact>();
        Set<String> contactIds = new Set<String>();
        String uniqueKey = '';
        Contact oldContact;

        // Iterate through each contact
        for (Contact newContact : newContacts) {
            //indicates that firstName,lastname,DOB, or Mobilephone has been updated
            oldContact = oldContactsMap.get(newContact.Id);

            boolean isOneOfContactFieldsUpdated = 
            newContact.FirstName != oldContact.FirstName ||
            newContact.LastName != oldContact.LastName || 
            newContact.Birthdate != oldContact.Birthdate || 
            newContact.Mobilephone != oldContact.Mobilephone;
            
            boolean isOneOfEmailFieldsUpdated = 
            newContact.Email != oldContact.Email ||
            newContact.QUT_Learner_Email__c != oldContact.QUT_Learner_Email__c || 
            newContact.QUT_Staff_Email__c != oldContact.QUT_Staff_Email__c || 
            newContact.Work_Email__c != oldContact.Work_Email__c;

            //indicates that no fields are updated
            boolean isExcludedFromPayload =
                (!isOneOfContactFieldsUpdated && !isOneOfEmailFieldsUpdated) ||
                newContact.RecordTypeId != ContactsDAO.PERSON_RECORDTYPE_ID;

            if (isExcludedFromPayload) {
                continue;
            }

            // Create a matching record from the contact record's data
            ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(
                new Map<String, String>{
                    'firstName' => newContact.Matching_Firstname__c,
                    'lastName' => newContact.Matching_Lastname__c,
                    //if any of the email is updated, set the primary email in the payload to null
                    //this means that the email updated is unique or null
                    'email' => isOneOfEmailFieldsUpdated ? '' : newContact.Email,
                    'birthDate' => newContact.Birthdate != null
                        ? String.valueOf(newContact.Birthdate)
                        : '',
                    'mobilePhone' => newContact.MobilePhone
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
            contactMatchingToMatchingResultKey.put(newContact.Id, uniqueKey);
            // Store contacts for matching
            contactsToMatch.add(newContact);
            contactIds.add(newContact.Id);
        }

        // skip contact matching services if no contacts for matching found
        if (contactsToMatch.isEmpty()) {
            return;
        }

        // Process the contact matching services
        Map<String, MatchingResult> matchingResults = ContactMatchingService.processContactMatching(
            matchingRecords,
            contactIds
        );

        // Process the matching results
        processMatchingResult(contactsToMatch, matchingResults, contactMatchingToMatchingResultKey);
    }

    /**
     * Processes the results of contact matching.
     *
     * @param contactsToMatch The list of contacts that were matched.
     * @param matchingResults The results of the contact matching.
     * @param contactMatchingToMatchingResultKey A map of contact IDs to their matching result keys.
     */
    private static void processMatchingResult(
        List<Contact> contactsToMatch,
        Map<String, MatchingResult> matchingResults,
        Map<Id, String> contactMatchingToMatchingResultKey
    ) {
        MatchingResult result;

        // Iterate through each contact to match
        for (Contact contactToMatch : contactsToMatch) {
            // Get the contact unique key string assigned to the current contact ID
            String contactUniqueKey = contactMatchingToMatchingResultKey.get(contactToMatch.Id);
            // Get the matching result using the unique key
            result = matchingResults.get(contactUniqueKey);

            //evaluate matching result
            boolean isMultipleMatch = result.errorMessage == 'Multiple match found';
            //one match found
            boolean isSingleMatch =
                !result.error &&
                String.isNotBlank(result.matchingType);
            //natural key email/mobile confirmation failed and contacts are found
            boolean isNaturalKeyConfirmationFailed =
                result.errorMessage ==
                'Contact Record does not match email and/or mobile provided';

            // Determine if another existing contact was found
            boolean isMatchingContactFound =
                isMultipleMatch ||
                isSingleMatch ||
                isNaturalKeyConfirmationFailed;

            // Add an error to the current contact if another existing contact was found
            if (isMatchingContactFound) {
                contactToMatch.addError(
                    'Contact update failed to prevent duplicate contact creation'
                );
            }
        }
    }

    private static void updateCanNurtureDependentFields(Contact con, Map<Id, Contact> oldItems) {
        if(con.Can_Nurture__c == false && (oldItems == null || oldItems.get(con.Id).Can_Nurture__c != con.Can_Nurture__c)) {
            con.Calculated_Cadence__c = null;
            con.Cadence_Application__c = null;
        }
    }
}