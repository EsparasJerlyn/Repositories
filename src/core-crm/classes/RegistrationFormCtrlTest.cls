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
 */
@isTest(SeeAllData=false)
public with sharing class RegistrationFormCtrlTest {
  public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Person')
    .getRecordTypeId();

  @isTest
  static void registerUserNoMatchTest() {
    UserRole userrole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    adminUser.UserRoleId = userRole.Id;
    adminUser.IsActive = true;
    update adminUser;
    Test.startTest();
    System.runAs(adminUser) {
      Account testAccount = new Account();
      testAccount.Name = 'OPE Catalogue';
      insert testAccount;

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      String page = RegistrationFormCtrl.registerUser(
        'Test',
        'User',
        emailTest,
        '12345',
        1,
        1,
        1999,
        'testDietary Req',
        '/study/s/'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserExactMatchTest() {
    UserRole userrole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    adminUser.UserRoleId = userRole.Id;
    adminUser.IsActive = true;
    update adminUser;
    Test.startTest();
    System.runAs(adminUser) {
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
        '12345',
        1,
        1,
        1999,
        'testDietary Req',
        '/study/s/'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserMultipleMatchTest() {
    UserRole userrole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    adminUser.UserRoleId = userRole.Id;
    adminUser.IsActive = true;
    update adminUser;
    Test.startTest();
    System.runAs(adminUser) {
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
        '12345',
        1,
        1,
        1999,
        'testDietary Req',
        '/study/s/'
      );
      System.assert(page == null, 'Page must not be null');
    }
    Test.stopTest();
  }

  @isTest
  static void isEmailExistTest() {
    UserRole userrole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    adminUser.UserRoleId = userRole.Id;
    adminUser.IsActive = true;
    update adminUser;
    Test.startTest();
    System.runAs(adminUser) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Ecommerce Learner'];
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
      Boolean isExist = RegistrationFormCtrl.isEmailExist(
        'testUser1234@test.com'
      );
      System.assert(isExist == true, 'Email is match');
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
  static void getOPEProductCategTest() {
    UserRole userrole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    adminUser.UserRoleId = userRole.Id;
    adminUser.IsActive = true;
    update adminUser;

    Test.startTest();
    System.runAs(adminUser) {
      ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
      insert prodCatalog;

      ProductCategory prodCateg = new ProductCategory(
        Name = 'Products',
        CatalogId = prodCatalog.Id
      );
      insert prodCateg;

      ProductCategory prodCategResult = RegistrationFormCtrl.getOPEProductCateg();

      System.assert(
        prodCategResult != null,
        'prodCategResult must not be null'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void sendRegistrationSMSOTPTest() {
    UserRole userrole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    adminUser.UserRoleId = userRole.Id;
    adminUser.IsActive = true;
    update adminUser;
    Test.startTest();
    System.runAs(adminUser) {
      Test.setMock(HttpCalloutMock.class, new reqMockHttpResponse());

      String sentOTP = RegistrationFormCtrl.sendRegistrationSMSOTP('12345678');

      System.assert(sentOTP != null, 'sentOTP must not be null');
    }
    Test.stopTest();
  }

  public class reqMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{}');
      res.setStatusCode(200);
      return res;
    }
  }
}
