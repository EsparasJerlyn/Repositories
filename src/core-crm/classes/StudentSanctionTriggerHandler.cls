/**
 * @description Student Sanction object trigger handler class
 * @see StudentSanctionTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | April 16, 2024        | DEPP-7984    | Created File
*/ 
public with sharing class StudentSanctionTriggerHandler implements Disableable, BeforeInsert{

    /**
    * @description performs afterInsert event for Student Sanction object
    * @param newItems - Map of StudentSanction.Trigger.newMap
    */
    public void beforeInsert (List<SObject> newItems) {
        StudentSanctionTriggerHelper.processDuplicateSanctionIntegration(newItems);
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