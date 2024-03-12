/**
 * @description Mock DAO Class for Plan Activity Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                 |
      | jerlyn.esparas                 | February 29, 2024     | DEPP-7890              |                              |
*/
@isTest
public inherited sharing class PlanActivitiesDAOMock extends DmlBaseMock implements IPlanActivitiesDAO {
	public Map<Id, Plan_Activity__c> planActivitiesMap;
    public Schema.SObjectType getSObjectType()
	{
		return Plan_Activity__c.SObjectType;
	}
	public PlanActivitiesDAOMock() {
		super(new Map<Id, Plan_Activity__c>(), Schema.Plan_Activity__c.SObjectType);
		this.planActivitiesMap = (Map<Id, Plan_Activity__c>) super.records;
	}

	public List<Plan_Activity__c> getPlanActivityRecordsWithOpportunityIds(Set<Id> opptyIds, AccessLevel accessLevel) {
        List<Plan_Activity__c> planActivityList = new List<Plan_Activity__c>();

        for (Plan_Activity__c record : planActivitiesMap.values()) {
            if (opptyIds.contains(record.Opportunity__c)) {
                planActivityList.add(record);
            }
        }
		return planActivityList;
	}
}