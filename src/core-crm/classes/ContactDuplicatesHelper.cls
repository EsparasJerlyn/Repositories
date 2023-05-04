/**
 * @description Helper class for detecting and handling duplicates for Contacts
 *
 * @see ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                |
 *    |---------------------------|-----------------------|----------------------|-----------------------------------------------|
 *    | angelika.j.s.galang       | May 17, 2022          | DEPP-1455            | Created File                                  |
 *    | alexander.cadalin         | June 22, 2022         | DEPP-3056            | Appended detectDuplicateInEmails              |
 *    | alexander.cadalin         | July 30, 2022         | DEPP-3623            | Included within batch duplicate checking      |
 *    | ryan.j.a.dela.cruz        | April 21, 2023        | DEPP-5553            | Prettier code reformat for new .prettierrc    |
 *    | roy.nino.s.regala         | April 23, 2022        | DEPP-5567            | Refactored to fix pmd issues                  |
 */

public without sharing class ContactDuplicatesHelper {
    public static void detectDuplicatesInEmails(List<Contact> newItems, Map<Id, Contact> oldItems) {
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
        Map<Id, Contact> newContactsWithIds = new Map<Id, Contact>();
        SObjectType recordObjectType = new ContactsDAO().getSObjectType();

        newContactsWithIds = getIdsMapAndCountFieldsToMatch(newItems, oldItems, recordObjectType);

        List<Contact> existingContactsWithMatchingEmails = ContactsDAO.newInstance()
            .getExistingPersonContactsWithMatchingEmails(
                DuplicateCheckerHelper.newItemsMatchCount.keySet(),
                newContactsWithIds.keySet(),
                'SYSTEM_MODE'
            );
        //process field matching
        if (
            !existingContactsWithMatchingEmails.isEmpty() ||
            !DuplicateCheckerHelper.newItemsMatchCount.isEmpty()
        ) {
            for (Contact newRecord : (oldItems == null ? newItems : newContactsWithIds.values())) {
                DuplicateCheckerHelper.processBatchChecking(newRecord, recordObjectType);
                DuplicateCheckerHelper.processWithOrgChecking(
                    newRecord,
                    existingContactsWithMatchingEmails,
                    recordObjectType
                );
            }
        }
    }

    private static Map<Id, Contact> getIdsMapAndCountFieldsToMatch(
        List<Contact> newItems,
        Map<Id, Contact> oldItems,
        SObjectType recordObjectType
    ) {
        Map<Id, Contact> newContactsWithIds = new Map<Id, Contact>();

        for (Contact record : newItems) {
            //store contact ids if there is a field change on update
            //count unique fields only when there is a change of the field on update or on insert
            if (
                DuplicateCheckerHelper.checkFieldChange(record, oldItems, recordObjectType) &&
                record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID
            ) {
                newContactsWithIds.put(record.Id, record);
                DuplicateCheckerHelper.countUniqueFieldsToMap(record, recordObjectType);
            } else if (
                oldItems == null &&
                record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID
            ) {
                DuplicateCheckerHelper.countUniqueFieldsToMap(record, recordObjectType);
            }
        }

        return newContactsWithIds;
    }
}
