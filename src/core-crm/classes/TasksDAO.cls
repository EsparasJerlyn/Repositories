/**
 * @description DAO Class for Task Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                   |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new method getCompletedTasksByTargetId   |
      | mark.j.mahilum                 | Sept 19, 2023         | DEPP-6524              | Updated getCompletedTasksByTargetId to include |
      |                                |                       |                        | follow-up status                               |
 */
public inherited sharing class TasksDAO extends DmlBase implements ITasksDAO {

    public static final Set<String> taskStatuses = new Set<String>{
        'Closed - Unsuccessful Call',
        'Closed - Follow Up'
    };    

    public static ITasksDAO newInstance() {
        return (ITasksDAO) ImplementationSelector.DAO.newInstance(Task.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }

    public List<Task> getCompletedTasksByTargetId(
        Set<String> targetIds,
        Set<String> actionCadenceIds
    ) {
        return [//NOPMD
            SELECT Id,ActionCadenceStepTracker.TargetId, CompletedDateTime, Status, 
                   ActionCadenceStepTracker.ActionCadenceName
            FROM Task
            WHERE
                ActionCadenceStepTracker.TargetId IN: targetIds
                AND ActionCadenceStepTracker.ActionCadenceTrackerId IN: actionCadenceIds
                AND Status IN: taskStatuses
            WITH SYSTEM_MODE
            ORDER BY CompletedDateTime DESC
        ];
    }
}