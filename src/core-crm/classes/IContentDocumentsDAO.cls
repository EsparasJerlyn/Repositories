/**
 * @description Interface for ContentDocuments DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Created file
 */
public interface IContentDocumentsDAO extends DmlInterface {
    List<ContentDocument> getContentDocumentsByTitle(String title);
}