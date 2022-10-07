/**
 * @description Test Class for OPE_and_CCE_Username_Format Flow
 * @see ..OPE_and_CCE_Username_Format Flow
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | May 12, 2022          | DEPP-1495,2402       | Created file                 |
 */

@isTest
public with sharing class OPE_and_CCE_Username_FormatTest {

  @testSetup
  public static void setUp() {
    Test.startTest();
        TestDataFactory.generateTestUsers();

    Test.stopTest();
  
  }

  @isTest
  static void registerOPEUserTest() {
    Test.startTest();
    System.runAs(TestDataFactory.getPortalSysAdminUser()) {
      Account testAccount = new Account();
      testAccount.Name = 'OPE Catalogue';
      insert testAccount;
      
      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      String page = RegistrationFormCtrl.registerUser(
        'Test',
        'User',
        emailTest,
        '611234567890',
        1,
        1,
        1999,
        'testDietary Req',
        'access Req',
        '/study/s/',
        '1234567890',
        'Australia (+61)',
         null
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void registerCCEUserTest() {
    Test.startTest();
    System.runAs(TestDataFactory.getPortalSysAdminUser()) {
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
        WHERE Name = 'Partner Community User'
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
      ![SELECT Id FROM User WHERE Profile.Name = 'Partner Community User']
        .isEmpty(),
      'User must be created'
    );
    Test.stopTest();
  }
}