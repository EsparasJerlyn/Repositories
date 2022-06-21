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
 */
@isTest(SeeAllData=false)
public with sharing class RegistrationFormCtrlTest {
  public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Person')
    .getRecordTypeId();
  private static final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();

  @testSetup
  public static void setUp() {
    // Create Custom Setting
    MC_Messaging_OTP_Setting__c setting = TestDataFactory.createOTPCustomSetting();
    insert setting;
  }

  @isTest
  static void registerUserNoMatchTest() {
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
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
        'Australia (+61)'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserExactMatchTest() {
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Account testAccount = new Account();
      testAccount.Name = 'OPE Catalogue';
      insert testAccount;

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      Contact testContact = new Contact();
      testContact.Birthdate = Date.newInstance(1999, 1, 1);
      testContact.Email = emailTest;
      testContact.LastName = 'User';
      testContact.RecordTypeId = PERSON;
      insert testContact;

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
        'Australia (+61)'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserMultipleMatchTest() {
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Account testAccount = new Account();
      testAccount.Name = 'OPE Catalogue';
      insert testAccount;

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

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

      testContact2.Email = emailTest;
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
        'Australia (+61)'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void isEmailExistTest() {
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
      List<User> isExist = RegistrationFormCtrl.isEmailExist(
        'testUser1234@test.com'
      );
      System.assert(isExist.size() > 0, 'Email is match');
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

    Test.startTest();
    RegistrationFormCtrl.CommunityWrapper comData = RegistrationFormCtrl.getCommunityUrl();
    Test.stopTest();
    System.assert(comData != null, 'No Community Data Found');
  }

  @isTest
  static void sendRegistrationSMSOTPTest() {
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Test.setMock(HttpCalloutMock.class, new ReqMockHttpResponse());

      String sentOTP = RegistrationFormCtrl.sendRegistrationSMSOTP('12345678');

      System.assert(sentOTP != null, 'sentOTP must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void getMobileLocaleOptionsTest() {
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
}
