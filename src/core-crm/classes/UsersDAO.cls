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
      | kim.howard.capanas             | April 2, 2024         | DEPP-8203              | added UserRole.Name          |
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
            'SELECT Id, UserRole.DeveloperName ' + 
              'FROM User ' + 
             'WHERE Username IN: usernames', accessLevel
        );
    }

    public List<User> getUsersById(
        Set<Id> userIdSet, 
        AccessLevel accessLevel
    ) {
        if(userIdSet.isEmpty()){
            return new List<User>();
        }
        return Database.query(
            'SELECT Id, Contact.Work_Email__c, Contact.Name, UserRole.Name, ' + 
            'FirstName, Email, TimeZoneSidKey ' +
            'FROM User ' + 
            'WHERE Id IN: userIdSet ' +
            'LIMIT 1 ', 
            accessLevel
        );
    }
}