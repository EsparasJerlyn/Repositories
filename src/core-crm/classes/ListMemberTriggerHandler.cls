/**
* @description TriggerHandler Class for ListMemberTrigger
* @see ..ListMemberTrigger
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | carl.alvin.cabiles             | September 15, 2023    | DEPP-6410              | Created file                                                                  |

*/
public with sharing class ListMemberTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate {
    /**
     * 
     * @param newItems - List of List_Member__c.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        ListMemberDuplicateCheckerHelper.detectDuplicateListMembers((List<List_Member__c>) newItems,null);
    }

    /**
     * 
     * @param newItems - List of List_Member__c.Trigger.new
     * @param oldItems - List of List_Member__c.Trigger.old
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
       ListMemberDuplicateCheckerHelper.detectDuplicateListMembers((List<List_Member__c>) newItems.values(),(Map<Id, List_Member__c>) oldItems);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}