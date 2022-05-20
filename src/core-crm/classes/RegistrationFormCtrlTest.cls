/**
 * @description Test Class for RegistrationFormCrtl
 * @see ..RegistrationFormCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                 |
      | eugene.andrew.abuan       | April 26, 2022        | DEPP-1293            | Modified to add get community| 
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
            testAccount.Name = 'OPE Catalogue';
            insert testAccount;

            String uniqueID = GenerateUniqueId.getUUID();
            String emailTest = 'testUser' + uniqueID + '@test.com';
            
            String page = RegistrationFormCtrl.registerUser('Test','User',emailTest,'12345', 1,1,1999,'testDietary Req');
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
            Profile p = [SELECT Id FROM Profile WHERE Name='Ecommerce Learner']; 
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
    static void getCommunityUrlTest(){
        WebStore testWebStore = new WebStore(Name='study', DefaultLanguage='en_US');
        insert testWebStore;

        Test.startTest();
        String communityUrl = RegistrationFormCtrl.getCommunityUrl();
        Test.stopTest();
        System.assert(communityUrl !=null , 'No Community Url Found');
    }
}