/**
 * @description DAO Class for Contact_Matching_Configuration__c Object. Contains soql and constants related to the Contact_Matching_Configuration__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 06, 2024        | DEPP-7986              | Created file
 */
public inherited sharing class ContactMatchingConfigurationsDAO extends DmlBase implements IContactMatchingConfigurationsDAO{

    public Schema.SObjectType getSObjectType()
	{
		return Contact_Matching_Configuration__c.SObjectType;
	}

    public static IContactMatchingConfigurationsDAO newInstance()
	{
		return (IContactMatchingConfigurationsDAO) ImplementationSelector.DAO.newInstance(Contact_Matching_Configuration__c.SObjectType);
	}

    public List<Contact_Matching_Configuration__c> getContactMatchingConfigurationRecords(AccessLevel accessLevel){

        return Database.query(
            'SELECT Id, Noise_String__c, Field_Name__c ' +
            'FROM Contact_Matching_Configuration__c '+
            'WHERE Field_Name__c != null ' +
            'AND Noise_String__c != null ',
            accessLevel 
        );
    }
}