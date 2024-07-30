/**
 * @description Test Class for Portal_Username_Format Flow
 * @see ..Portal_Username_Format Flow
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | kenneth.f.alsay           | July 26, 2024         | DEPP-9231            | Created file                 |
 */

 @isTest
 public with sharing class PortalUsernameFormatFlowTest {
 
   public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
     .get('Person')
     .getRecordTypeId();
 
   @testSetup
   public static void setUp() {
     Test.startTest();
         TestDataFactoryUser.generateUserSystemAdministrator();
 
         BuyerGroup opeBuyerGroup = new BuyerGroup(Name = 'OPE BuyerGroup');
         insert opeBuyerGroup;
 
     Test.stopTest();
   }
 
   @isTest
   static void registerOPEUserTest() {
     Test.startTest();
     System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
       Account testAccount = new Account();
       testAccount.Name = 'OPE Catalogue';
       insert testAccount;
       
       String uniqueID = GenerateUniqueId.getUUID();
       String emailTest = 'testUser' + uniqueID + '@test.com';
          
       Contact contactRecord = new Contact();
       contactRecord.FirstName = 'Test';
       contactRecord.LastName = 'User';
       contactRecord.Registered_Email__c = emailTest;
       contactRecord.MobilePhone = '611234567890';
       contactRecord.Dietary_Requirement__c = 'testDietary Req';
       contactRecord.Accessibility_Requirement__c = 'access Req';
       contactRecord.Mobile_No_Locale__c = '1234567890';
       contactRecord.ContactMobile_Locale__c = 'Australia (+61)';
 
       RegistrationFormCtrl.RegistrationDataWrapper registrationData = new RegistrationFormCtrl.RegistrationDataWrapper();   
       registrationData.startURL = '/study/s/';
       registrationData.isOptIn = true;
       registrationData.contactRecord = contactRecord;
 
       RegistrationFormCtrl.BirthDateWrapper birthDateData = new RegistrationFormCtrl.BirthDateWrapper();
       birthDateData.day = 1;
       birthDateData.month = 1;
       birthDateData.year = 1999;
 
       String page = RegistrationFormCtrl.registerUser(
           JSON.serialize(registrationData),
           JSON.serialize(birthDateData)
       );
 
       System.assert(page == null, 'Page must not be null');
     }
     Test.stopTest();
   }
 
   @isTest
   static void registerCCEUserTest() {
     Test.startTest();
     System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
       Account testAccount = new Account();
       testAccount.Name = 'OPE Catalogue';
       insert testAccount;
 
       String uniqueID = GenerateUniqueId.getUUID();
       String emailTest = 'testUser' + uniqueID + '@test.com';
 
       Date birthdate = Date.newInstance(1999, 1, 1);
 
       //Set fields from the form to the Contact Object
       Contact c = new Contact();
       c.AccountId = testAccount.Id;
       c.FirstName = 'Test';
       c.lastName = 'User';
       c.Email = emailTest;
       c.MobilePhone = '12345';
       c.Birthdate = birthdate;
       c.Dietary_Requirement__c = 'testDietary Req';
       c.Accessibility_Requirement__c = 'access Req';
       insert (c);
 
 
 
       //Query Ecommerece Learner Profile
       Profile p = [
         SELECT Id
         FROM Profile
         WHERE Name = 'Corporate Partner'
       ];
 
       //Create User
       User u = new User();
       u.FirstName = c.FirstName;
       u.LastName = c.lastName;
       u.Email = c.Email;
       u.MobilePhone = c.MobilePhone;
       u.Birthdate__c = c.Birthdate;
       String alias = c.FirstName;
       if (alias.length() > 8) {
         alias = alias.substring(0, 8);
       }
       u.Username = emailTest+'.ope';
       u.alias = alias;
       u.LanguageLocaleKey = 'en_US';
       u.localesidkey = UserInfo.getLocale();
       u.emailEncodingKey = 'UTF-8';
       u.timeZoneSidKey = 'Australia/Brisbane';
       u.ContactId = c.Id;
       u.profileId = p.Id;
       insert (u);
     }
     System.assert(
       ![SELECT Id FROM User WHERE Profile.Name = 'Corporate Partner']
         .isEmpty(),
       'User must be created'
     );
     Test.stopTest();
   }
 
 }