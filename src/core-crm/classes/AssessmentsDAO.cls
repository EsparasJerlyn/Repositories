/**
 * @description DAO Class for Assessment Object. Contains soql and constants related to the Assessment object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 08, 2024          | DEPP-8487              | Created file                 |
 */

 public inherited sharing class AssessmentsDAO extends DmlBase implements IAssessmentsDAO{
   
    public Schema.SObjectType getSObjectType()
	{
		return Assessment__c.SObjectType;
	}

    public static IAssessmentsDAO newInstance()
	{
		return (IAssessmentsDAO) ImplementationSelector.DAO.newInstance(Assessment__c.SObjectType);
	}

}