/**
 * @description  Mock DAO Class for Assessment__c Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 08, 2024          | DEPP-8487              | Created file                 |
 */

@isTest
public inherited sharing class AssessmentsDAOMock extends DmlBaseMock implements IAssessmentsDAO {

	public Map<Id, Assessment__c> assessmentMap;

    public Schema.SObjectType getSObjectType()
	{
		return Assessment__c.SObjectType;
	}

	public AssessmentsDAOMock() {
		super(new Map<Id, Assessment__c>(), Schema.Assessment__c.SObjectType);
		this.assessmentMap = (Map<Id, Assessment__c>) super.records;
	}
}