/**
 * @description Interface for WorkTypesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | nicole.genon                   | November 22, 2023     | DEPP-7259              | Created file                 |
      |                                |                       |                        |                              |
 */
public interface IWorkTypesDAO extends DmlInterface{
    List<WorkType> getWorkTypesBySetIds(Set<Id> workTypeIds, AccessLevel accessLevel);
    List<WorkType> getWorkTypesBySetNames(Set<String> workTypeNames, AccessLevel accessLevel);
}