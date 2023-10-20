/**
 * @description Case object trigger handler class
 * @see CaseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | Sept 09, 2023         | DEPP-6421              | Created file                                     |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added method for before insert                   |
 */
public with sharing class CaseTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert {
    
    public static Boolean isRunning = false;

    /**
    * @description beforeInsert trigger event
    * @param newItems - List of Case.Trigger.new
    */
    public void beforeInsert(List<SObject> newItems) { 
        CaseTriggerHelper.caseRecordByMobileMatching((List<Case>) newItems);
        CaseTriggerHelper.updateCaseAutoPriorityAssignment((List<Case>) newItems);
    }

   /**
    * @description afterInsert trigger event
    * @param newItems - Map<Id, SObject> of Case.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {

        if(!isRunning ){
            isRunning = true;
            CaseTriggerHelper.matchExistingContactOrLeadToCase((List<Case>) newItems.values());
            CaseTriggerHelper.handleAutoPriorityAssignedCase((List<Case>) newItems.values());
            CaseLeadScoreHelper.processLeadScoreCalculation((List<Case>) newItems.values(), null);
        }
    }

    /**
     * @description before update
     * @param newItems - List of MarketingSegmentation.Trigger.new
     * @param oldItems - List of MarketingSegmentation.Trigger.old
     */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        if(!isRunning){
            isRunning = true;
            CaseLeadScoreHelper.processLeadScoreCalculation(
                (List<Case>) newItems.values(), 
                (Map<Id, Case>) oldItems
            );
        }
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