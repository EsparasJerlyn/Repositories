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
public with sharing class CaseTriggerHandler implements Disableable, BeforeInsert, AfterInsert {
    
    public static Boolean isRunning = false;

    /**
    * @description beforeInsert trigger event
    * @param newItems - List of Case.Trigger.new
    */
    public void beforeInsert(List<SObject> newItems) { 
        CaseTriggerHelper.caseRecordByMobileMatching((List<Case>) newItems);
    }
    
   /**
    * @description afterInsert trigger event
    * @param newItems - Map<Id, SObject> of Case.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
    
        if(!isRunning ){
            isRunning = true; 
            CaseTriggerHelper.matchExistingContactOrLeadToCase((List<Case>) newItems.values());           
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