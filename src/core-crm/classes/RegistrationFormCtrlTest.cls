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
      | arsenio.jr.dayrit         | December 16, 2022     | DEPP-4907            | Update UpdateContactTest     |

 */
@isTest
public with sharing class RegistrationFormCtrlTest {
  public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Person')
    .getRecordTypeId();

  private static final Id ADMINISTRATIVE_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();

  @testSetup
  public static void setUp() {
    TestDataFactoryUser.generateUserSystemAdministrator();
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      RegistrationFormCtrl.RegistrationDataWrapper registrationData = new RegistrationFormCtrl.RegistrationDataWrapper();
      RegistrationFormCtrl.BirthDateWrapper birthDateData = new RegistrationFormCtrl.BirthDateWrapper();
      Contact contactRecord = new Contact();

      contactRecord.FirstName = 'Test';
      contactRecord.LastName = 'User';
      contactRecord.Registered_Email__c = emailTest;
      contactRecord.MobilePhone = '611234567890';
      contactRecord.Dietary_Requirement__c = 'testDietary Req';
      contactRecord.Accessibility_Requirement__c = 'access Req';
      contactRecord.Id = null;
      contactRecord.Mobile_No_Locale__c = '1234567890';
      contactRecord.ContactMobile_Locale__c = 'Australia (+61)';

      registrationData.startURL = '/study/s/';
      registrationData.isOptIn = true;
      registrationData.contactRecord = contactRecord;

      birthDateData.day =1;
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
  static void registerUserExactMatchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {

      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      Contact testContact = new Contact();
      testContact.Birthdate = Date.newInstance(1999, 1, 1);
      testContact.Email = emailTest;
      testContact.FirstName = 'Test001';
      testContact.LastName = 'User001';
      testContact.RecordTypeId = PERSON;
      insert testContact;


      RegistrationFormCtrl.RegistrationDataWrapper registrationData = new RegistrationFormCtrl.RegistrationDataWrapper();
      RegistrationFormCtrl.BirthDateWrapper birthDateData = new RegistrationFormCtrl.BirthDateWrapper();
      Contact contactRecord = new Contact();

      contactRecord.FirstName = 'Test001';
      contactRecord.LastName = 'User001';
      contactRecord.Registered_Email__c = emailTest;
      contactRecord.MobilePhone = '611234567890';
      contactRecord.Dietary_Requirement__c = 'testDietary Req';
      contactRecord.Accessibility_Requirement__c = 'access Req';
      contactRecord.Id = testContact.Id;
      contactRecord.Mobile_No_Locale__c = '1234567890';
      contactRecord.ContactMobile_Locale__c = 'Australia (+61)';

      registrationData.startURL = '/study/s/';
      registrationData.isOptIn = true;
      registrationData.contactRecord = contactRecord;

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
  static void isUserExistTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'QUT Experience'];
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      
      Contact c = new Contact(
                              LastName = 'Testing01', 
                              FirstName ='Testing01',
                              Email = 'test12345@sample.com',
                              RecordTypeId = PERSON
                              );
      insert c;


      RegistrationFormCtrl.RegistrationDataWrapper registrationData = new RegistrationFormCtrl.RegistrationDataWrapper();
      Contact contactRecord = new Contact();

      contactRecord.FirstName = 'Test';
      contactRecord.LastName = 'User';
      contactRecord.Registered_Email__c = 'test12345@sample.com';
      contactRecord.Email = 'test12345@sample.com';
      contactRecord.MobilePhone = '611234567890';
      contactRecord.Dietary_Requirement__c = 'testDietary Req';
      contactRecord.Accessibility_Requirement__c = 'access Req';
      contactRecord.Id = c.Id;
      contactRecord.Mobile_No_Locale__c = '1234567890';
      contactRecord.ContactMobile_Locale__c = 'Australia (+61)';

      registrationData.startURL = '/study/s/';
      registrationData.isOptIn = true;
      registrationData.contactRecord = contactRecord;


      RegistrationFormCtrl.updateContact(
        JSON.serialize(registrationData),
        false
      );
      String accessibilityReq = [SELECT Accessibility_Requirement__c FROM Contact WHERE Id =: c.Id]?.Accessibility_Requirement__c;

      System.assert(accessibilityReq != null, 'The contact details is not updated');
    }
    Test.stopTest();
  }

  
  @isTest
  static void updateContactNoEmailTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      TestDataFactory.loadEDATriggers();
        
      Contact c = new Contact(
                              LastName = 'Testing01', 
                              FirstName ='Testing01',
                              Work_Email__c = 'test_work@email.com',
                              QUT_Staff_Email__c = 'test_staff@email.com',
                              QUT_Learner_Email__c = 'test_learner@email.com',
                              RecordTypeId = PERSON
                              );
      insert c;

      RegistrationFormCtrl.RegistrationDataWrapper registrationData = new RegistrationFormCtrl.RegistrationDataWrapper();
      Contact contactRecord = new Contact();

      contactRecord.FirstName = 'Test';
      contactRecord.LastName = 'User';
      contactRecord.Registered_Email__c = 'test_work@email.com';
      contactRecord.Email = 'test12345@sample.com';
      contactRecord.MobilePhone = '611234567890';
      contactRecord.Dietary_Requirement__c = 'testDietary Req';
      contactRecord.Accessibility_Requirement__c = 'access Req';
      contactRecord.Id = c.Id;
      contactRecord.Mobile_No_Locale__c = '1234567890';
      contactRecord.ContactMobile_Locale__c = 'Australia (+61)';

      registrationData.startURL = '/study/s/';
      registrationData.isOptIn = true;
      registrationData.contactRecord = contactRecord;


      RegistrationFormCtrl.updateContact(
        JSON.serialize(registrationData),
        true        
      );
                                          
      String email = [SELECT Email FROM Contact WHERE id =: c.Id]?.Email;
      System.assertEquals('test12345@sample.com', email, 'The contact details is not updated');
    }
    Test.stopTest();
  }


  @isTest
  static void isEmailExistTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      
      Profile pCEE = [SELECT Id FROM Profile WHERE Name = 'Corporate Partner'];
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
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

      RegistrationFormCtrl.CommunityWrapper comData = RegistrationFormCtrl.getCommunityUrl();
  
      System.assert(comData != null, 'No Community Data Found');
      Test.stopTest();
    }
  }

  @isTest
  static void sendRegistrationSMSOTPTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      String uniqueID = GenerateUniqueId.getUUID();
      String emailTest = 'testUser' + uniqueID + '@test.com';

      Contact testContact = new Contact();
      testContact.Birthdate = Date.newInstance(1999, 1, 1);
      testContact.ContactMobile_Locale__c  = 'Australia (+61)';
      testContact.Email = emailTest;
      testContact.LastName = 'User';
      insert testContact;

      String getMLocale = RegistrationFormCtrl.getUserMobileLocale(testContact.Id);
      System.assert(getMLocale != null, 'User has no mobile locale.');
    Test.stopTest();
    }
  }

  @isTest
  static void getMobileLocaleOptionsTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'QUT Experience'];
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
      String pwd = key.substring(0, 10) + 'AbC123!';
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Corporate Partner'];
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN) {
      Id buyerGroup = [SELECT Id FROM BuyerGroup WHERE Name = 'OPE BuyerGroup' LIMIT 1].Id;

      List<Account> accounts;
      accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
          acc.RecordTypeId = ADMINISTRATIVE_ACC_RECTYPEID;
      }
      insert accounts;

      RegistrationFormCtrl.AdminAccountDetails adminAcc = new RegistrationFormCtrl.AdminAccountDetails();
      adminAcc.buyerGroupId = buyerGroup;
      adminAcc.accountId = accounts[0].Id;
      adminAcc.lastName = 'lastName';
      adminAcc.firstName = 'firstName';
      Id withAdministrativeAccount = RegistrationFormCtrl.createAdministrativeAccount(adminAcc);
      System.assert(withAdministrativeAccount != null , 'No administrative records, buyer accouunt, and buyer group member records was created');

      adminAcc.accountId = null;
      Id withoutAdministrativeAccount = RegistrationFormCtrl.createAdministrativeAccount(adminAcc);
      System.assert(withoutAdministrativeAccount != null , 'No administrative records, buyer accouunt, and buyer group member records was created');
    }
    Test.stopTest();
  }



}