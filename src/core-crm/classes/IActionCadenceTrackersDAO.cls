/**
 * @description Interface for Action Cadence Tracker
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 8, 2023           | DEPP-5677                | created file                 |
 */
public interface IActionCadenceTrackersDAO extends DmlInterface {
    List<ActionCadenceTracker> getRunningACTrackerByTargetIdAndCadenceName(
        Set<Id> targetIds,
        Set<String> cadenceName,
        String accessLevel
    );
    List<ActionCadenceTracker> getCompletedACTrackerById(
        Set<String> recordIds,
        String accessLevel
    );
}
