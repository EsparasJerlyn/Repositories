/**
 * @description Controller Class for List Members in List
 * @see ../lwc/customHeaderDatatable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | December 20, 2023     | DEPP-6963              | Created file                                      |
      | kenneth.f.alsay                | January 15, 2024      | DEPP-6964              | Added updateListMemberStatus method               |
 */
public with sharing class CustomHeaderDatatableCtrl {

    /**
     * @description Fetches the List Members Object that are connected to Lists
     * @param ListId Record Id of Lists Object
     * @return Records of List<List_Member__c>
     */
    @AuraEnabled
    public static List<List_Member__c> getListMembers(Id listId) {
        List<List_Member__c> listMembers = ListMembersDAO.newInstance().getexistingListMembersWithMatchingList(new Set<Id>{listId}, new Set<Id>{}, 'USER_MODE');
        return listMembers;
    }
    /**
     * @description Updates the List_Member__c records
     * @param listMembers List of List Member records to update
     */
    @AuraEnabled
    public static void updateListMemberStatus(List<List_Member__c> listMembers){
        List<List_Member__c> listMembersToUpdate = new List<List_Member__c>();
        for(List_Member__c listMember : listMembers){
            listMembersToUpdate.add(
                new List_Member__c(
                	Id = listMember.Id,
                	List_Member_Status__c = listMember.List_Member_Status__c)
             );
        } 
        ListMembersDAO.newInstance().updateRecords(listMembersToUpdate, false, AccessLevel.USER_MODE);       
    }
}