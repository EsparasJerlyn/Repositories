/**
 * @description Interface for ContentDocument DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Created file
 */
@isTest
public inherited sharing class ContentDocumentsDAOMock extends DmlBaseMock implements IContentDocumentsDAO {
    public Map<Id, ContentDocument> contentDocumentMap;
    
    public Schema.SObjectType getSObjectType() {
        return ContentDocument.SObjectType;
    }

    public ContentDocumentsDAOMock() {
        super(new Map<Id, ContentDocument>(), Schema.ContentDocument.SObjectType);
        this.contentDocumentMap = (Map<Id, ContentDocument>) super.records;
    }

    public List<ContentDocument> getContentDocumentsByTitle(String title) {
        List<ContentDocument> contentDocumentList = new List<ContentDocument>();
        for (ContentDocument record : contentDocumentMap.values()) {
            if (record.title.contains(title)) {
                contentDocumentList.add(record);
            }
        }

        return contentDocumentList;
    }
}