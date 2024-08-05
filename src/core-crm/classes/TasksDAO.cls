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
      | mark.j.mahilum                 | Nov 09, 2023          | DEPP-7110              | Added method getCompletedSMSTask               |
      | johanna.a.gibas                | Nov 16, 2023          | DEPP-7118              | Replaced Closed - Contacted with               |
      |                                |                       |                        |     Closed - No Further Action Required        |
      | johanna.a.gibas                | Jan 15, 2024          | DEPP-7596              | Added WhoId in getCompletedTasksByTargetId     |
      | mark.j.mahilum                 | Jan 25, 2024          | DEPP-7675              | Added FOR UPDATE to delete and update task that|
      |                                |                       |                        | is getting unable to lock row issue            |
      | eugene.andrew.abuan            | August 03, 2024       | DEPP-9691              | Added getTaskByCompeltedCadence                |
 */
public inherited sharing class TasksDAO extends DmlBase implements ITasksDAO {

    public static final String CLOSED_UNSUCCESSFUL_CALL_STATUS = 'Closed - Unsuccessful Call';
    public static final String CLOSED_FOLLOW_UP_STATUS = 'Closed - Follow Up';
    public static final String CLOSED_NO_FURTHER_ACTION_REQUIRED_STATUS = 'Closed - No Further Action Required';
    public static final Id SMS_RECTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();   

    public static final Set<String> taskStatuses = new Set<String>{
        CLOSED_UNSUCCESSFUL_CALL_STATUS,
        CLOSED_FOLLOW_UP_STATUS,
        CLOSED_NO_FURTHER_ACTION_REQUIRED_STATUS
    };    

    public static ITasksDAO newInstance() {
        return (ITasksDAO) ImplementationSelector.DAO.newInstance(Task.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public List<Task> getCompletedTasksByTargetId(
        Set<String> targetIds,
        Set<String> actionCadenceIds
    ) {
        return [
            SELECT Id,ActionCadenceStepTracker.TargetId, CompletedDateTime, Status, WhoId, 
                   ActionCadenceStepTracker.ActionCadenceName, ActionCadenceStepTracker.CompletionDate, ActionCadenceStepTracker.CreatedDate
            FROM Task
            WHERE
                ActionCadenceStepTracker.TargetId IN: targetIds
                AND ActionCadenceStepTracker.ActionCadenceTrackerId IN: actionCadenceIds
                AND Status IN: taskStatuses
            WITH SYSTEM_MODE
            FOR UPDATE
        ];
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public List<Task> getCompletedSMSTasksByActionCadenceStepTrackerId(
        Set<String> actionCadenceStepTrackerIds
    ) {
        return [
            SELECT Id, Status, Subject, Type, WhoId, ActionCadenceStepTrackerId 
            FROM Task
            WHERE
                ActionCadenceStepTrackerId IN: actionCadenceStepTrackerIds
                AND Status ='Completed'
                AND IsClosed = TRUE
                AND ActionCadenceStepTracker.StepType = 'CreateTask'
            WITH SYSTEM_MODE
            FOR UPDATE
        ];
    }

    public List<Task> getTaskByCompeltedCadence(
        Set<Id> completedCadenceIdSet,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Completed_Cadence__c, Status  ' +
            'FROM Task ' +
            'WHERE Completed_Cadence__c IN: completedCadenceIdSet ',
            accessLevel        
        );
    }
}