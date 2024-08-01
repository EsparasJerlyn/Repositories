/**
 * @description Mock DAO Class for ActionCadenceStepTracker Object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 4, 2023     | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public inherited sharing class ActionCadenceStepTrackersDAOMock extends DmlBaseMock implements IActionCadenceStepTrackersDAO {
    public Map<Id, ActionCadenceStepTracker> actionCadenceStepMap;
    public static final String ACST_MOCK_RECORD = '[{"attributes":{"type":"ActionCadenceStepTracker","url":"/services/data/v58.0/sobjects/ActionCadenceStepTracker/8HF9n00000007XlGAI"},' +
    '"Id":"8HF9n00000007XlGAI","ActionCadenceStepId":"8C89n0000000AozCAE","State":"InProgress","StepType":"SendAnEmail","ActionCadenceName":"Domestic","StepTitle":"SendSMS"}]';

    public ActionCadenceStepTrackersDAOMock() {
        super(new Map<Id, ActionCadenceStepTracker>(), Schema.ActionCadenceStepTracker.SObjectType);
        this.actionCadenceStepMap = (Map<Id, ActionCadenceStepTracker>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return ActionCadenceStepTracker.SObjectType;
    }

    public List<ActionCadenceStepTracker> getActionCadenceStepTrackerForEmail(
        List<String> recordIds,     
        AccessLevel accessLevel){
            List<ActionCadenceStepTracker> acStepTrackerList = new List<ActionCadenceStepTracker>();
            for(ActionCadenceStepTracker acStepTracker : actionCadenceStepMap.values()){
                if(recordIds.contains(acStepTracker.Id)){
                    acStepTrackerList.add(acStepTracker);
                }
            }
            
        if(acStepTrackerList.isEmpty()){
            return (List<ActionCadenceStepTracker>)JSON.deserialize(ACST_MOCK_RECORD, List<ActionCadenceStepTracker>.class);
        }

        return acStepTrackerList;
    }

    public List<ActionCadenceStepTracker> getCadenceStepTrackersByTargetId(
        Set<String> targetIdsSet,
        AccessLevel accessLevel
    ) {
        List<ActionCadenceStepTracker> cadenceStepTrackers = new List<ActionCadenceStepTracker>();
        for(ActionCadenceStepTracker cadenceStepTracker : actionCadenceStepMap.values()) {
            if(targetIdsSet.contains(cadenceStepTracker.TargetId)) {
                cadenceStepTrackers.add(cadenceStepTracker);
            }
        }
        
        return cadenceStepTrackers;
    }
}