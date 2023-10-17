/**
 * @description Mock DAO Class for AdhocCommunication Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Oct 10, 2023          | DEPP-6614              | Created file
 */
@isTest
public inherited sharing class AdhocCommunicationsDAOMock extends DmlBaseMock implements IAdhocCommunicationsDAO {

	public Map<Id, Adhoc_Communication__c> adhocCommunicationsMap;

    public Schema.SObjectType getSObjectType()
	{
		return Adhoc_Communication__c.SObjectType;
	}

	public AdhocCommunicationsDAOMock() {
		super(new Map<Id, Adhoc_Communication__c>(), Schema.Adhoc_Communication__c.SObjectType);
		this.adhocCommunicationsMap = (Map<Id, Adhoc_Communication__c>) super.records;
	}

	public List<Adhoc_Communication__c> getAdhocCommunicationsByOfferingFieldAndProductOfferingId(
        String productOfferingId, 
        String offeringField,
        AccessLevel accessLevel
    ){
		List<Adhoc_Communication__c> adhocCommunicationList = new List<Adhoc_Communication__c>();
		
		for(Adhoc_Communication__c record : adhocCommunicationsMap.values()){
			if(
				String.isNotBlank(offeringField) &&
				(record.Course_Offering__c == productOfferingId 
				 || record.Program_Offering__c == productOfferingId)
			){
				adhocCommunicationList.add(record);
			}
		}
		return adhocCommunicationList;
    }

	
    public Database.QueryLocator getAdhocCommunicationsByDate(
        Date todayDate
    ){
        return null;
    }
}