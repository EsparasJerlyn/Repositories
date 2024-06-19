/**
 * @description Mock DAO Class for Contact Matching Configuration Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 06, 2024        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class ContactMatchingConfigurationsDAOMock extends DmlBaseMock implements IContactMatchingConfigurationsDAO{

	public Map<Id, Contact_Matching_Configuration__c> conMatchConfigMap;

    public Schema.SObjectType getSObjectType()
	{
		return Contact_Matching_Configuration__c.SObjectType;
	}

	public ContactMatchingConfigurationsDAOMock() {
		super(new Map<Id, Contact_Matching_Configuration__c>(), Schema.Contact_Matching_Configuration__c.SObjectType);
		this.conMatchConfigMap = (Map<Id, Contact_Matching_Configuration__c>) super.records;
	}


	public List<Contact_Matching_Configuration__c> getContactMatchingConfigurationRecords(AccessLevel accessLevel){

		List<Contact_Matching_Configuration__c> conMatchConfigList = new List<Contact_Matching_Configuration__c>();

		for(Contact_Matching_Configuration__c conMatchConfig: conMatchConfigMap.values()){
			if(conMatchConfig.Field_Name__c != null && conMatchConfig.Noise_String__c != null){
				conMatchConfigList.add(conMatchConfig);
			}
		}
        
		return conMatchConfigList;
	}
}