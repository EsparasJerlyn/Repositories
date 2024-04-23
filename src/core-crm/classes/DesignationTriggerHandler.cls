/**
 * @description trigger handler class for object Designation
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | March 18, 2024        | DEPP-8200              | created file                 |
      | eugene.andrew.abuan            | April 17, 2024        | DEPP-8340              | Added Designation Endowment  |
 */
public with sharing class DesignationTriggerHandler implements Disableable, BeforeInsert {
    public void beforeInsert(List<Sobject> newItems) {
        CodeGeneratorService.generateCodeForDesignationGivingToCauseRecords((List<Designation__c>)newItems);
        CodeGeneratorService.generateCodeForDesignationEndowmentRecords((List<Designation__c>)newItems);
    }
    
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}