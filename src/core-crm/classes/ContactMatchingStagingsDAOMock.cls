/**
 * @description Mock DAO Class for Contact Matching Staging Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 09, 2024          | DEPP-8676              | Created file
 */
@isTest
public inherited sharing class ContactMatchingStagingsDAOMock extends DmlBaseMock implements IContactMatchingStagingsDAO{

	public Map<Id, Contact_Matching_Staging__c> conMatchingStagingMap;

    public Schema.SObjectType getSObjectType()
	{
		return Contact_Matching_Staging__c.SObjectType;
	}

	public ContactMatchingStagingsDAOMock() {
		super(new Map<Id, Contact_Matching_Staging__c>(), Schema.Contact_Matching_Staging__c.SObjectType);
		this.conMatchingStagingMap = (Map<Id, Contact_Matching_Staging__c>) super.records;
	}

	public Database.QueryLocator queryLocatorGetContactMatchingStagingsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
        return null;
    }

	public List<Contact_Matching_Staging__c> getContactMatchingStagingsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
		List<Contact_Matching_Staging__c> conMatchingStagings = new List<Contact_Matching_Staging__c>();

		for(Contact_Matching_Staging__c conMatchingStaging : conMatchingStagings){
			if(batchProcessSet.contains(conMatchingStaging.Batch_Process__c)){
				conMatchingStagings.add(conMatchingStaging);
			}
		}

		return conMatchingStagings;
    }
}