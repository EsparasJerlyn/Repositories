/**
 * @description Interface for Contact DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IContactsDAO extends DmlInterface {
    List<Contact> getExistingPersonContactsWithMatchingEmails(
        Set<String> allEmailsToMatch,
        Set<Id> newContactIds,
        String accessLevel
    );
    List<Contact> getPersonContactsWithLimit(Integer recordsCount);
}
