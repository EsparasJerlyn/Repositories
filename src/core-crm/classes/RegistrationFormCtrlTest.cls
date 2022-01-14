/**
 * @description Test Class for RegistrationFormCrtl
 * @see ..RegistrationFormCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                 |
      |                           |                       |                      |                              | 
 */
@isTest(SeeAllData=false)
public with sharing class RegistrationFormCtrlTest {

    @isTest
    static void registerUserTest() {
        UserRole userrole = [Select Id, Name From UserRole Where Name = 'System Administrator' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];

        adminUser.UserRoleId = userRole.Id;
        adminUser.IsActive = True;
        update adminUser;
        Test.startTest();
        System.runAs(adminUser){
            Account testAccount = new Account();
            testAccount.Name = 'Test Account12345';
            insert testAccount;

            String page = RegistrationFormCtrl.registerUser('Test','User','testuser12345#_@test.com','12345', date.newinstance(1960, 2, 17));
            System.assert(page !=null,'Page must not be null');
        }
        Test.stopTest();
    }
	
    @isTest
    static void isEmailExistTest(){
        UserRole userrole = [Select Id, Name From UserRole Where Name = 'System Administrator' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];

        adminUser.UserRoleId = userRole.Id;
        adminUser.IsActive = True;
        update adminUser;
        Test.startTest();
        System.runAs(adminUser){
            Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User']; 
            Contact c = new Contact(LastName = 'Testing');
            insert c;
            User u = new User(Alias = 'standt', Email='testUser1234@test.com', 
                EmailEncodingKey='UTF-8', lastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, ContactId = c.Id,
                Username='testUser1234@test.com.org',TimeZoneSidKey='Australia/Brisbane');
            insert u;
            Boolean isExist = RegistrationFormCtrl.isEmailExist('testUser1234@test.com');
            System.assert(isExist == true,'Email is match');
        }
        Test.stopTest();
    }
    
    @isTest
    static void sendWelcomeMailTest(){
        UserRole userrole = [Select Id, Name From UserRole Where Name = 'System Administrator' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];

        adminUser.UserRoleId = userRole.Id;
        adminUser.IsActive = True;
        update adminUser;
        Test.startTest();
        System.runAs(adminUser){
            Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User']; 
            Contact c = new Contact(LastName = 'Testing');
            insert c;
            User u = new User(Alias = 'standt', Email='testUser12347@test.com', 
                EmailEncodingKey='UTF-8', lastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, ContactId = c.Id,
                Username='testUser12347@test.com.org',TimeZoneSidKey='Australia/Brisbane');
            insert u;
            String message = RegistrationFormCtrl.sendWelcomeMail(u);
            System.assert(message !=null, 'Email is sent to the User');
        }
        Test.stopTest();
    }
}