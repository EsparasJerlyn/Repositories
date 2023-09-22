/**
 * @description Mock DAO Class for Course Offering Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-5483              | Created file                 |                                                     |
 */
@isTest
public inherited sharing class CourseOfferingsDAOMock extends DmlBaseMock implements ICourseOfferingsDAO {

	public Map<Id, hed__Course_Offering__c> courseOfferingsMap;

    public Schema.SObjectType getSObjectType()
	{
		return hed__Course_Offering__c.SObjectType;
	}

	public CourseOfferingsDAOMock() {
		super(new Map<Id, hed__Course_Offering__c>(), Schema.hed__Course_Offering__c.SObjectType);
		this.courseOfferingsMap = (Map<Id, hed__Course_Offering__c>) super.records;
	}
}
