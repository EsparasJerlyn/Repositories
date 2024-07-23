/**
 * @description Controller Class for LWC addFromExistingList
 * @see ../lwc/addFromExistingList
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | December 31, 2023     | DEPP-7004              | Created file                                      |
      |                                |                       |                        |                                                   |
 */
public with sharing class AddFromExistingListCtrl {
    /**
     * @description Fetches the List Members Object that are connected to Lists
     * @param filterString to filter
     * @param recordId Record Id of Lists Object
     * @return Records of List<List>
     */
    @AuraEnabled
    public static List<List__c> getSearchedLists(Id recordId, String filterString){
        List<List__c> listRecord =  ListsDAO.newInstance().getListByRecordIdName(recordId, filterString, AccessLevel.USER_MODE);

        return listRecord;
    }
}