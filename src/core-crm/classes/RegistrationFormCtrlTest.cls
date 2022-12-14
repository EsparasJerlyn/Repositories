/**
 * @description Test Class for RegistrationFormCrtl
 * @see ..RegistrationFormCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                 |
      | eugene.andrew.abuan       | April 26, 2022        | DEPP-1293            | Modified to add get community|
      | john.bo.a.pineda          | June 1, 2022          | DEPP-1661            | Added send SMS OTP method    |
      | rhea.b.torres             | June 6, 2022          | DEPP-2861            | Added testSetup              |
      | keno.domienri.dico        | June 15, 2022         | DEPP-2758            | Added Accessibility Req field|
      | john.bo.a.pineda          | June 20, 2022         | DEPP-3191            | Added Logic for Login User   |
      | julie.jane.alegre         | August 02, 2022       | DEPP-3568            | Added test method for update |
      |                           |                       |                      | contact & check if user exist|
      | eugene.andrew.abuan       | September 12, 2022    | DEPP-4225            | Added method for cce login   |
      | eugene.andrew.abuan       | Septmeber 16, 2022    | DEPP-3506            | Removed OPE Catalouge Account|
      |                           |                       |                      | & added OPE BuyerGroup       |
      | julie.jane.alegre         | September 24, 2022    | DEPP-3568            | Update method  isEmailExist  |

 */
@isTest
public with sharing class RegistrationFormCtrlTest {
  public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Person')
    .getRecordTypeId();

  private static final Id ADMINISTRATIVE_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();

  @testSetup
  public static void setUp() {
    TestDataFactory.generateTestUsers();
    // Create Custom Setting
    MC_Messaging_OTP_Setting__c setting = TestDataFactory.createOTPCustomSetting();
    insert setting;
    BuyerGroup opeBuyerGroup = new BuyerGroup(
      Name = 'OPE BuyerGroup'
    );
    insert opeBuyerGroup;
  }

  @isTest
  static void registerUserNoMatchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {

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
  static void registerUserExactMatchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      Contact testContact = new Contact();
      testContact.Birthdate = Date.newInstance(1999, 1, 1);
      testContact.Email = emailTest;
      testContact.LastName = 'User';
      testContact.RecordTypeId = PERSON;
      insert testContact;

      String page = RegistrationFormCtrl.registerUser(
        'Test001',
        'User001',
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
  static void registerUserMultipleMatchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser1' + uniqueID + '@test.com';

      List<Contact> testContacts = new List<Contact>();
      Contact testContact1 = new Contact();
      testContact1.Birthdate = Date.newInstance(1999, 1, 1);
      testContact1.Email = emailTest;
      testContact1.LastName = 'User';
      testContact1.RecordTypeId = PERSON;
      testContacts.add(testContact1);

      Contact testContact2 = new Contact();
      testContact2.Birthdate = Date.newInstance(1999, 1, 1);
      testContact2.LastName = 'User';
      testContact2.RecordTypeId = PERSON;
      testContacts.add(testContact2);

      insert testContacts;

      testContact2.Email = 'testUser2' + GenerateUniqueId.getUUID() + '@test.com';
      update testContact2;

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
  static void isUserExistTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'OPE Catalogue'];
      Contact c = new Contact(LastName = 'Testing');
      insert c;
      User u = new User(
        Alias = 'standt',
        Email = 'testUser12345@test.com',
        EmailEncodingKey = 'UTF-8',
        lastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        ContactId = c.Id,
        Username = 'testUser1234@test.com.org',
        TimeZoneSidKey = 'Australia/Brisbane'
      );
      insert u;
      List<User> isExist = RegistrationFormCtrl.isUserExist(
        c.Id
      );
      System.assert(isExist.size() > 0, 'The user exist');
    }
    Test.stopTest();
  }

  @isTest
  static void updateContactTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Contact c = new Contact(
                              LastName = 'Testing01', 
                              FirstName ='Testing01',
                              Email = 'test12345@sample.com',
                              RecordTypeId = PERSON
                              );
      insert c;

      RegistrationFormCtrl.updateContact(
                                          c.Id, 
                                          'test12345@sample.com', 
                                          '0987654321', 
                                          'Australia (+61)', 
                                          'testing', 
                                          'testing',
                                          false);
      String contact = c.Accessibility_Requirement__c;

      System.assert(contact == null, 'The contact details is updated');
    }
    Test.stopTest();
  }


  @isTest
  static void isEmailExistTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      
      Profile pCEE = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'];
      List<Account> accounts;
      accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
          acc.RecordTypeId = ADMINISTRATIVE_ACC_RECTYPEID;
      }
      insert accounts;

      Contact contact = new Contact();
      contact.FirstName = 'User fname';
      contact.LastName = 'Testing 001';
      contact.AccountId = accounts[0].Id;
      contact.Email = 'testemailcce@test.com';
      contact.Work_Email__c = 'testworkemailcce@test.com';
      contact.hed__Preferred_Email__c = 'Alternate Email';
      contact.hed__AlternateEmail__c = 'testemailcce@test.com';
      contact.Registered_Email__c = 'testemailcce@test.com';
      insert contact;

      User uCCE = new User(
        Alias = 'standt',
        Email = contact.Work_Email__c,
        EmailEncodingKey = 'UTF-8',
        lastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = pCEE.Id,
        ContactId = contact.Id,
        Username = contact.Work_Email__c + '.cce',
        TimeZoneSidKey = 'Australia/Brisbane'
      );
      insert uCCE;

      List<User> isExist = RegistrationFormCtrl.isEmailExist(
        'testworkemailcce@test.com'
      );
      System.assert(isExist.size() > 0, 'Email is not match');
    }
    Test.stopTest();
  }

  @isTest
  static void getCommunityUrlTest() {
    WebStore testWebStore = new WebStore(
      Name = 'study',
      DefaultLanguage = 'en_US'
    );
    insert testWebStore;

    WebStore testWebStoreCCE = new WebStore(
      Name = 'cce',
      DefaultLanguage = 'en_US'
    );
    insert testWebStoreCCE;

    Test.startTest();
    RegistrationFormCtrl.CommunityWrapper comData = RegistrationFormCtrl.getCommunityUrl();
    Test.stopTest();
    System.assert(comData != null, 'No Community Data Found');
  }

  @isTest
  static void sendRegistrationSMSOTPTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Test.setMock(HttpCalloutMock.class, new ReqMockHttpResponse());

      String sentOTP = RegistrationFormCtrl.sendRegistrationSMSOTP('12345678');

      System.assert(sentOTP != null, 'sentOTP must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void getUserMobileLocale(){
    String uniqueID = GenerateUniqueId.getUUID();
    String emailTest = 'testUser' + uniqueID + '@test.com';

    Contact testContact = new Contact();
    testContact.Birthdate = Date.newInstance(1999, 1, 1);
    testContact.ContactMobile_Locale__c  = 'Australia (+61)';
    testContact.Email = emailTest;
    testContact.LastName = 'User';
    insert testContact;

    Test.startTest();
    String getMLocale = RegistrationFormCtrl.getUserMobileLocale(testContact.Id);
    System.assert(getMLocale != null, 'User has no mobile locale.');
    Test.stopTest();
  }

  @isTest
  static void getMobileLocaleOptionsTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      List<RegistrationFormCtrl.MobileLocaleWrapper> mobLocaleOptionList = RegistrationFormCtrl.getMobileLocaleOptions();
      System.assert(
        mobLocaleOptionList.size() > 0,
        'No mobLocaleOptionList Found'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void sendRegistrationEmailOTPTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      String sentOTP = RegistrationFormCtrl.sendRegistrationEmailOTP(
        'test@mail.com'
      );
      System.assert(sentOTP != null, 'sentOTP must not be null');
    }
    Test.stopTest();
  }

  public class ReqMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{}');
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void loginExistingUserTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'OPE Catalogue'];
      Contact c = new Contact(LastName = 'Testing');
      insert c;
      User u = new User(
        Alias = 'standt',
        Email = 'testUser1234@test.com',
        EmailEncodingKey = 'UTF-8',
        lastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        ContactId = c.Id,
        Username = 'testUser1234@test.com.org',
        TimeZoneSidKey = 'Australia/Brisbane'
      );
      insert u;
      
      //Set user password
      String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
      String pwd = key.substring(0, 10) + 'AbC123';
      system.setPassword(u.id, pwd);
      update u;

      String page;
      page = RegistrationFormCtrl.loginExistingUser(
        u.Id,
        u.Username,
        '/study/s/'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void loginCorporateUserTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'];
      Contact c = new Contact(LastName = 'Testing');

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'uniqueEmail1' + uniqueID + '@test.com';
      
      insert c;

      User u = new User(
        Alias = 'test12',
        Email = emailTest,
        EmailEncodingKey = 'UTF-8',
        lastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        ContactId = c.Id,
        Username = 'testUser1234@test.com.org',
        TimeZoneSidKey = 'Australia/Brisbane'
      );
      insert u;

      List<User> isExist = RegistrationFormCtrl.loginCorporateUser(
        'testUserWorkEmail@test.com' , '123456'
      );
      System.assert(isExist == null , 'No user has been found');
    }
    Test.stopTest();
  }
  
  @isTest
  static void createAdministrativeAccountTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
      Id buyerGroup = [SELECT Id FROM BuyerGroup WHERE Name = 'OPE BuyerGroup' LIMIT 1].Id;

      List<Account> accounts;
      accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
          acc.RecordTypeId = ADMINISTRATIVE_ACC_RECTYPEID;
      }
      insert accounts;

      Id withAdministrativeAccount = RegistrationFormCtrl.createAdministrativeAccount(buyerGroup, accounts[0].Id, 'lastName', 'firstName');
      System.assert(withAdministrativeAccount != null , 'No administrative records, buyer accouunt, and buyer group member records was created');

      Id withoutAdministrativeAccount = RegistrationFormCtrl.createAdministrativeAccount(buyerGroup, null, 'lastName', 'firstName');
      System.assert(withoutAdministrativeAccount != null , 'No administrative records, buyer accouunt, and buyer group member records was created');
    }
    Test.stopTest();
  }

  @isTest
  static void workEmailConsentTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Contact c = new Contact(
        LastName = 'Test', 
        FirstName ='Contact 1',
        Email = 'testemail@test.com',
        Work_Email__c = 'testemailw@test.com',
        hed__Preferred_Email__c = 'Alternate Email',
        hed__AlternateEmail__c = 'testemail@test.com',
        Registered_Email__c = 'testemail@test.com',
        Work_Email_Opt_Out__c = true,
        RecordTypeId = PERSON
      );

      insert c;

      RegistrationFormCtrl.updateContact(
        c.Id, 
        'testemailw@test.com', 
        '0987654321', 
        'Australia (+61)', 
        'testing', 
        'testing',
        true
      );

      Contact contact = [SELECT Work_Email_Opt_Out__c, Work_Email_Opt_In_DateTime__c FROM Contact WHERE Work_Email__c = 'testemailw@test.com' LIMIT 1];
      System.assertEquals(false ,contact.Work_Email_Opt_Out__c , 'Work Email Opt out should be set to false.');
      System.assert(contact.Work_Email_Opt_In_DateTime__c != null , 'Work Email Opt out date time should be dated today.');
    }
    Test.stopTest();
  }

  @isTest
  static void staffEmailConsentTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Contact c = new Contact(
        LastName = 'Test', 
        FirstName ='Contact 1',
        Email = 'testemail@test.com',
        QUT_Staff_Email__c = 'testemails@test.com',
        hed__Preferred_Email__c = 'Alternate Email',
        hed__AlternateEmail__c = 'testemail@test.com',
        Registered_Email__c = 'testemail@test.com',
        Staff_Email_Opt_Out__c = true,
        RecordTypeId = PERSON
      );

      insert c;

      RegistrationFormCtrl.updateContact(
        c.Id, 
        'testemails@test.com', 
        '0987654321', 
        'Australia (+61)', 
        'testing', 
        'testing',
        true
      );

      Contact contact = [SELECT Staff_Email_Opt_Out__c, Staff_Email_Opt_In_DateTime__c FROM Contact WHERE QUT_Staff_Email__c = 'testemails@test.com' LIMIT 1];
      System.assertEquals(false ,contact.Staff_Email_Opt_Out__c , 'Staff Email Opt out should be set to false.');
      System.assert(contact.Staff_Email_Opt_In_DateTime__c != null , 'Staff Email Opt out date time should be dated today.');

    }
    Test.stopTest();
  }

  @isTest
  static void learnerEmailConsentTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Contact c = new Contact(
        LastName = 'Test', 
        FirstName ='Contact 1',
        Email = 'testemail@test.com',
        QUT_Learner_Email__c = 'testemaill@test.com',
        hed__Preferred_Email__c = 'Alternate Email',
        hed__AlternateEmail__c = 'testemail@test.com',
        Registered_Email__c = 'testemail@test.com',
        Learner_Email_Opt_Out__c = true,
        RecordTypeId = PERSON
      );

      insert c;

      RegistrationFormCtrl.updateContact(
        c.Id, 
        'testemaill@test.com', 
        '0987654321', 
        'Australia (+61)', 
        'testing', 
        'testing',
        true
      );

      Contact contact = [SELECT Learner_Email_Opt_Out__c, Learner_Email_Opt_In_DateTime__c FROM Contact WHERE QUT_Learner_Email__c = 'testemaill@test.com' LIMIT 1];
      System.assertEquals(false ,contact.Learner_Email_Opt_Out__c , 'Learner Email Opt out should be set to false.');
      System.assert(contact.Learner_Email_Opt_In_DateTime__c != null , 'Learner Email Opt out date time should be dated today.');
    }
    Test.stopTest();
  }

  @isTest
  static void emailConsentTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Contact c = new Contact(
        LastName = 'Test', 
        FirstName ='Contact 1',
        Email = 'testemail@test.com',
        hed__Preferred_Email__c = 'Alternate Email',
        hed__AlternateEmail__c = 'testemail@test.com',
        Registered_Email__c = 'testemail@test.com',
        HasOptedOutOfEmail = true,
        RecordTypeId = PERSON
      );

      insert c;

      RegistrationFormCtrl.updateContact(
        c.Id, 
        'testemail@test.com', 
        '0987654321', 
        'Australia (+61)', 
        'testing', 
        'testing',
        true
      );

      Contact contact = [SELECT HasOptedOutOfEmail, Email_Opt_In_DateTime__c FROM Contact WHERE Email = 'testemail@test.com' LIMIT 1];
      System.assertEquals(false ,contact.HasOptedOutOfEmail , 'Email Opt out should be set to false.');
      System.assert(contact.Email_Opt_In_DateTime__c != null , 'Email Opt out date time should be dated today.');
    }
    Test.stopTest();
  }

}