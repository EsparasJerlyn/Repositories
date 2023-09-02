/**
 * @description Interface for ContentDocumentLink DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IContentDocumentLinksDAO extends DmlInterface {
    List<ContentDocumentLink> getContentDocLinksBySetLinkedEntityIds(Id linkedEntityId);
}
