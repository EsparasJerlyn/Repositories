/**
 * @description Mock DAO Class for Relationship Manager Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141	            | Created file                 |                                                     |
 */
@isTest
public inherited sharing class RelationshipManagersDAOMock extends DmlBaseMock implements IRelationshipManagersDAO {

	public Map<Id, Relationship_Manager__c> relationshipManagerMap;

    public Schema.SObjectType getSObjectType()
	{
		return Relationship_Manager__c.SObjectType;
	}

	public RelationshipManagersDAOMock() {
		super(new Map<Id, Relationship_Manager__c>(), Schema.Relationship_Manager__c.SObjectType);
		this.relationshipManagerMap = (Map<Id, Relationship_Manager__c>) super.records;
	}
}
