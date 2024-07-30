/**
 * @description Registration handler when user wants to login to OPE Store via QUT SSO
 * 
 * @see QUTExperienceSSO Auth Provider
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                           |
      |--------------------------------|-----------------------|------------------------|------------------------------------------|
      | eugene.andrew.abuan            | May 30, 2022          | DEPP-870               | Created file                             | 
      | kenneth.f.alsay                | June 21, 2024         | DEPP-9221              | Renamed OPE Catalogue to QUT Experience  |
      |                                |                       |                        |                                          |
 */

public without sharing class StudySSORegHandler implements Auth.RegistrationHandler  {

    /**
     * @description Creates user when logs in for the first time via LinkedIn
     * @param portadId - Id of the organization
     * @param data - Auth Provider user data describing the User to create
     * @return User Object
     */  
    public User createUser(Id portalId, Auth.UserData data){
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        Account a =  [SELECT Id, Name FROM Account WHERE Name ='QUT Experience'];

        //Link Contact to QUT Experience
		List<Contact> contacts = [SELECT Id, QUT_Student_Username__c, Registered_Email__c  FROM Contact WHERE QUT_Student_Username__c =: data.username LIMIT 1];
        for (Contact con : contacts){
            con.AccountId = a.Id;
            con.Registered_Email__c = data.email;
        }
        update(contacts);
        
        Contact c = [SELECT Id, QUT_Student_Username__c  FROM Contact WHERE QUT_Student_Username__c =: data.username LIMIT 1];
		User u = new User();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'QUT Experience'];
		u.Username = data.username;
		u.Email = data.email;
		u.LastName = data.lastName;
		u.FirstName = data.firstName;
		u.ContactId = c.Id;
		String alias = data.firstName;
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

    /**
    * @description Method to Assign the Permission set to the User in future
    * @param recordIds - Id of the User
    */
    @future
    public static void assignOPEPermset(List<ID> recordIds){
        User userInserted = [SELECT Id FROM User WHERE Id IN : recordIds];
        PermissionSet ps = [SELECT Name,Id FROM PermissionSet WHERE Name ='OPE_Catalogue'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id , AssigneeId = userInserted.Id );
        insert (psa);
    }
}
