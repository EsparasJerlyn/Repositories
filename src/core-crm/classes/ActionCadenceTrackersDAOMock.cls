/**
 * @description Mock DAO Class for Action Cadence Tracker Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                    |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added mock method for getCompletedACTrackerById |
 */
@isTest
public inherited sharing class ActionCadenceTrackersDAOMock extends DmlBaseMock implements IActionCadenceTrackersDAO {
    public Map<Id, ActionCadenceTracker> actionCadenceTrackerMap;

    public Schema.SObjectType getSObjectType() {
        return ActionCadenceTracker.SObjectType;
    }

    public ActionCadenceTrackersDAOMock() {
        super(new Map<Id, ActionCadenceTracker>(), Schema.ActionCadenceTracker.SObjectType);
        this.actionCadenceTrackerMap = (Map<Id, ActionCadenceTracker>) super.records;
    }

    public List<ActionCadenceTracker> getRunningACTrackerByTargetIdAndCadenceName(
        Set<Id> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    ) {
        List<ActionCadenceTracker> actionCadenceList = new List<ActionCadenceTracker>();
        for (ActionCadenceTracker acTracker : actionCadenceTrackerMap.values()) {
            if (
                targetIds.contains(acTracker.TargetId) &&
                acTracker.State == 'Running'
            ) {
                actionCadenceList.add(acTracker);
            }
        }
        return actionCadenceList;
    }
    
    public List<ActionCadenceTracker> getCompletedACTrackerById(
        Set<String> recordIds,
        String accessLevel
    ) {
        List<ActionCadenceTracker> actionCadenceList = new List<ActionCadenceTracker>();
        for (ActionCadenceTracker acTracker : actionCadenceTrackerMap.values()) {
            if (
                recordIds.contains(acTracker.Id) &&
                acTracker.State == 'Complete'
            ) {
                actionCadenceList.add(acTracker);
            }
        }
        return actionCadenceList;
    }
}
