/**
 * @description DAO Class for Milestone Object. Contains soql and constants related to the Milestone object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 5 2023           | DEPP-5474              | Created file
 */
public inherited sharing class MilestonesDAO extends DmlBase implements IMilestonesDAO{

    public Schema.SObjectType getSObjectType()
	{
		return Milestone__c.SObjectType;
	}

    public static IMilestonesDAO newInstance()
	{
		return (IMilestonesDAO) ImplementationSelector.DAO.newInstance(Milestone__c.SObjectType);
	}
}