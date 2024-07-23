/**
 * @description Helper Class for List Member Trigger
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                                             |
      | roy.nino.s.regala              | Feb 26, 2023          | DEPP-7882              | Updated logic to also consider on insert                 |
 */
public with sharing class ListMemberDuplicateCheckerHelper {
    public static void detectDuplicateListMembers(List<List_Member__c> newItems,Map<Id, List_Member__c> oldItems){
    	Set<String> duplicateCheckers = new Set<String>();

        Set<Id> listRecordIds = new Set<Id>();
        Set<Id> listMemberIds = new Set<Id>();
        List<List_Member__c> listMembersToCheck = new List<List_Member__c>();
        for(List_Member__c listItem: newItems){
            Boolean listItemNotNullListAndListMember = listItem.List_Member__c != null && listItem.List__c != null;
            Boolean listRecordCreated = oldItems == null;
            Boolean listRecordChanged = oldItems != null && oldItems.get(listItem.Id).List__c != listItem.List__c;
            Boolean listMemberRecordChanged = oldItems != null && oldItems.get(listItem.Id).List_Member__c != listItem.List_Member__c; 
           
            if( listItemNotNullListAndListMember &&
               (listRecordCreated || listRecordChanged || listMemberRecordChanged )
            ){
            listRecordIds.add(listItem.List__c);
            listMemberIds.add(listItem.List_Member__c);
            listMembersToCheck.add(listItem);
           }
        }
        
        List<List_Member__c> existingListMemberRecordsWithMatchingListIds = ListMembersDAO.newInstance().
            getexistingListMembersWithMatchingList(listRecordIds,listMemberIds,'SYSTEM_MODE');
        
        for(List_Member__c listItem : existingListMemberRecordsWithMatchingListIds){
            String listMemberIdPair = listItem.List_Member__c+'-'+listItem.List__c;
            duplicateCheckers.add(
                listMemberIdPair
            );
        }


        for( List_Member__c listMember: listMembersToCheck){
            if(                
                duplicateCheckers.contains(listMember.List_Member__c+'-'+listMember.List__c)
            ){
                listMember.List_Member__c.addError(ListMembersDAO.DUPLICATE_ERROR_MESSAGE);
            }
            duplicateCheckers.add(listMember.List_Member__c+'-'+listMember.List__c);
        }

    }

}