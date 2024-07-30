/**
 * @description Test Class for CartItemCtrl
 * @see ../lwc/CartItemCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.m.tambasen           | Jun 4 , 2022          | DEPP-787             | Created file                 |
      |                           |                       |                      |                              |
 */
@isTest
public with sharing class PaymentConfirmationCtrlTest {

  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

  @testSetup
  static void setupMethod() {
    BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
    insert bypass;
    Test.startTest();
    TestDataFactoryUser.generateUserSystemAdministrator();
    Test.stopTest();
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    //create account
    List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
    accounts[0].RecordTypeId = ACCT_UNIV_DEP_ID;
    accounts[0].Organization_Unit_Level__c = '2';
    insert accounts;

    //create contact
    List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
    contacts[0].AccountId = accounts[0].Id;
    insert contacts;

    //run this bloack as system admin
    System.runAs(PORTAL_SYS_ADMIN) {
      //Create account
      Account portalAccount1 = new Account(
        Name = 'TestAccount',
        OwnerId = PORTAL_SYS_ADMIN.Id
      );
      insert portalAccount1;
          
      //Create contact
      Contact contact1 = new Contact(
      FirstName = 'JM',
      Lastname = 'Testing',
      AccountId = portalAccount1.Id,
      Email = System.now().millisecond() + 'jm@test.com'
      );
      insert contact1;
          
      //Create user
      Profile portalProfile = [select Id from Profile where Name = 'QUT Experience' limit 1];
      User user1 = new User(
        Username = System.now().millisecond() + 'jm3@test.com',
        ContactId = contact1.Id,
        ProfileId = portalProfile.Id,
        Alias = 'JMT3',
        Email = 'jm@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'McTesty',
        CommunityNickname = 'test12345',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US'
      );
      insert user1;
    }

    List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
      10,
      accounts[0].Id
    );
    insert terms;

    List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
      1
    );
    insert prodRequest;

    List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
      10,
      accounts[0].Id,
      prodRequest[0].Id
    );
    insert courses;

    List<Product2> products = TestDataFactory.createTestProductRecords(
      10,
      courses
    );
    insert products;

    List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
      10,
      courses,
      terms
    );
    insert courseOfferings;
    
    List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
      10
    );
    insert programPlans;

    List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(
      10,
      programPlans
    );
    insert programOffs;

    hed__Course_Offering__c newOffering = new hed__Course_Offering__c(Program_Offering__c = programOffs[0].Id, 
          hed__Course__c = courses[0].id,
          hed__Term__c = terms[0].id,
          hed__Start_Date__c = system.today() + 2,
          hed__Capacity__c = 10);

          insert newOffering;
    Pricebook2 priceBook = new Pricebook2(
      isActive = true,
      id = Test.getStandardPricebookId()
    );
    update pricebook;

    Pricebook2 priceBook2 = new Pricebook2(
      isActive = true,
      Name = 'Current Learner'
    );
    insert priceBook2;

    Pricebook2 priceBook3 = new Pricebook2(
      isActive = true,
      Name = 'Current Staff'
    );
    insert priceBook3;

    PricebookEntry priceBookEntry = new PricebookEntry(
      pricebook2id = pricebook.Id,
      UnitPrice = 123,
      product2Id = products[0].id
    );
    insert priceBookEntry;

    PricebookEntry priceBookEntry2 = new PricebookEntry(
      pricebook2id = pricebook2.Id,
      UnitPrice = 456,
      product2Id = products[0].id
    );
    insert priceBookEntry2;

    PricebookEntry priceBookEntry3 = new PricebookEntry(
      pricebook2id = pricebook3.Id,
      UnitPrice = 789,
      product2Id = products[0].id
    );
    insert priceBookEntry3;

    PricebookEntry priceBookEntry4 = new PricebookEntry(
      pricebook2id = pricebook.Id,
      UnitPrice = 999,
      product2Id = products[1].id
    );
    insert priceBookEntry4;

    WebStore testWebStore = new WebStore(
      Name = 'Study',
      DefaultLanguage = 'en_US'
    );
    insert testWebStore;

    WebCart cart = new WebCart(
      Name = 'Cart',
      AccountId = accounts[0].Id,
      Status__c = 'Checkout',
      WebStoreId = testWebStore.Id,
      External_Id__c = '6894b2af-cb62-86f5-7d21-7b54e9df96e5',
      Payment_Method__c = 'Pay Now'
    );
    insert cart;

    CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
      CartId = cart.Id,
      Name = 'Default Delivery'
    );
    insert cartDeliveryGroup;

    CartItem cartItem = new CartItem(
      CartId = cart.Id,
      Name = 'TestProductCourse',
      Product2Id = products[0].id,
      Course_Offering__c = courseOfferings[0].id,
      CartDeliveryGroupId = cartDeliveryGroup.Id,
      Pricebook_Entry_ID__c = priceBookEntry.Id
    );
    insert cartItem;

    CartItem cartItem2 = new CartItem(
      CartId = cart.Id,
      Name = 'TestProductCourse2',
      Product2Id = products[0].id,
      Course_Offering__c = courseOfferings[1].id,
      CartDeliveryGroupId = cartDeliveryGroup.Id,
      Pricebook_Entry_ID__c = priceBookEntry2.Id
    );
    insert cartItem2;

    CartItem cartItem3 = new CartItem(
      CartId = cart.Id,
      Name = 'TestProductCourse3',
      Product2Id = products[0].id,
      Course_Offering__c = courseOfferings[2].id,
      CartDeliveryGroupId = cartDeliveryGroup.Id,
      Pricebook_Entry_ID__c = priceBookEntry3.Id
    );
    insert cartItem3;

    CartItem cartItem4 = new CartItem(
      CartId = cart.Id,
      Name = 'TestProductProgram',
      Product2Id = products[1].id,
      Program_Offering__c = programOffs[0].id,
      CartDeliveryGroupId = cartDeliveryGroup.Id,
      Pricebook_Entry_ID__c = priceBookEntry4.Id
    );
    insert cartItem4;

    ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
    insert prodCatalog;

    ProductCategory prodCateg = new ProductCategory(
      Name = 'Products',
      CatalogId = prodCatalog.Id
    );
    insert prodCateg;
  }

  @isTest
  static void getCartDataTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
		System.runAs(PORTAL_SYS_ADMIN) {
      WebCart webC = [
        SELECT Id, External_Id__c, OwnerId
        FROM WebCart
        LIMIT 1
      ];

      PaymentConfirmationCtrl.CartData cartDataWrapper = new PaymentConfirmationCtrl.CartData();

      Test.startTest();
      cartDataWrapper = PaymentConfirmationCtrl.getCartData(
        webC.External_Id__c,
        webC.OwnerId
      );
      Test.stopTest();

      System.assertNotEquals(
        null,
        cartDataWrapper,
        'There should be a returned object data'
      );
    }
  }

  @isTest
  static void checkCartOwnerShipTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
		System.runAs(PORTAL_SYS_ADMIN) {
      WebCart cart = [SELECT Id, OwnerId, Name, External_Id__c FROM WebCart LIMIT 1];
        
      Test.startTest();
      Boolean isOwned = PaymentConfirmationCtrl.checkCartOwnerShip(
        cart.External_Id__c,
        cart.OwnerId
      );
      Test.stopTest();

      System.assert(
        isOwned,
        'Cart should be owned by user'
      );
    }
  }

  /*@isTest
  static void createCourseConnectionTest() {

    WebCart webCart = [
      SELECT 
        Id, 
        Name 
      FROM WebCart 
      LIMIT 1
    ];

    User userTest = [
      SELECT Id, ContactId
      FROM User
      WHERE ContactId != NULL
      LIMIT 1
    ];

    Test.startTest();

    PaymentConfirmationCtrl.createCourseConnection(webCart.Id, userTest.Id, 100, '6894b2af-cb62-86f5-7d21-7b54e9df96e5', 'Pay Now', 'Yes');

    Test.stopTest();

    System.assert(![SELECT Id FROM hed__Course_Enrollment__c LIMIT 1].isEmpty(), 'hed__Course_Enrollment__c record not inserted');

  }*/

  @isTest
  static void updateWebCartTest() {
  final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
		System.runAs(PORTAL_SYS_ADMIN) {
    WebCart webCart = [
      SELECT 
        Id, 
        Name 
      FROM WebCart 
      LIMIT 1
    ];

    Test.startTest();
    PaymentConfirmationCtrl.updateWebCart(webCart.Id, 'Approved', '123Invoice', '456Receipt', 100, 'https://testurl.com', 'testtest@email.com');
    Test.stopTest();

    WebCart webCartUpdated = [
      SELECT 
        Id, 
        Name,
        Status
      FROM WebCart 
      LIMIT 1
    ];

    System.assertEquals('Closed', webCartUpdated.Status, 'Cart Status should be closed');
    }
  }
}