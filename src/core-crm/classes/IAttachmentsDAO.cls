/**
 * @description Interface for Attachment DAO 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public interface IAttachmentsDAO extends DmlInterface {
    List<Attachment> findAttachmentsByNames(Set<String> names, AccessLevel accessLevel); 
} 