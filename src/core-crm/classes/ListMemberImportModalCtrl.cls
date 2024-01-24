/**
 * @description Controller Class for List Members in List
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

        List<Contact> contacts = ContactsDAO.newInstance().getPersonContactsBySetIds(idSet, AccessLevel.USER_MODE);

        return contacts;
    }

    /**
     * @description bulk save list member
     * @param listId, record list members
     * @return Records of List<List_Member__c>
    */
    @AuraEnabled
    public static Boolean bulkSaveListMember(Id listId, String record) {

        List<Object> contactRecord = (List<Object>)JSON.deserializeUntyped(record);
        List<List_Member__c> insertListMember = new List<List_Member__c>();

        for (Object con : contactRecord) {
            Map<String, Object> data = (Map<String, Object>) con;
            List_Member__c newListMember = new List_Member__c();
            newListMember.List_Member__c = (Id)data.get('List_Member__c');
            newListMember.Column_2_Value__c = (String)data.get('Column_2_Value__c');
            newListMember.Column_3_Value__c = (String)data.get('Column_3_Value__c');
            newListMember.Column_4_Value__c = (String)data.get('Column_4_Value__c');
            newListMember.Column_5_Value__c = (String)data.get('Column_5_Value__c');
            newListMember.Column_6_Value__c = (String)data.get('Column_6_Value__c');
            newListMember.Column_7_Value__c = (String)data.get('Column_7_Value__c');
            newListMember.Column_1_Value__c = (String)data.get('Column_1_Value__c');
            newListMember.List__c = listId;
            newListMember.Activity_Status__c = (String)data.get('Activity_Status__c');
            newListMember.List_Member_Status__c = (String)data.get('List_Member_Status__c');

            insertListMember.add(newListMember);
        }

        if (insertListMember.size() > 0) {
            ListMembersDAO.newInstance().insertRecords(insertListMember, false, AccessLevel.SYSTEM_MODE);
        }


        return true;
    }
}