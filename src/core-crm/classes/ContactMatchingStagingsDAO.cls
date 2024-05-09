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
public inherited sharing class ContactMatchingStagingsDAO extends DmlBase implements IContactMatchingStagingsDAO{

	public static final String INSERT_PROCESS = 'Insert';
	public static final String PROCESSED_PROCESS = 'Processed';

    public Schema.SObjectType getSObjectType()
	{
		return Contact_Matching_Staging__c.SObjectType;
	}

    public static IContactMatchingStagingsDAO newInstance()
	{
		return (IContactMatchingStagingsDAO) ImplementationSelector.DAO.newInstance(Contact_Matching_Staging__c.SObjectType);
	}

	public Database.QueryLocator queryLocatorGetContactMarketingStagingsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
        String query =
		' SELECT Id, Birthdate__c, Citizenship_Status__c, Date_Deceased__c, Deceased__c, Email__c, FirstName__c, LastName__c, Indigenous_Status__c, ' +
		' Mailing_City__c, Mailing_Country__c, Mailing_State__c, Mailing_Street__c, Mailing_PostalCode__c, MiddleName__c, Mobile_No_Locale__c, MobilePhone__c, ' +
		' Preferred_Given_Name__c, QUT_Employee_ID__c, QUT_Identity_ID__c, Work_Email__c, QUT_Learner_Email__c, QUT_Staff_Email__c, QUT_Staff_Username__c, QUT_Student_ID__c, ' +
		' QUT_Student_Username__c, Residential_City__c, Residential_Country__c, Residential_State__c, Residential_Street__c, Residential_PostalCode__c,  ' +
		' Salutation__c, Staff_End_Date__c, Batch_Process__c  ' +
		' FROM Contact_Matching_Staging__c ' +
		' WHERE Batch_Process__c IN: batchProcessSet ';
        return Database.getQueryLocator(query,accessLevel);
    }

	public List<Contact_Matching_Staging__c> getContactMarketingStagingsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
		if(batchProcessSet.isEmpty()){
			return new List<Contact_Matching_Staging__c>();
		}
		
        String query =
		' SELECT Id ' +
		' FROM Contact_Matching_Staging__c ' +
		' WHERE Batch_Process__c IN: batchProcessSet ' +
		' LIMIT 1 ';
        return Database.query(query,accessLevel);
    }
}