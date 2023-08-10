/**
 * @description Mock DAO Class for Action Cadence Tracker Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                 |
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
}
