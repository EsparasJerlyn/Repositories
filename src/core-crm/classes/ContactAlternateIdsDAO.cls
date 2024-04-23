/**
 * @description DAO Class for Contact_Alternate_ID__c Object. Contains soql and constants related to the Contact_Alternate_ID__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 06, 2024        | DEPP-7986              | Created file
 */
public inherited sharing class ContactAlternateIdsDAO extends DmlBase implements IContactAlternateIdsDAO{

    public static final String ACTIVE_STATUS = 'Active';

    public Schema.SObjectType getSObjectType()
	{
		return Contact_Alternate_ID__c.SObjectType;
	}

    public static IContactAlternateIdsDAO newInstance()
	{
		return (IContactAlternateIdsDAO) ImplementationSelector.DAO.newInstance(Contact_Alternate_ID__c.SObjectType);
	}

    public List<Contact_Alternate_ID__c> getContactAlternateIdsBySystemKeyIdSet(Set<String> systemKeyIdsSet, AccessLevel accessLevel){

        if(systemKeyIdsSet.isEmpty()){
            return new List<Contact_Alternate_ID__c>();
        }

        return Database.query(
            'SELECT Id, Contact_Alternate_Id__c, Alternate_Id_Type__c, Contact__c, ' +
            'Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, Contact__r.MobilePhone, ' +
            'Contact__r.Email, Contact__r.QUT_Staff_Email__c, Contact__r.QUT_Learner_Email__c, Contact__r.Work_Email__c, ' +
            'Contact__r.QUT_Employee_ID__c, Contact__r.QUT_Student_ID__c ' +
            'FROM Contact_Alternate_Id__c '+
            'WHERE Contact_Alternate_Id__c IN: systemKeyIdsSet ' +
            'AND Contact__c != null '+
            'AND Alternate_Id_Status__c =: ACTIVE_STATUS ',
            accessLevel 
        );
    }

    public List<Contact_Alternate_ID__c> getContactAlternateIdsByContactIdSet(Set<Id> contactIdSet, AccessLevel accessLevel){

        if(contactIdSet.isEmpty()){
            return new List<Contact_Alternate_ID__c>();
        }

        return Database.query(
            'SELECT Id, Contact_Alternate_Id__c, Alternate_Id_Type__c, Contact__c, ' +
            'Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, Contact__r.MobilePhone, ' +
            'Contact__r.Email, Contact__r.QUT_Staff_Email__c, Contact__r.QUT_Learner_Email__c, Contact__r.Work_Email__c, ' +
            'Contact__r.QUT_Employee_ID__c, Contact__r.QUT_Student_ID__c ' +
            'FROM Contact_Alternate_Id__c '+
            'WHERE Contact__c IN: contactIdSet ' +
            'AND Alternate_Id_Type__c != null '+
            'AND Alternate_Id_Status__c =: ACTIVE_STATUS ' +
            'AND Contact_Alternate_Id__c != null ',
            accessLevel 
        );
    }
}