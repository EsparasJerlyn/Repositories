/**
 * @description Mock DAO Class for IP Management Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                 |                                                     |
 */
@isTest
public inherited sharing class IPManagementsDAOMock extends DmlBaseMock implements IIPManagementsDAO {

	public Map<Id, IP_Management__c> ipManagements;

    public Schema.SObjectType getSObjectType()
	{
		return IP_Management__c.SObjectType;
	}

	public IPManagementsDAOMock() {
		super(new Map<Id, Document__c>(), Schema.Document__c.SObjectType);
		this.ipManagements = (Map<Id, IP_Management__c>) super.records;
	}
}
