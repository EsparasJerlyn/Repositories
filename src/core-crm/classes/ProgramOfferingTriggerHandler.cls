/**
 * @description 
 * @see ProgramOfferingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 18, 2022        | DEPP-1687              | Created file                 |
 */

public without sharing class ProgramOfferingTriggerHandler implements Disableable, BeforeInsert, AfterInsert {
    public void beforeInsert(List<SObject> newItems) {
        SetOfferingName.setName(newItems); 
    }
    
       /**
       * @description performs afterinsert event for hed__Course_Offering object
       * @param newItems - List of Program_Offering__c.Trigger.new
       */
      public void afterInsert(Map<Id,SObject> newItems) {
        SendNewOfferingNotificationHelper.sendProgramOfferingAvailabiltyNotification((List<Program_Offering__c>) newItems.values());
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