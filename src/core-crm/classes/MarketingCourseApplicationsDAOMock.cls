/**
 * @description Mock DAO Class for Marketing Course Application Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 02, 2024          | n/a                    | Created file
 */
@isTest
public inherited sharing class MarketingCourseApplicationsDAOMock extends DmlBaseMock implements IMarketingCourseApplicationsDAO {

	public Map<Id, Marketing_Course_Application__c> marketingCourseApplicationsMap;

    public Schema.SObjectType getSObjectType()
	{
		return Marketing_Course_Application__c.SObjectType;
	} 

	public MarketingCourseApplicationsDAOMock() {
		super(new Map<Id, Marketing_Course_Application__c>(), Schema.Marketing_Course_Application__c.SObjectType);
		this.marketingCourseApplicationsMap = (Map<Id, Marketing_Course_Application__c>) super.records;
	}

	public List<Marketing_Course_Application__c> getMrktngCourseAppsByLeadIds(
		Set<Id> leadIds,
        AccessLevel accessLevel
	) {
		List<Marketing_Course_Application__c> mrktgCourseAppList = new List<Marketing_Course_Application__c>();
		for(Marketing_Course_Application__c mrktgCourseApp : marketingCourseApplicationsMap.values()) {
			if(leadIds.contains(mrktgCourseApp.Lead__c)) {
				mrktgCourseAppList.add(mrktgCourseApp);
			}
		}
		return mrktgCourseAppList;
	}
}