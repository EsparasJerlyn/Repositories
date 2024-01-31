/**
 * @description Trigger handler class for LeadTrigger
 * 
 * @see ../triggers/LeadTrigger.trigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | angelika.j.s.galang            | May 19, 2022          | DEPP-1455              | Created file                  |
 *    | alexander.cadalin              | June 22, 2022         | DEPP-3056              | + before insert,update        |
 *    |                                |                       |                        | + detectDuplicatesInEmails    |
 *    |                                |                       |                        | - global dupes handlers       |
 *    | mark.j.mahilum                 | June 08,2023          | DEPP-5798              | added LeadService helper class|
 *    | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | added can nurture flag update | 
 *    | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added after insert            |
 *    | eccarius.munoz                 | October 6, 2023       | DEPP-5866              | Added handling for lead score |
 *    | roy.nino.s.regala              | November 1, 2023      | DEPP-7105              | Updated creation of marketing |
 *    | roy.nino.s.regala              | November 1, 2023      | DEPP-7105              | segmentation to future        |
 */

public without sharing class LeadTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate {
    /**
     * @description performs beforeInsert event for Lead object
     * @param newItems - List of Lead.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        LeadDuplicatesHelper.detectDuplicatesInEmails((List<Lead>) newItems, null);
    }

    /**
     * @description performs beforeUpdate event for Lead object
     * @param newItems - Map of Lead.Trigger.newMap
     * @param oldItems - Map of Lead.Trigger.oldMap
     */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, Sobject> oldItems
    ) {
        LeadDuplicatesHelper.detectDuplicatesInEmails((List<Lead>) newItems.values(), (Map<Id, Lead>) oldItems);
        LeadWithCaseHelper.updateCaseParentToContact((Map<Id, Lead>) newItems, (Map<Id, Lead>) oldItems);
        LeadService.updateLeadStatus((List<Lead>) newItems.values());
    }

    /**
     * @description performs afterInsert event for Lead object
     * @param newItems - List of Lead.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        LeadService.createLeadScoreDetailRecord((List<Lead>) newItems.values());
        LeadService.createMarketingSegmentationForLeads(newItems.keySet());
        LeadLeadScoreHelper.processLeadScoreCalculation((List<Lead>) newItems.values(), null);
    }

  /**
   * @description performs afterUpdate event for Lead object
   * @param newItems - Map of Lead.Trigger.newMap
   * @param oldItems - Map of Lead.Trigger.oldMap
   */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        LeadService.getLeadCalculatedCadence((List<Lead>) newItems.values(), (Map<Id, Lead>) oldItems);
        LeadLeadScoreHelper.processLeadScoreCalculation((List<Lead>) newItems.values(), (Map<Id, Lead>) oldItems);
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