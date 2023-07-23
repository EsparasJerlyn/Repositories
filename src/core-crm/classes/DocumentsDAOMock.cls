/**
 * @description Mock DAO Class for Document Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                 |                                                     |
 */
@isTest
public inherited sharing class DocumentsDAOMock extends DmlBaseMock implements IDocumentsDAO {

	public Map<Id, Document__c> documentMap;

    public Schema.SObjectType getSObjectType()
	{
		return Document__c.SObjectType;
	}

	public DocumentsDAOMock() {
		super(new Map<Id, Document__c>(), Schema.Document__c.SObjectType);
		this.documentMap = (Map<Id, Document__c>) super.records;
	}
}