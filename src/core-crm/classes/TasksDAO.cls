/**
 * @description DAO Class for Task Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | roy.nino.s.regala              | Aug 08, 2023          | DEPP-5677              | Created file                                 |
 */
public inherited sharing class TasksDAO extends DmlBase implements ITasksDAO {

    public static ITasksDAO newInstance() {
        return (ITasksDAO) ImplementationSelector.DAO.newInstance(Task.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }
}