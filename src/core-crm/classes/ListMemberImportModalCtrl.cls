/**
 * @description Controller Class for LWC listMemberImportModal
 * @see ../lwc/listMemberImportModal
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | Jan 23, 2024          | DEPP-7005              | Created file                                      |
 */
public with sharing class ListMemberImportModalCtrl {

    /**
     * @description Fetches Contact Object by Ids
     * @param ids Contact Ids
     * @return Records of List<Contact>
    */
    @AuraEnabled
    public static List<Contact> getContactById(String ids) {
        List<String> idList = ids.split(',');
        Set<Id> idSet = new Set<Id>();
        for (String idString : idList) {
            idSet.add((Id)idString.trim());
        }

        List<Contact> contacts = ContactsDAO.newInstance().getAlumniPersonContactsBySetIds(idSet, AccessLevel.USER_MODE);

        return contacts;
    }

    /**
     * @description Fetches the List Contributor Object by Ids
     * @param ids List Contributor Ids
     * @return Records of List<List_Contributor__c>
     */
    @AuraEnabled
    public static List<List_Contributor__c> getListContributorByIds(Id listId, String contributorIds) {
        List<String> idList = contributorIds.split(',');
        Set<Id> idSet = new Set<Id>();
        for (String idString : idList) {
            idSet.add((Id)idString.trim());
        }

        List<List_Contributor__c> listContributorRecord = ListContributorsDAO.newInstance().getRecordIdListContributorByListID(idSet, new Set<Id>{listId}, AccessLevel.USER_MODE);

        return listContributorRecord;
    }

    /**
     * @description bulk save list member
     * @param listId, record list members
     * @return Records success
    */
    @AuraEnabled
    public static Boolean bulkSaveListMember(List<List_Member__c> record) {
        ListMembersDAO.newInstance().insertRecords(record, false, AccessLevel.USER_MODE);
        return true;
    }
}