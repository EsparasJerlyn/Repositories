/**
 * @description Creates User when learner tries to Register in OPE Store
 * @see ../lwc/registrationForm
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                 |
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
    * @description Method to Register User 
    * @param firstName - First Name of the User 
    * @param lastName - Last Name of the User
    * @param email - Email of the User
    * @param mobile - Mobile of the User
    * @param birtdate - Birthdate of the User
    * @return page - Returns api name of the confirmation page
    */
    @AuraEnabled
    public static string registerUser(String firstName, String lastName, String email, String mobile, Date birtdate){
        try {
            Account a = new Account();
            a.Name = firstName + ' ' + lastName;
            insert (a);

            Contact c= new Contact();
            c.AccountId = a.Id;
            c.FirstName = firstName;
            c.lastName = lastName;
            c.Birthdate = birtdate;
            insert (c);
            
            User u = new User();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'];
            u.FirstName = firstName;
            u.LastName = lastName;
            u.Email = email;
            u.MobilePhone = mobile;
            u.Birthdate__c = birtdate;
            u.Username = email;
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

            String emailReceived = sendWelcomeMail(u);

            string confrimPageName = 'CheckPasswordResetEmail';
            return confrimPageName;
        } 
         catch (Exception e) {
            system.debug('e.getMessage+   '+e.getMessage());
            return null;          
        }
    }   

    /**
    * @description Method to send Welcome Email to the User
    * @param email - Email of the User 
    * @return success - returns string value to indicate email has been sent.
    */
    @AuraEnabled
    public static String sendWelcomeMail(User u){

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<EmailTemplate> welcomeTemplate = new List<EmailTemplate>([Select Id from EmailTemplate where name = 'Experience Cloud: New Member Welcome Email']);

            mail.setTargetObjectId(u.Id);
            mail.setTemplateId(welcomeTemplate[0].Id);
            mail.setSaveAsActivity(false);

            Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{mail} );
            return 'success';
    }
}