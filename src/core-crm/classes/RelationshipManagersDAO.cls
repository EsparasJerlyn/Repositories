/**
 * @description DAO Class for Relationship Manager Object. Contains soql and constants related to the Relationship Manager object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141              | Created file                 |
 */
public inherited sharing class RelationshipManagersDAO extends DmlBase implements IRelationshipManagersDAO{
    public static final Id ACCOUNT_RELATIONSHIP_MANAGER_RECTYPE_ID = Schema.SObjectType.Relationship_Manager__c.getRecordTypeInfosByDeveloperName()
	.get('Account_Relationship_Manager')
	.getRecordTypeId();

    public Schema.SObjectType getSObjectType()
	{
		return Relationship_Manager__c.SObjectType;
	}

    public static IRelationshipManagersDAO newInstance()
	{
		return (IRelationshipManagersDAO) ImplementationSelector.DAO.newInstance(Relationship_Manager__c.SObjectType);
	}
}
