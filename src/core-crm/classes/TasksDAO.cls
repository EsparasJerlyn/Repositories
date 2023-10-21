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
      | johanna.a.gibas                | Oct 16, 2023          | DEPP-6855              | Added Closed - Contacted in taskStatuses,      |
      |                                |                       |                        | used string literals for Statuses, and         |
      |                                |                       |                        | updated getCompletedTasksByTargetId to include |
      |                                |                       |                        | ACST CompletionDate and ACST CreatedDate       |
 */
public inherited sharing class TasksDAO extends DmlBase implements ITasksDAO {

    public static final String CLOSED_UNSUCCESSFUL_CALL_STATUS = 'Closed - Unsuccessful Call';
    public static final String CLOSED_FOLLOW_UP_STATUS = 'Closed - Follow Up';
    public static final String CLOSED_CONTACTED_STATUS = 'Closed - Contacted';    

    public static final Set<String> taskStatuses = new Set<String>{
        CLOSED_UNSUCCESSFUL_CALL_STATUS,
        CLOSED_FOLLOW_UP_STATUS,
        CLOSED_CONTACTED_STATUS
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
                   ActionCadenceStepTracker.ActionCadenceName, ActionCadenceStepTracker.CompletionDate, ActionCadenceStepTracker.CreatedDate
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