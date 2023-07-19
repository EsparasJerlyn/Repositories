/**
 * @description DAO Class for Document Object. Contains soql and constants related to the Document object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                 |
 */
public inherited sharing class DocumentsDAO extends DmlBase implements IDocumentsDAO{
	public static final Id STANDARD_RECTYPE_ID = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName()
	.get('Standard')
	.getRecordTypeId();

    public Schema.SObjectType getSObjectType()
	{
		return Document__c.SObjectType;
	}

    public static IDocumentsDAO newInstance()
	{
		return (IDocumentsDAO) ImplementationSelector.DAO.newInstance(Document__c.SObjectType);
	}
}