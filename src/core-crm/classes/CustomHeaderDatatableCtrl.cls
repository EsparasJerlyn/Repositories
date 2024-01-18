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
      | nicole.genon                   | January 18, 2023      | DEPP-6953              | Added getEngagementOpportunityListId method       |
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
     * @description Fetches the List Members Object that are connected to Lists
     * @param engagementOpportunityId Record Id of Lists Object
     * @return Records of List<List_Member__c>
     */
    @AuraEnabled
    public static Id getEngagementOpportunityListId(Id engagementOpportunityId) {
        List<List__c> lists = ListsDAO.newInstance().getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>{engagementOpportunityId}, AccessLevel.USER_MODE);

        return lists.get(0).Id;
    }
}