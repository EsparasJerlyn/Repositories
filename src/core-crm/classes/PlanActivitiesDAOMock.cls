/**
 * @description Mock DAO Class for Plan Activity Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                               |
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
}