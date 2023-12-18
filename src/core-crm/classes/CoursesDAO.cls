
/**
 * @description DAO Class for Course Object. Contains soql and constants related to the Course object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                 |
 */
public inherited sharing class CoursesDAO extends DmlBase implements ICoursesDAO{

    public Schema.SObjectType getSObjectType()
	{
		return hed__Course__c.SObjectType;
	}

    public static ICoursesDAO newInstance()
	{
		return (ICoursesDAO) ImplementationSelector.DAO.newInstance(hed__Course__c.SObjectType);
	}
} 
