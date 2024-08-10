/**
 * @description Controller Class for LWC customHeaderContainer
*               Retriving Object List, List Member, User List Contributor Records
 *              Updating List Member Status
 * @see ../lwc/customHeaderContainer
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | December 20, 2023     | DEPP-6963              | Created file                                      |
      | kenneth.f.alsay                | January 15, 2024      | DEPP-6964              | Added updateListMemberStatus method               |
      | kenneth.f.alsay                | January 15, 2024      | DEPP-6953              | Added getListMembersByListIdAndStatus method      |
      | kenneth.f.alsay                | February 14, 2024     | DEPP-8040              | Added getAllListContributors method               |
 */
public with sharing class CustomHeaderContainerCtrl {

    /**
     * @description Fetches the List Members Object that are connected to Lists
     * @param recordId Record Id of Lists Object
     * @return Records of List<List_Member__c>
     */
    @AuraEnabled
    public static List<List_Member__c> getListMembers(Id recordId) {
        List<List_Member__c> listMembers = ListMembersDAO.newInstance().getexistingListMembersWithMatchingList(new Set<Id>{recordId}, new Set<Id>{}, 'USER_MODE');

        return listMembers;
    }

    /**
     * @description Fetches the List Members Object that are connected to Lists
     * @param engOppIds Record Id of Lists Engagement Opportunity
     * @return Records of List<List__c>
     */
    @AuraEnabled
    public static List<List__c> getListIdEngOpp(Id recordId) {
        List<List__c> listRecord = ListsDAO.newInstance().getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>{recordId}, AccessLevel.USER_MODE);

        return listRecord;
    }

    /**
     * @description Updates the List_Member__c records
     * @param listMembers List of List Member records to update
     */
    @AuraEnabled
    public static void updateListMemberStatus(List<List_Member__c> listMembers) {
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

    /**
     * @description Retrieve User has List Contributor
     * @param listId List Id
     * @param userId User Id
     */
    @AuraEnabled
    public static List<List_Contributor__c> getUserHasListContributor(Id listId, Id userId) {
        List<List_Contributor__c> listContributorRecord = ListContributorsDAO.newInstance().getListContributorByUserID(new Set<Id>{listId}, new Set<Id>{userId}, AccessLevel.USER_MODE);

        return listContributorRecord;
    }

    /**
     * @description Retrieve List Members that matches listId and status
     * @param listId List Id
     * @param status User Id
     */
    @AuraEnabled
    public static List<List_Member__c> getListMembersByListIdAndStatus(Id listId, String status) {
        List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance().getListMembersByListIdAndStatus(new Set<Id>{listId}, status, AccessLevel.USER_MODE);

        return listMemberRecords;
    }

    /**
     * @description Retrieve All List Contributors in List
     * @param listId List Id
     */
    @AuraEnabled
    public static List<List_Contributor__c> getAllListContributors(Id listId) {
        List<List_Contributor__c> listContributorRecord = ListContributorsDAO.newInstance().getAllListContributors(new Set<Id>{listId}, AccessLevel.USER_MODE);

        return listContributorRecord;
    }
}