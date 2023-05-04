/**
 * @description Helper class for detecting and handling duplicates for Leads
 * 
 * @see LeadTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|------------|-------------------------------------|
      | angelika.j.s.galang       | May 17, 2022          | DEPP-1455            | Created File                        |
	    | alexander.cadalin         | June 22, 2022         | DEPP-3056            | Appended detectDuplicatesInEmails   |
	    | alexander.cadalin         | July 29, 2022         | DEPP-3623            | Fixed issues with batch operations  |
      | roy.nino.s.regala         | April 23, 2023        | DEPP-5567            | Fixed pmd issues                    |
 */
public without sharing class LeadDuplicatesHelper {
    public static void detectDuplicatesInEmails(List<Lead> newItems, Map<Id, Lead> oldItems) {
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
        Map<Id, Lead> newLeadsWithIds = new Map<Id, Lead>();
        SObjectType recordObjectType = new LeadsDAO().getSObjectType();

        newLeadsWithIds = getIdsMapAndCountFieldsToMatch(newItems, oldItems, recordObjectType);

        List<Lead> existingLeadsWithMatchingEmails = LeadsDAO.newInstance()
            .getExistingUnconvertedLeadsByEmail(
                DuplicateCheckerHelper.newItemsMatchCount.keySet(),
                newLeadsWithIds.keySet(),
                'SYSTEM_MODE'
            );
        //process field matching
        if (
            !existingLeadsWithMatchingEmails.isEmpty() ||
            !DuplicateCheckerHelper.newItemsMatchCount.keySet().isEmpty()
        ) {
            for (Lead newRecord : (oldItems == null ? newItems : newLeadsWithIds.values())) {
                DuplicateCheckerHelper.processBatchChecking(newRecord, recordObjectType);
                DuplicateCheckerHelper.processWithOrgChecking(
                    newRecord,
                    existingLeadsWithMatchingEmails,
                    recordObjectType
                );
            }
        }
    }

    private static Map<Id, Lead> getIdsMapAndCountFieldsToMatch(
        List<Lead> newItems,
        Map<Id, Lead> oldItems,
        SObjectType recordObjectType
    ) {
        Map<Id, Lead> newLeadsWithIds = new Map<Id, Lead>();
        //store lead ids if there is a field change on update
        //count unique fields only when there is a change of the field on update or on insert
        for (Lead record : newItems) {
            if (DuplicateCheckerHelper.checkFieldChange(record, oldItems, recordObjectType)) {
                newLeadsWithIds.put(record.Id, record);
                DuplicateCheckerHelper.countUniqueFieldsToMap(record, recordObjectType);
            } else if (oldItems == null) {
                DuplicateCheckerHelper.countUniqueFieldsToMap(record, recordObjectType);
            }
        }

        return newLeadsWithIds;
    }
}
