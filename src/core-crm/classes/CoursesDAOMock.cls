/**
 * @description Mock DAO Class for Course Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                 |                                                     |
 */
@isTest
public inherited sharing class CoursesDAOMock extends DmlBaseMock implements ICoursesDAO {

	public Map<Id, hed__Course__c> courseMap;

    public Schema.SObjectType getSObjectType()
	{
		return hed__Course__c.SObjectType;
	}

	public CoursesDAOMock() {
		super(new Map<Id, hed__Course__c>(), Schema.hed__Course__c.SObjectType);
		this.courseMap = (Map<Id, hed__Course__c>) super.records;
	}
}
