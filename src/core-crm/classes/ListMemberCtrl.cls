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
 *    |                                |                       |                        |                                                   |
 */
public class ListMemberCtrl {
	/**
    * @description Updates the List_Member_Status__c of the selected List Members from customHeaderDatatable
    * @param listMembers - List of List Members selected
    * @param status - New List Member Status 
    */
    @AuraEnabled
    public static void updateListMemberStatus(List<List_Member__c> listMembers, String status){        
        for(List_Member__c listMember : listMembers){
            listMember.List_Member_Status__c = status;
        }
        ListMembersDAO.newInstance().updateRecords(listMembers, false, AccessLevel.SYSTEM_MODE);       
    }
}