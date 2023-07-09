/**
 * @description Mock DAO Class for Milestone Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 06, 2023         | DEPP-5457              | Created file
 */
@isTest
public inherited sharing class MilestonesDAOMock extends DmlBaseMock implements IMilestonesDAO {

	public Map<Id, Milestone__c> milestonesMap;

    public Schema.SObjectType getSObjectType()
	{
		return Milestone__c.SObjectType;
	}

	public MilestonesDAOMock() {
		super(new Map<Id, Milestone__c>(), Schema.Milestone__c.SObjectType);
		this.milestonesMap = (Map<Id, Milestone__c>) super.records;
	}
}