/**
 * @description Application object trigger handler class
 * @see ApplicationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------------------|
      | mark.j.mahilum            | June 19,2023          | DEPP-5846    | Created file                                                          |
      | mark.j.mahilum            | July 25, 2023         | DEPP-6106    | Added new method setCanNurtureOnContactOrLeadBasedOnApplicationStatus |
      | julie.jane.alegre         | September 19, 2023    | DEPP-6667    | Added new method updateContactWhenQTACAppIsInactive                   |
      | eccarius.munoz            | October 05, 2023      | DEPP-5866    | Added method to reset lead score of linked contact/lead               |
      | alexander.cadalin         | Oct 13, 2023          | DEPP-6890    | Removed isRunning flag
*/
public with sharing class ApplicationTriggerHandler implements Disableable, BeforeInsert,  AfterInsert, AfterUpdate {
    /**
     * @description beforeInsert trigger event
     * @param newItems - List of hed__Application__c.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        ApplicationTriggerHelper.updateCalculatedDateOnSamsApplicationRecords((List<hed__Application__c>) newItems);
}

    /**
     * @description afterInsert trigger event
     * @param newItems - List of hed__Application__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        ApplicationService.executeMatchingRule((List<hed__Application__c>) newItems.values(), null);
        ApplicationTriggerHelper.getContactOnApplication((List<hed__Application__c>) newItems.values(),null);
        ApplicationTriggerHelper.createAddressesForMatchingQTACApplicant(newItems, null);
        ApplicationTriggerHelper.updateRelatedRecords(newItems, null);
    }

    /**
     * @description performs beforeUpdate event for hed__Application__c object
     * @param newItems - Map of hed__Application__c.Trigger.newMap
     * @param oldItems - Map of hed__Application__c.Trigger.oldMap
     */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        ApplicationService.executeMatchingRule((List<hed__Application__c>) newItems.values(), (Map<Id, hed__Application__c>) oldItems);
        ApplicationTriggerHelper.getContactOnApplication((List<hed__Application__c>) newItems.values(),(Map<Id, hed__Application__c>) oldItems);
        ApplicationTriggerHelper.createAddressesForMatchingQTACApplicant(newItems, oldItems);
        ApplicationTriggerHelper.updateRelatedRecords(newItems, oldItems);
        ApplicationTriggerHelper.updateContactWhenQTACAppIsInactive((List<hed__Application__c>) newItems.values(), (Map<Id, hed__Application__c>) oldItems);
        ApplicationTriggerHelper.resetLeadScore((List<hed__Application__c>) newItems.values(), (Map<Id, hed__Application__c>) oldItems);
    }

    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}