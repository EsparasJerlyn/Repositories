/**
 * @description DAO class for User
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
public with sharing class UsersDAO extends DmlBase implements IUsersDAO {
    
    public Schema.SObjectType getSObjectType(){
		return User.SObjectType;
	}

    public static IUsersDAO newInstance(){
		return (IUsersDAO) ImplementationSelector.DAO.newInstance(User.SObjectType);
	}

    public List<User> getUsersByNameSet(Set<String> usernames, AccessLevel accessLevel) {
        return Database.query(
            'SELECT Id ' + 
              'FROM User ' + 
             'WHERE Username IN: usernames', accessLevel
        );
    }
}