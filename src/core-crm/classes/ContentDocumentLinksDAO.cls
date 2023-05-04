/**
 * @description DAO Class for ContentDocumentLink Object. Contains soql and constants related to the ContentDocumentLink object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class ContentDocumentLinksDAO extends DmlBase implements IContentDocumentLinksDAO {
    public static IContentDocumentLinksDAO newInstance() {
        return (IContentDocumentLinksDAO) ImplementationSelector.DAO.newInstance(
            ContentDocumentLink.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.SObjectType;
    }

    public List<ContentDocumentLink> getContentDocLinksBySetLinkedEntityIds(Id linkEntityId) {
        return [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :linkEntityId
            WITH USER_MODE
        ];
    }
}
