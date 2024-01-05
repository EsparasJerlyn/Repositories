/**
 * @description Interface for UsersDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 4, 2023     | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public interface IUsersDAO extends DmlInterface{
    List<User> getUsersByNameSet(
        Set<String> usernames, 
        AccessLevel accessLevel
    );

    List<User> getUsersById(
        Set<Id> userIdSet, 
        AccessLevel accessLevel
    );
}