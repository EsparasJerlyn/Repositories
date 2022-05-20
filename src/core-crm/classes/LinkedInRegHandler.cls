/**
 * @description LinkedIn handler when user wants to login to OPE Store via LinkedIn
 * 
 * @see LinkedIn Auth Provider
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | November 24, 2021     | DEPP-771               | Created file                 | 
      |                                |                       |                        |                              | 
 */

public with sharing class LinkedInRegHandler implements Auth.RegistrationHandler {

    /**
     * @description Creates user when logs in for the first time via LinkedIn
     * @param portadId - Id of the organization
     * @param data - Auth Provider user data describing the User to create
     * @return User Object
     */    
    public User createUser(Id portalId, Auth.UserData data) {
        //Create Account 
        Account a = new Account();
        a.Name = data.lastName;
        insert (a);
        
        //Create Contact
        Contact c= new Contact();
        c.AccountId = a.Id;
        c.FirstName = data.firstName;
        c.lastName = data.lastName;
        insert (c);
        
        //Create User
        User u = new User();
        Profile p = [SELECT id FROM profile WHERE name = 'Partner Community User'];
        u.Username = data.email;
		u.Email = data.email;
        u.LastName = data.lastName;
        u.FirstName = data.firstName;
        u.ContactId = c.Id;
        String alias = data.firstName;
        
        //Alias must be 8 characters or less
        if (alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.LanguageLocaleKey = 'en_US';
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'Australia/Brisbane';
        u.profileId = p.Id;
        
        return u;
    }
    /**
     * description - Updates the user's first and last name
     * @param userId  - Id of the user
     * @param portalId  - Id of the Community
     * @param data - Auth Provider user data describing the User to create
     **/     
    public void updateUser(Id userId, Id portalId, Auth.UserData data){

        User u = new User(id=userId);
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u);
    }

}