/**
 * @description ActionCadenceStepTrackerChangeEvent object trigger handler class
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.majilum                   | September 4,2023      | DEPP-6138              | Created file                 |
      | eccarius.munoz                 | September 4,2023      | DEPP-6138              | Added to trigger handler     |
 */
public with sharing class ActionCadenceStepTrackerTriggerHandler implements Disableable,  AfterInsert {
    
    public void afterInsert(Map<Id, SObject> newItems){
        ActionCadenceStepTrackerTriggerHelper.insertCommunicationQueue((List<ActionCadenceStepTrackerChangeEvent>) newItems.values());
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}