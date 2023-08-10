/**
 * @description DAO Class for Action Cadence Tracker Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                 |
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
            'SELECT  Id, TargetId ' +
                'FROM ActionCadenceTracker ' +
                'WHERE TargetId IN:targetIds ' +
                'AND ActionCadence.Name IN :cadenceName ' +
                'AND State = \'Running\' ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }
}
