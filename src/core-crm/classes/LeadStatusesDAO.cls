/**
 * @description DAO Class for LeadStatus Object. Contains soql and constants related to the LeadStatus object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 03, 2024          | n/a                    | Created file
 */
public inherited sharing class LeadStatusesDAO extends DmlBase implements ILeadStatusesDAO{

    public Schema.SObjectType getSObjectType()
	{
		return LeadStatus.SObjectType;
	} 

    public static ILeadStatusesDAO newInstance()
	{
		return (ILeadStatusesDAO) ImplementationSelector.DAO.newInstance(LeadStatus.SObjectType);
	}

	public LeadStatus getConvertedLeadStatus(AccessLevel accessLevel) {
		if(accessLevel == null) { return null; }
		return Database.query(
			'SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1',
			accessLevel
		);
	}
}