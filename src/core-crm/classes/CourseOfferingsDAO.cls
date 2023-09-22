
/**
 * @description DAO Class for Course Offering Object. Contains soql and constants related to the Course Offering object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                 |
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
} 