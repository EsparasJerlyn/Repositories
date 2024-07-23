/**
 * @description DAO Class for Action Cadence Tracker Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                                   |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new query methods getCompletedACTrackerById              |
      | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Added new field in getRunningACTrackerByTargetIdAndCadenceName |
 */
public inherited sharing class ActionCadenceTrackersDAO extends DmlBase implements IActionCadenceTrackersDAO {
    public static IActionCadenceTrackersDAO newInstance() {
        return (IActionCadenceTrackersDAO) ImplementationSelector.DAO.newInstance(
            ActionCadenceTracker.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return ActionCadenceTracker.SObjectType;
    }

    public List<ActionCadenceTracker> getRunningACTrackerByTargetIdAndCadenceName(
        Set<Id> targetIds,
        Set<String> cadenceName,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, TargetId, ActionCadence.Name ' +
                'FROM ActionCadenceTracker ' +
                'WHERE TargetId IN:targetIds ' +
                'AND ActionCadence.Name IN :cadenceName ' +
                'AND State = \'Running\' ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }
    
    public List<ActionCadenceTracker> getCompletedACTrackerById(
        Set<String> recordIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, TargetId, ActionCadence.Name, CompletionReason ' +
            'FROM ActionCadenceTracker ' +
            'WHERE Id IN:recordIds ' +
            'AND State = \'Complete\' ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
}

