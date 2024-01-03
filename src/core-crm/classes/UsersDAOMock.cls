/**
 * @description Mock DAO Class for Users Object
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
@isTest
public inherited sharing class UsersDAOMock extends DmlBaseMock implements IUsersDAO{
    public Map<Id, User> usersMap;

    public UsersDAOMock() {
        super(new Map<Id, User>(), Schema.User.SObjectType);
        this.usersMap = (Map<Id, User>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return User.SObjectType;
    }

    public List<User> getUsersByNameSet(
        Set<String> usernames,     
        AccessLevel accessLevel){

        List<User> userList = new List<User>();
        for (User record : usersMap.values()) {
            if (usernames.contains(record.Username)) {
                userList.add(record);
            }
        }

        return userList;
    }

    public List<User> getUsersById(
        Set<Id> userIdSet,     
        AccessLevel accessLevel){

        List<User> userList = new List<User>();
        for (User record : usersMap.values()) {
            if (userIdSet.contains(record.Id)) {
                userList.add(record);
            }
        }

        return userList;
    }
}