/**
 * @description Controller Class for List Members in List
 * @see ../lwc/customHeaderContainer
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | December 20, 2023     | DEPP-6963              | Created file                                      |
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
}