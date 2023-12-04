/**
 * @description Mock DAO Class for WorkType Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | nicole.genon                   | November 27, 2023     | DEPP-7259              | Created File                       |
 */
@isTest
public inherited sharing class WorkTypesDAOMock extends DmlBaseMock implements IWorkTypesDAO{
    public Map<Id, WorkType> workTypeMap;

    public WorkTypesDAOMock() {
        super(new Map<Id, WorkType>(), Schema.WorkType.SObjectType);
        this.workTypeMap = (Map<Id, WorkType>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return WorkType.SObjectType;
    }

    public List<WorkType> getWorkTypesBySetIds(Set<Id> idSet, AccessLevel accessLevel) {
        List<WorkType> workTypeList = new List<WorkType>();

        for (WorkType record : workTypeMap.values()) {
            if (idSet.contains(record.Id)) {
                workTypeList.add(record);
            }
        }

        return workTypeList;
    }

    public List<WorkType> getWorkTypesBySetNames(Set<String> workTypeNames, AccessLevel accessLevel) {
        List<WorkType> workTypeList = new List<WorkType>();

        for (WorkType record : workTypeMap.values()) {
            if (workTypeNames.contains(record.Name)) {
                workTypeList.add(record);
            }
        }

        return workTypeList;
    }
}