/**
 * @description DAO class for ActionCadenceStepTracker
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 4, 2023     | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
      | mark.j.mahilum                 | Oct 05, 2023          | DEPP-6781              | Added new field DueDateTime  |
 */
public with sharing class ActionCadenceStepTrackersDAO extends DmlBase implements IActionCadenceStepTrackersDAO {
    
  private static final String STATE_ACTIVE = 'Active';
  private static final Set<String> STEP_TYPE = new Set<String>{'SendAnEmail','CreateTask'};

  public Schema.SObjectType getSObjectType(){
    return ActionCadenceStepTracker.SObjectType;
  }

  public static IActionCadenceStepTrackersDAO newInstance(){
		return (IActionCadenceStepTrackersDAO) ImplementationSelector.DAO.newInstance(ActionCadenceStepTracker.SObjectType);
	}

  public List<ActionCadenceStepTracker> getActionCadenceStepTrackerForEmail(List<String> recordIds, AccessLevel accessLevel) {
    return Database.query(
        'SELECT Id, ActionCadenceStepId, ActionCadenceName, TargetId, StepType, StepTitle, ActionCadenceStep.TemplateId, DueDateTime, ActionCadenceTracker.OwnerId ' + 
        'FROM ActionCadenceStepTracker ' + 
        'WHERE Id IN: recordIds ' + 
        'AND State =: STATE_ACTIVE ' + 
        'AND StepType IN: STEP_TYPE', accessLevel
    );
  }  

  public List<ActionCadenceStepTracker> getCadenceStepTrackersByTargetId(
    Set<String> targetIdsSet,
    AccessLevel accessLevel
  ) {
    if(targetIdsSet.isEmpty() || targetIdsSet == null || accessLevel == null) {
      return new List<ActionCadenceStepTracker>();
    }
    return Database.query(
      'SELECT Id, ActionCadenceName, TargetId FROM ActionCadenceStepTracker WHERE TargetId IN :targetIdsSet', 
      accessLevel
    );
  }
}