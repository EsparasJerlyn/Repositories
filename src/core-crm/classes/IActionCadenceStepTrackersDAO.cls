/**
 * @description Interface for ActionCadenceStepTrackersDAO
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
public interface IActionCadenceStepTrackersDAO extends DmlInterface {
    List<ActionCadenceStepTracker> getActionCadenceStepTrackerForEmail(
        List<String> recordIds, 
        AccessLevel accessLevel
    );

    List<ActionCadenceStepTracker> getCadenceStepTrackersByTargetId(
        Set<String> targetIdsSet,
        AccessLevel accessLevel
    );
}