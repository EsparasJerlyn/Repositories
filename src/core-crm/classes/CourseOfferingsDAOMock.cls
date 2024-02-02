/**
 * @description Mock DAO Class for Course Offering Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
      |--------------------------------|-----------------------|------------------------|----------------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-5483              | Created file                           |
	  | kenneth.f.alsay                | September 26, 2023    | DEPP-6629              | Added method getRecordsLikeName        |
      | sebastianne.k.trias            | January 25, 2024      | DEPP-7481              | added queryLocatorGetPastActiveRecords |
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
	
	public List<hed__Course_Offering__c> getRecordsLikeName(
    	String name
    ) {
		List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>();

        for (hed__Course_Offering__c record : courseOfferingsMap.values()) {
            if (record.Name.startsWith(name) || record.Name.endsWith(name)) {
                courseOfferingList.add(record);
            }
        }

		return courseOfferingList;
    }

    public Database.QueryLocator queryLocatorGetPastActiveRecords() {
        return null;
    }
}
