/**
 * @description Mock DAO Class for ContentDocumentLink Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class ContentDocumentLinksDAOMock extends DmlBaseMock implements IContentDocumentLinksDAO {
    public Map<Id, ContentDocumentLink> contentDocumentLinkMap;

    public Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.SObjectType;
    }

    public ContentDocumentLinksDAOMock() {
        super(new Map<Id, ContentDocumentLink>(), Schema.ContentDocumentLink.SObjectType);
        this.contentDocumentLinkMap = (Map<Id, ContentDocumentLink>) super.records;
    }

    public List<ContentDocumentLink> getContentDocLinksBySetLinkedEntityIds(Id linkEntityId) {
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();

        for (ContentDocumentLink record : contentDocumentLinkMap.values()) {
            if (record.LinkedEntityId == linkEntityId) {
                contentDocumentLinkList.add(record);
            }
        }

        return contentDocumentLinkList;
    }
}
