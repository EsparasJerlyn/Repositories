/**
 * @description Creates User when learner tries to Register in OPE Store
 * @see ../lwc/registrationForm
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                 |
      | eugene.andrew.abuan       | March 28, 2022        | DEPP-1293            | Added Dietary Req            | 
      |                           |                       |                      |                              | 

 */
public without sharing class RegistrationFormCtrl {
    /**
    * @description Method to check if Email exists 
    * @param email - Email of the User 
    * @return userList - returns true if email exits otherwise false
    */
    @AuraEnabled(cacheable=false)  
    public static boolean isEmailExist(String email){
        try {
            List<User> userList = new List<User>();
            userList = [Select Id, Name From User Where Email =:email];
            return !userList.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Method to get the community URL
    * @return communityUrl - returns the site link
    */
    @AuraEnabled(cacheable=false)  
    public static string getCommunityUrl(){
        try {
            Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'study' LIMIT 1];
            String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
            return communityUrl;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Method to Register User 
    * @param firstName - First Name of the User 
    * @param lastName - Last Name of the User
    * @param email - Email of the User
    * @param mobile - Mobile of the User
    * @param date - date of the Birthdate of the User
    * @param month - month of the Birthdate of the User
    * @param year - year of the Birthdate of the User    
    * @param dietraryReq - Dietary Requirement of the User
    * @return page - Returns api name of the confirmation page
    */
    @AuraEnabled
    public static string registerUser(
        String firstName, String lastName, String email, String mobile, 
        Integer day, Integer month, Integer year, String dietaryReq){
        try {
            //Query OPE Account
            Account a =  [SELECT Id, Name FROM Account WHERE Name ='OPE Catalogue'];
            Date birthdate = Date.newInstance(year, month, day);

            //Set fields from the form to the Contact Object
            Contact c= new Contact();
            c.AccountId = a.Id;
            c.FirstName = firstName;
            c.lastName = lastName;
            c.Email = email;
            c.MobilePhone = mobile;
            c.Birthdate = birthdate;
            c.Dietary_Requirement__c = dietaryReq;
            insert (c);
            
            //Query Ecommerece Learner Profile
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Ecommerce Learner'];

            //Create User
            User u = new User();
            u.FirstName = firstName;
            u.LastName = lastName;
            u.Email = email;
            u.MobilePhone = mobile;
            u.Birthdate__c = birthdate;
            u.Username = email + '.ope';
            String alias = firstName;
            if (alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.alias = alias;
            u.LanguageLocaleKey = 'en_US';
            u.localesidkey = UserInfo.getLocale();
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = 'Australia/Brisbane';
            u.ContactId = c.Id;
            u.profileId = p.Id;
            insert (u);

            List<Id> userInserted = new List<Id>();
            userInserted.add(u.Id);
            assignOPEPermset(userInserted);

            string confrimPageName = 'CheckPasswordResetEmail';
            return confrimPageName;
        } 
         catch (Exception e) {
            return null;          
        }
    }  

    /**
    * @description Method to Assign the Permission set to the User in future
    * @param recordIds - Id of the User
    */
	@future
    public static void assignOPEPermset(List<ID> recordIds){
        User userInserted = [SELECT Id FROM User WHERE Id IN : recordIds];
        PermissionSet ps = [SELECT Name,Id FROM PermissionSet WHERE Name ='OPE_Portal'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id , AssigneeId = userInserted.Id );
        insert (psa);
    }   
}