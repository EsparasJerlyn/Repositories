/**
 * @description Mock DAO Class for ContentVersion Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class ContentVersionsDAOMock extends DmlBaseMock implements IContentVersionsDAO {
    public Map<Id, ContentVersion> contentVersionMap;

    public Schema.SObjectType getSObjectType() {
        return ContentVersion.SObjectType;
    }

    public ContentVersionsDAOMock() {
        super(new Map<Id, ContentVersion>(), Schema.ContentVersion.SObjectType);
        this.contentVersionMap = (Map<Id, ContentVersion>) super.records;
    }

    public List<ContentVersion> getContentVersionBySetContentDocumentIds(
        Set<Id> contentDocumentIds
    ) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();

        for (ContentVersion record : contentVersionMap.values()) {
            if (contentDocumentIds.contains(record.ContentDocumentId)) {
                contentVersionList.add(record);
            }
        }

        return contentVersionList;
    }

    public List<ContentVersion> getContentVersionBySetIds(Set<Id> contentVersionIds) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();

        for (ContentVersion record : contentVersionMap.values()) {
            if (contentVersionIds.contains(record.Id)) {
                contentVersionList.add(record);
            }
        }

        return contentVersionList;
    }
}
