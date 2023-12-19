/**
 * @description DAO Class for Course Offering Object. Contains soql and constants related to the Course Offering object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                 |
 *    | kenneth.f.alsay                | September 25, 2023    | DEPP-6629              | added getRecordsLikeName     |
 */
public inherited sharing class CourseOfferingsDAO extends DmlBase implements ICourseOfferingsDAO{

    public Schema.SObjectType getSObjectType()
	{
		return hed__Course_Offering__c.SObjectType;
	}

    public static ICourseOfferingsDAO newInstance()
	{
		return (ICourseOfferingsDAO) ImplementationSelector.DAO.newInstance(hed__Course_Offering__c.SObjectType);
	}
    
    public static List<hed__Course_Offering__c> getRecordsLikeName(
    	String name
    ) {
		name = '%' + name + '%';
        return [ //NOPMD
            SELECT Id, hed__End_Date__c, Name, hed__Start_Date__c, LMS_Integration_Status__c, IsActive__c
            FROM hed__Course_Offering__c
			WHERE Name LIKE :name
            WITH USER_MODE
        ];
    }
}