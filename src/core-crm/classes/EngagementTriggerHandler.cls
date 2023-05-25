/**
 * @description trigger handler class for object Engagement
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 12, 2023          | DEPP-5594              | created file
 */
public with sharing class EngagementTriggerHandler implements Disableable, BeforeInsert {
    public void beforeInsert(List<Sobject> newItems) {
        CodeGeneratorService.generateEngagementCodeForEngagementRecords((List<Engagement__c>)newItems);
    }
    
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}