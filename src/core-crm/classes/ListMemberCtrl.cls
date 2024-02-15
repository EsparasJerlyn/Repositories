/**
 * @description Controller Class for ListMemberCtrlTest LWC
 * @see ../lwc/ListMemberCtrlTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
 *    | kenneth.f.alsay                | January 12, 2024      | DEPP-6964              | Created file                                      |
 *    | kenneth.f.alsay                | February 7, 2024      | DEPP-6953              | Updated updateListMemberStatus for Engage tab     |
 */
public class ListMemberCtrl {
	/**
    * @description Updates the List_Member_Status__c of the selected List Members from customHeaderDatatable
    * @param listMembers - List of List Members selected
    * @param status - New List Member Status 
    */
    @AuraEnabled
    public static void updateListMemberStatus(List<List_Member__c> listMembers, String status, Boolean isEngage){      
        List<List_Member__c> listMembersToUpdate = new List<List_Member__c>();
        for(List_Member__c listMember : listMembers){
            List_Member__c newListMember = new List_Member__c();
            newListMember.Id = listMember.Id;
            if(isEngage){
                newListMember.Activity_Status__c = status;
            }else{
                newListMember.List_Member_Status__c = status;
            }
            listMembersToUpdate.add(newListMember);
        }       
        ListMembersDAO.newInstance().updateRecords(listMembersToUpdate, false, AccessLevel.USER_MODE);       
    }
}