/**
 * @description DAO Class for IP Management Object. Contains soql and constants related to the IP Management object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 12, 2023         | DEPP-5483              | Created file                 |
 */
public inherited sharing class IPManagementsDAO extends DmlBase implements IIPManagementsDAO{

	public static final Id PATENT_RECTYPE_ID = Schema.SObjectType.IP_Management__c.getRecordTypeInfosByDeveloperName()
	.get('Patent')
	.getRecordTypeId();

    public Schema.SObjectType getSObjectType()
	{
		return IP_Management__c.SObjectType;
	}

    public static IIPManagementsDAO newInstance()
	{
		return (IIPManagementsDAO) ImplementationSelector.DAO.newInstance(IP_Management__c.SObjectType);
	}
}


