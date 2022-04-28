/**
 * @description Tests the Product Details Controller Test Class
 *
 * @see ProductDetailsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                     |
      |---------------------------|-----------------------|-----------|----------------------------------------------------|
      | roy.nino.s.regala         | December 10, 2021     | DEPP116   | Created file                                       |
      | roy.nino.s.regala         | December 27, 2021     | DEPP1028  | Added testmethod for insertLearnerInfo             |
      | roy.nino.s.regala         | February 04, 2022     | DEPP213   | Added testmethod for insert Expression of Interest |
      | john.bo.a.pineda          | April 26, 2022        | DEPP-1211 | Updated logic for new UI                           |
*/
@isTest(SeeAllData=false)
private class ProductDetailsCtrlTest {
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
    .getRecordTypeId();

  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @testSetup
  static void setupMethod() {
    System.runAs(currentUser) {
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      contacts[0]
        .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_snowtops.jpg" alt="test.jpg"></img></p>';
      insert contacts;

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
      for (Product2 prod : products) {
        prod.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
      }
      insert products;

      Pricebook2 pricebook = new Pricebook2(
        isActive = true,
        id = Test.getStandardPricebookId()
      );
      update pricebook;

      List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
      for (Product2 prodPBEntry : products) {
        PricebookEntry priceBookEntry = new PricebookEntry();
        priceBookEntry.pricebook2id = pricebook.Id;
        priceBookEntry.UnitPrice = 12;
        priceBookEntry.product2Id = prodPBEntry.Id;
        priceBookEntry.isActive = true;
        priceBookEntryList.add(priceBookEntry);
      }
      insert priceBookEntryList;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        10,
        courses,
        terms
      );
      for (hed__Course_Offering__c cOffering : courseOfferings) {
        cOffering.Registration_Start_Date__c = system.today() + 2;
        cOffering.IsActive__c = true;
        cOffering.Delivery_Type__c = 'Online Classroom';
      }
      insert courseOfferings;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );
      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = FACULTY_RECTYPEID;
      }
      insert courseConnections;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
        10
      );
      insert programPlans;

      List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(
        10,
        programPlans
      );
      insert programOffs;

      WebStore testWebStore = new WebStore(
        Name = 'Study',
        DefaultLanguage = 'en_US'
      );
      insert testWebStore;

      WebCart cart = new WebCart(
        Name = 'Cart',
        AccountId = accounts[0].Id,
        Status = 'Active',
        WebStoreId = testWebStore.Id
      );
      insert cart;

      CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
        CartId = cart.Id,
        Name = 'Default Delivery'
      );
      insert cartDeliveryGroup;

      Test.stopTest();
    }
  }

  @isTest
  static void testGetProductRelatedRecords() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      Test.startTest();

      ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
      getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(
        [SELECT Id FROM Product2 WHERE CreatedById = :currUsr.Id LIMIT 1]
        .Id
      );

      Test.stopTest();

      System.assert(
        getProductDetails != null,
        'Successfully retrieved Product Related Records'
      );
    }
  }

  @isTest
  static void testGetCourseOfferingRelatedRecords() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      Test.startTest();

      List<ProductDetailsCtrl.CourseOfferingWrapper> getCourseOfferings = new List<ProductDetailsCtrl.CourseOfferingWrapper>();
      getCourseOfferings = ProductDetailsCtrl.getCourseOfferingRelatedRecords(
        [
          SELECT Id, Course__c
          FROM Product2
          WHERE CreatedById = :currUsr.Id
          LIMIT 1
        ]
        .Course__c,
        new List<String>{ 'Online Classroom' }
      );

      Test.stopTest();

      System.assert(
        getCourseOfferings.size() > 0,
        'Successfully retrieved Course Offering Related Records'
      );
    }
  }

  @isTest
  static void testAddToCart() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      Test.startTest();
      String communityId = [
        SELECT Id
        FROM Network
        WHERE Name = 'Study' AND Status = 'Live'
      ]
      .Id;

      String effectiveAccountId = [
        SELECT Id
        FROM Account
        WHERE CreatedById = :currUsr.Id
        LIMIT 1
      ]
      .Id;

      Product2 prod = [
        SELECT
          Id,
          Name,
          Course__c,
          (SELECT Id FROM PricebookEntries WHERE IsActive = TRUE)
        FROM Product2
        WHERE CreatedById = :currUsr.Id
        LIMIT 1
      ];
      String productId = prod.Id;
      String productName = prod.Name;
      String pricebookEntryId = prod.PricebookEntries[0].Id;

      String courseOfferingId = [
        SELECT Id
        FROM hed__Course_Offering__c
        WHERE hed__Course__c = :prod.Course__c
        LIMIT 1
      ]
      .Id;

      ProductDetailsCtrl.addToCartItem(
        communityId,
        productId,
        effectiveAccountId,
        productName,
        courseOfferingId,
        pricebookEntryId
      );
      Test.stopTest();
    }
  }

  /* @isTest
  static void testInsertLearnerInfo() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      Test.startTest();
      List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>(
        [SELECT Id FROM hed__Course_Offering__c LIMIT 1]
      );
      List<Contact> contacts = TestDataFactory.createTestContactRecords(100);

      ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
      wrappedData.courseOfferingId = courseOffering[0].Id;

      ProductDetailsCtrl.insertLearnerInfo(contacts, wrappedData);
      System.assert(
        ![SELECT ID FROM Contact].isEmpty(),
        'has no contacts created'
      );
      System.assert(
        ![SELECT ID FROM hed__Course_Enrollment__c].isEmpty(),
        'has no contact enrollement created'
      );
    }
    Test.stopTest();
  } */

  /* @isTest
  static void testInsertExpressionOfInterest() {
    UserRole portalRole = [
      SELECT Id
      FROM UserRole
      WHERE PortalType = 'None'
      LIMIT 1
    ];
    Profile profile1 = [
      SELECT Id
      FROM Profile
      WHERE name = 'System Administrator'
    ];
    User portalAccountOwner1 = new User(
      UserRoleId = portalRole.Id,
      ProfileId = profile1.Id,
      Username = System.now().millisecond() + 'Admin1@test.com',
      Alias = 'batman',
      Email = 'bruce.wayne@wayneenterprises.com',
      EmailEncodingKey = 'UTF-8',
      Firstname = 'Bruce',
      Lastname = 'Wayne',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Chicago'
    );
    Database.insert(portalAccountOwner1);

    System.runAs(portalAccountOwner1) {
      //Create account
      Account portalAccount1 = new Account(
        Name = 'TestAccount',
        OwnerId = portalAccountOwner1.Id
      );
      Database.insert(portalAccount1);

      //Create contact
      Contact contact1 = new Contact(
        FirstName = 'Test',
        Lastname = 'McTesty',
        AccountId = portalAccount1.Id,
        Email = System.now().millisecond() + 'test@test.com'
      );
      Database.insert(contact1);

      //Create user
      User portalUser = TestDataFactory.createPortalUserRecords(
          1,
          'Corporate Partner User',
          contact1.Id
        )
        .iterator()
        .next();
      Database.insert(portalUser);

      Product2 product = [SELECT Id FROM Product2 LIMIT 1];
      Test.startTest();

      ProductDetailsCtrl.insertExpressionOfInterest(portalUser.Id, product.Id);
      System.assert(
        ![SELECT Id FROM Expression_of_interest__c].isEmpty(),
        'No expression of interest created'
      );

      Test.stopTest();
    }

  } */
}
