/**
 * @description DAO class for WorkType
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
public with sharing class WorkTypesDAO extends DmlBase implements IWorkTypesDAO{

    //Add Template Names here
    public static final String INTERNATIONAL_WORK_TYPE = 'International Phone Calls';
    public static final String DOMESTIC_WORK_TYPE = 'Domestic Phone Calls';

    public Schema.SObjectType getSObjectType(){
		return WorkType.SObjectType;
	}

    public static IWorkTypesDAO newInstance(){
		return (IWorkTypesDAO) ImplementationSelector.DAO.newInstance(WorkType.SObjectType);
	}

    public List<WorkType> getWorkTypesBySetIds(Set<Id> idSet, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, Name ' + 
            'FROM WorkType ' +
            'WHERE Id IN: idSet', accessLevel
        );
    }

    public List<WorkType> getWorkTypesBySetNames(Set<String> workTypeNames, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id, Name ' + 
            'FROM WorkType ' +
            'WHERE Name IN :workTypeNames', accessLevel
        );
    }
}