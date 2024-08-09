/**
 * @description Interface for Task
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 8, 2023           | DEPP-5677              | created file                 |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new list<task>         |
      | eugene.andrew.abuan            | July 23, 2024         | DEPP-8255              | Added get task by CC         |
 */
public interface ITasksDAO extends DmlInterface {
     List<Task> getCompletedTasksByTargetId(
          Set<String> targetIds,
          Set<String> actionCadenceIds
     );
     List<Task> getCompletedSMSTasksByActionCadenceStepTrackerId(
          Set<String> actionCadenceStepTrackerIds
     );

     List<Task> getTaskByCompeltedCadence(
          Set<Id> completedCadenceIdSet,
          AccessLevel accessLevel
      );
}
