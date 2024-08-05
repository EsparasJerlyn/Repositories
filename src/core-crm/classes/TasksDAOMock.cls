/**
 * @description Mock DAO Class for Action Cadence Tracker Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                      |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new mock method getCompletedTasksByTargetId |
      | eugene.andrew.abuan            | August 03, 2024       | DEPP-9691              | Added getTaskByCompeltedCadence                |

 */
@isTest
public inherited sharing class TasksDAOMock extends DmlBaseMock implements ITasksDAO {
    public Map<Id, Task> taskMap;

    public Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }

    public TasksDAOMock() {
        super(new Map<Id, Task>(), Schema.Task.SObjectType);
        this.taskMap = (Map<Id, Task>) super.records;
    }

    public List<Task> getCompletedTasksByTargetId(
        Set<String> targetIds,
        Set<String> actionCadenceIds
    ) {
        List<Task> taskList = new List<Task>();
        for (Task ts : taskMap.values()) {
            if (
                targetIds.contains(ts.ActionCadenceStepTracker.TargetId)
            ) {
                taskList.add(ts);
            }
        }
        return taskList;
    }
    
    public List<Task> getCompletedSMSTasksByActionCadenceStepTrackerId(
        Set<String> actionCadenceStepTrackerIds
    ) {
        List<Task> taskList = new List<Task>();
        for (Task ts : taskMap.values()) {
            if (
                actionCadenceStepTrackerIds.contains(ts.ActionCadenceStepTrackerId)
            ) {
                taskList.add(ts);
            }
        }
        return taskList;
    }


    public List<Task> getTaskByCompeltedCadence(
        Set<Id> completedCadenceIdSet,
        AccessLevel accessLevel
    ) {
        List<Task> taskList = new List<Task>();
        for (Task ts : taskMap.values()) {
            if (
                completedCadenceIdSet.contains(ts.ActionCadenceStepTrackerId)
            ) {
                taskList.add(ts);
            }
        }
        return taskList;
    }

}
