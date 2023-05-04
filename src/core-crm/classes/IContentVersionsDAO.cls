/**
 * @description Interface for ContentVersion DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IContentVersionsDAO extends DmlInterface {
    List<ContentVersion> getContentVersionBySetContentDocumentIds(Set<Id> contentDocumentIds);
    List<ContentVersion> getContentVersionBySetIds(Set<Id> contentVersionIds);
}
