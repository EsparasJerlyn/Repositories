/**
 * @description Mock DAO Class for Plan Activity Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                                   |
      | jerlyn.esparas                 | February 29, 2024     | DEPP-7890              |                                                |
      | nicole.genon                   | March 7, 2024         | DEPP-7922              | Added getPlanActivityRecordsWithStewardshipIds |
*/
@isTest
public inherited sharing class PlanActivitiesDAOMock extends DmlBaseMock implements IPlanActivitiesDAO {
	public Map<Id, Plan_Activity__c> planActivitiesMap;

    public Schema.SObjectType getSObjectType(){
		return Plan_Activity__c.SObjectType;
	}

	public PlanActivitiesDAOMock() {
		super(new Map<Id, Plan_Activity__c>(), Schema.Plan_Activity__c.SObjectType);
		this.planActivitiesMap = (Map<Id, Plan_Activity__c>) super.records;
	}

	public List<Plan_Activity__c> getPlanActivityRecordsWithStewardshipIds(
        Set<Id> stewardshipIds,
        AccessLevel accessLevel
    ) {
        List<Plan_Activity__c> planActivityList = new List<Plan_Activity__c>();

        if(!stewardshipIds.isEmpty()){
            for (Plan_Activity__c record : planActivitiesMap.values()) {
                if (stewardshipIds.contains(record.Stewardship__c)) {
                    planActivityList.add(record);
                }
            }
        }

        return planActivityList;
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