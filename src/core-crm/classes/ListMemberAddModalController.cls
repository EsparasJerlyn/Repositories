/**
 * @description Controller Class for ListMemberAddModal LWC
 * @see ../lwc/listMemberAddModal
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | carl.alvin.cabiles             | January 18, 2024      | DEPP-7003              | Created file                                      |
      | nicole.genon                   | January 31, 2024      | DEPP-7003              | Added checkIfExistingContact                      |
 */
public with sharing class ListMemberAddModalController {
    /**
    * @description return ID for default List Contributor
    * @param listContributorRecord - List Contributor with List Contributor Field as the current user
    */
    @AuraEnabled(cacheable=true)
    public static List<List_Contributor__c> getDefaultListContributor(Id listId, Id currentUser){        
        List<List_Contributor__c> listContributorRecord= ListContributorsDAO.newInstance().getListContributorByUserID(new Set<Id>{listId}, new Set<Id>{currentUser}, AccessLevel.SYSTEM_MODE);
      
        return listContributorRecord;
    }

    /**
    * @description return Boolean true if contact already exist in the List Members Table
    * @param listId - List ID of current record
    * @param contactId - Selected Contact ID on List Member field
    */
    @AuraEnabled
    public static Boolean checkIfExistingContact(Id listId, Id contactId) {
        List<List_Member__c> listMembers = ListMembersDAO.newInstance().getexistingListMembersWithMatchingContactList(new Set<Id>{listId}, new Set<Id>{contactId}, 'SYSTEM_MODE');
        return listMembers.isEmpty()? false : true;
    }

    /**
    * @description get all Contributor related in List
    * @param listId - List ID of current record
    */
    @AuraEnabled(cacheable=true)
    public static List<List_Contributor__c> getRelatedListContributor(Id listId) {
        List<List_Contributor__c> listContributorRecord = ListContributorsDAO.newInstance().getListContributorByListID(new Set<Id>{listId}, AccessLevel.USER_MODE);
        return listContributorRecord;
    }

    /**
    * @description get all Contacts
    */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsWithMatchingEmailsPosition(String toSearch, Integer recordLimit) {
        List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithMatchingEmailsPosition(toSearch, recordLimit, AccessLevel.SYSTEM_MODE);

        return contactList;
    }

    /**
    * @description create new List Member record
    * @param records - List List Member record
    */
    @AuraEnabled
    public static Boolean createListMember(List<List_Member__c> records) {
        Boolean isSuccess = false;
        Database.SaveResult[] listMemberRecord = ListMembersDAO.newInstance().insertRecords(records, false, AccessLevel.USER_MODE);
        for (Database.SaveResult rec : listMemberRecord) {
            if (rec.isSuccess()) {
                isSuccess = true;
            }
        }

        return isSuccess;
    }
}