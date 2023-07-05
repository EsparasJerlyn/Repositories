/**
 * @description DAO Class for ContentVersion Object. Contains soql and constants related to the ContentVersion object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | added getContentVersionByTitle
 */
public inherited sharing class ContentVersionsDAO extends DmlBase implements IContentVersionsDAO {
    public static IContentVersionsDAO newInstance() {
        return (IContentVersionsDAO) ImplementationSelector.DAO.newInstance(
            ContentVersion.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return ContentVersion.SObjectType;
    }

    public List<ContentVersion> getContentVersionBySetContentDocumentIds(
        Set<Id> contentDocumentIds
    ) {
        return [
            SELECT ContentDocumentId, FileExtension, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            WITH USER_MODE
        ];
    }

    public List<ContentVersion> getContentVersionBySetIds(Set<Id> contentVersionIds) {
        return [
            SELECT ContentDocumentId, FileExtension, Title
            FROM ContentVersion
            WHERE Id IN :contentVersionIds
            WITH USER_MODE
        ];
    }

    public List<ContentVersion> getContentVersionByTitle(Set<String> titles) {
        return [//NOPMD
            SELECT ID, ContentDocumentId, FileExtension, Title
            FROM ContentVersion
            WHERE Title IN :titles
            WITH USER_MODE
        ];
    }
}
