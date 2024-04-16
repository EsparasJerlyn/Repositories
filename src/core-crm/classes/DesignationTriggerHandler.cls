/**
 * @description trigger handler class for object Designation
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | March 18, 2024        | DEPP-8200              | created file
 */
public with sharing class DesignationTriggerHandler implements Disableable, BeforeInsert {
    public void beforeInsert(List<Sobject> newItems) {
        CodeGeneratorService.generateCodeForDesignationRecords((List<Designation__c>)newItems);
    }
    
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}