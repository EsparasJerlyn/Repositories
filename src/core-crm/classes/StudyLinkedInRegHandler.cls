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
      | eugene.andrew.abuan            | May 31, 2022          | DEPP-2484              | Modified profile             |
      |                                |                       |                        |                              | 
 
 */

public without sharing class StudyLinkedInRegHandler implements Auth.RegistrationHandler  {
    /**
     * @description Creates user when logs in for the first time via LinkedIn
     * @param portadId - Id of the organization
     * @param data - Auth Provider user data describing the User to create
     * @return User Object
     */    
    public User createUser(Id portalId, Auth.UserData data) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        //Query OPE Account 
        Account a =  [SELECT Id, Name FROM Account WHERE Name ='QUT Experience'];

        //Create Contact
        Contact c= new Contact();
        c.AccountId = a.Id;
        c.FirstName = data.firstName;
        c.lastName = data.lastName;
        c.Email = data.email;
        c.Registered_Email__c = data.email;
        insert (c);
        
        //Create User
        User u = new User();
        Profile p = [SELECT id FROM profile WHERE name = 'QUT Experience'];
        u.Username = data.email;
		u.Email = data.email;
        u.LastName = data.lastName;
        u.FirstName = data.firstName;
        u.ContactId = c.Id;    
        u.alias = uniqueName.substring(18, 24);
        u.LanguageLocaleKey = 'en_US';
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'Australia/Brisbane';
        u.profileId = p.Id;
        insert(u);

        List<Id> userInserted = new List<Id>();
        userInserted.add(u.Id);
        assignOPEPermset(userInserted);

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

    @future
    public static void assignOPEPermset(List<ID> recordIds){
        User userInserted = [SELECT Id FROM User WHERE Id IN : recordIds];
        PermissionSet ps = [SELECT Name,Id FROM PermissionSet WHERE Name ='OPE_Catalogue'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id , AssigneeId = userInserted.Id );
        insert (psa);
    }   
}
