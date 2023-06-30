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
public inherited sharing class ContentDocumentsDAO extends DmlBase implements IContentDocumentsDAO {
    public static IContentDocumentsDAO newInstance() {
        return (IContentDocumentsDAO) ImplementationSelector.DAO.newInstance(
            ContentDocument.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return ContentDocument.SObjectType;
    }

    public List<ContentDocument> getContentDocumentsByTitle(String title) {
        return [//NOPMD
            SELECT ID
            FROM ContentDocument
            WHERE Title like :title
            WITH USER_MODE
        ];
    }
}