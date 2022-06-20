/**
 * @description Test Class for CartItemCtrl
 * @see ../lwc/CartItemCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.m.tambasen           | May 11, 2022          | DEPP-2060            | Created file                 |
      |                           |                       |                      |                              |
 */
@isTest(SeeAllData=false)
public with sharing class CartItemCtrlTest {

  private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe().getLocalName();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
  private static final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();

  @TestSetup
  static void setupMethod() {
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
      Profile portalProfile = [select Id from Profile where UserType = 'PowerPartner' limit 1];
      User user1 = new User(
        Username = System.now().millisecond() + 'jm2@test.com',
        ContactId = contact1.Id,
        ProfileId = portalProfile.Id,
        Alias = 'JMT2',
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

  

    List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
      10
    );
    insert programPlans;

    List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(
      10,
      programPlans
    );
    insert programOffs;

    List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
      10,
      courses,
      terms
    );
    courseOfferings[0].Program_Offering__c = programOffs[0].Id;
    insert courseOfferings;

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

    WebStore testWebStore = new WebStore(
      Name = 'CCE',
      DefaultLanguage = 'en_US'
    );
    insert testWebStore;

    WebCart cart = new WebCart(
      Name = 'Cart',
      AccountId = accounts[0].Id,
      Status__c = 'Checkout',
      WebStoreId = testWebStore.Id
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
      Name = 'TestProductCourse4',
      Product2Id = products[0].id,
      Program_Offering__c = programOffs[0].Id,
      CartDeliveryGroupId = cartDeliveryGroup.Id,
      Pricebook_Entry_ID__c = priceBookEntry3.Id
    );
    insert cartItem4;

    //for registration questions setup
    Questionnaire__c questionnaire = new Questionnaire__c(
      Questionnaire_Type__c = 'Registration Questions',
      Parent_Record_ID__c =  prodRequest[0].Id,
      Object_Type__c = PRODUCT_API_NAME
    );
    insert questionnaire;

    //create questions
    List<Question__c> questions = new List<Question__c>();
    Question__c question1 = new Question__c(
      Label__c = 'Question 1',
      Type__c = 'Text'
    );
    Question__c question2 = new Question__c(
      Label__c = 'Question 2',
      Type__c = 'Checkbox'
    );
    Question__c question3 = new Question__c(
      Label__c = 'Question 3',
      Type__c = 'Picklist',
      Dropdown_Options__c = 'option1;option2;option3'
    );
    Question__c question4 = new Question__c(
      Label__c = 'Question 4',
      Type__c = 'Multi-Select Picklist',
      Dropdown_Options__c = 'multioption1;multioption2;multioption3'
    );
    Question__c question5 = new Question__c(
      Label__c = 'Question 5',
      Type__c = 'File Upload'
    );
    questions.add(question1);
    questions.add(question2);
    questions.add(question3);
    questions.add(question4);
    questions.add(question5);
    insert questions;

    User userTest = [
      SELECT Id, ContactId
      FROM User
      WHERE ContactId != NULL
      LIMIT 1
    ];

    Questionnaire_Response_Summary__c questionnaireResponse = new Questionnaire_Response_Summary__c(
      Contact__c = userTest.ContactId,
      Questionnaire__c = questionnaire.Id
    );
    insert questionnaireResponse;

    //create related answers
    List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(
      5,
      questionnaire.Id,
      questions
    );
    insert relatedAnswers;

    //create answers
    List<Answer__c> answers = new List<Answer__c>();
    Answer__c answer1 = new Answer__c(
      Related_Answer__c = relatedAnswers[0].Id,
      Questionnaire_Response_Summary__c = questionnaireResponse.Id,
      Response__c = 'Text response'
    );
    Answer__c answer2 = new Answer__c(
      Related_Answer__c = relatedAnswers[1].Id,
      Questionnaire_Response_Summary__c = questionnaireResponse.Id,
      Response__c = 'true'
    );
    Answer__c answer3 = new Answer__c(
      Related_Answer__c = relatedAnswers[2].Id,
      Questionnaire_Response_Summary__c = questionnaireResponse.Id,
      Response__c = 'option1'
    );
    Answer__c answer4 = new Answer__c(
      Related_Answer__c = relatedAnswers[3].Id,
      Questionnaire_Response_Summary__c = questionnaireResponse.Id,
      Response__c = 'multioption1'
    );
    Answer__c answer5 = new Answer__c(
      Related_Answer__c = relatedAnswers[4].Id,
      Questionnaire_Response_Summary__c = questionnaireResponse.Id,
      Response__c = '069123123123'
    );
    answers.add(answer1);
    answers.add(answer2);
    answers.add(answer3);
    answers.add(answer4);
    answers.add(answer5);
    insert answers;

    //for coupons
    List<Promotion> promotionList = new List<Promotion>();
    Promotion promotion1 = new Promotion(
      Name = 'Test Promotion',
      isActive = true
    );
    Promotion promotion2 = new Promotion(
      Name = 'Test Promotion2',
      isActive = true
    );
    promotionList.add(promotion1);
    promotionList.add(promotion2);
    insert promotionList;

    List<PromotionTarget> promotionTargetList = new List<PromotionTarget>();
    PromotionTarget promotionTarget1 = new PromotionTarget(
      PromotionId = promotionList[0].Id,
      TargetType = 'Product',
      TargetId = products[0].id,
      AdjustmentType = 'FixedAmountOffUnitPrice',
      AdjustmentAmount = 123
    );
    PromotionTarget promotionTarget2 = new PromotionTarget(
      PromotionId = promotionList[1].Id,
      TargetType = 'Product',
      TargetId = products[0].id,
      AdjustmentType = 'PercentageDiscount',
      AdjustmentPercent = 50
    );
    promotionTargetList.add(promotionTarget1);
    promotionTargetList.add(promotionTarget2);
    insert promotionTargetList;

    List<Coupon> couponList = new List<Coupon>();
    Coupon coupon1 = new Coupon(
      PromotionId = promotionList[0].Id,
      CouponCode = 'TESTCOUP',
      status = 'Active',
      StartDateTime = System.now() - 1,
      EndDateTime = System.now() + 1
    );
    Coupon coupon2 = new Coupon(
      PromotionId = promotionList[1].Id,
      CouponCode = 'TESTCOUP2',
      status = 'Active',
      StartDateTime = System.now() - 1,
      EndDateTime = System.now() + 1
    );
    couponList.add(coupon1);
    couponList.add(coupon2);
    insert couponList;

    ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
    insert prodCatalog;

    ProductCategory prodCateg = new ProductCategory(
      Name = 'Products',
      CatalogId = prodCatalog.Id
    );
    insert prodCateg;
  }

  @IsTest
  static void getCartItemsTest() {
    WebCart cart = [SELECT Id, Name FROM WebCart LIMIT 1];
    User userTest = [
      SELECT Id, ContactId
      FROM User
      WHERE ContactId != NULL
      LIMIT 1
    ];
    CartItemCtrl.CartItemsData cartItemsDataWrapper = new CartItemCtrl.CartItemsData();

    Test.startTest();
    cartItemsDataWrapper = CartItemCtrl.getCartItemsByCart(
      cart.Id,
      userTest.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      cartItemsDataWrapper,
      'There should be a returned object data'
    );
  }

  @isTest
  static void createCourseConnectionTest(){
    List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 1]);
    List<CartItem> cartItemList = new List<CartItem>([SELECT Id FROM CartItem LIMIT 10]);
    List<String> cartItems = new List<String>{cartItemList[0].Id};
    Test.startTest();

    CartItemCtrl.createCourseConnection(cartItems,contactList[0].Id,'Yes','Pay Now');

    Test.stopTest();

    System.assert(![SELECT Id FROM hed__Course_Enrollment__c LIMIT 1].isEmpty(),'No course connection created');
  }


  @isTest
  static void checkCartOwnerShipTest(){
    List<WebCart> webcarts = new List<WebCart>([SELECT Id, OwnerId FROM WebCart Limit 1]);
    Boolean owned;
    Test.startTest();

    owned = CartItemCtrl.checkCartOwnerShip(webcarts[0].Id,webcarts[0].OwnerId);

    Test.stopTest();

    System.assert(owned, 'user do not own the cart');
  }

  @IsTest
  static void getCartItemDiscountTest() {
    WebCart cart = [SELECT Id, Name FROM WebCart LIMIT 1];

    Double discount;
    Double discount2;

    Test.startTest();
    discount = CartItemCtrl.getCartItemDiscount(
      cart.Id,
      'TESTCOUP',
      1000
    );
    discount2 = CartItemCtrl.getCartItemDiscount(
      cart.Id,
      'TESTCOUP2',
      2000
    );
    Test.stopTest();

    System.assert(discount !=null,  'Incorrect calculation');
    System.assert(discount2 !=null ,  'Incorrect calculation');
  }

  @IsTest
  static void updateCartStatusTest() {
    WebCart webCart = [SELECT Id, Name FROM WebCart LIMIT 1];

    Test.startTest();
    CartItemCtrl.updateCartStatus(webCart.Id, 'Checkout');
    Test.stopTest();
  }

  @IsTest
  static void closeCartTest() {
    WebCart webCart = [SELECT Id, Name, Status FROM WebCart LIMIT 1];

    Test.startTest();
    CartItemCtrl.closeCart(webCart.Id);
    Test.stopTest();

    WebCart webCartTest = [SELECT Id, Name, Status FROM WebCart LIMIT 1];

    System.assertEquals('Closed', webCartTest.Status, 'Cart should be closed');
  }

  
  @IsTest
  static void getOPEProductCategTest() {
    Test.startTest();
    ProductCategory prodCategId = CartItemCtrl.getOPEProductCateg();
    Test.stopTest();

    System.assertNotEquals(null, prodCategId, 'Product Category Id Retrieved');
  }

  @IsTest
  static void updatePaymentMethodTest() {
    WebCart webCart = [SELECT Id, Name FROM WebCart LIMIT 1];

    Test.startTest();
    CartItemCtrl.updatePaymentMethod(webCart.Id, 'Pay Now');
    Test.stopTest();

    WebCart webCartTest = [SELECT Id, Name, Payment_Method__c FROM WebCart LIMIT 1];

    System.assertEquals('Pay Now', webCartTest.Payment_Method__c, 'Incorrect Payment Method');
  }

  @isTest
  static void getWebCartExternalIdTest(){
    WebCart webCart = [SELECT Id, Name, External_Id__c FROM WebCart LIMIT 1];

    Test.startTest();
    String webCartExtId = CartItemCtrl.getCartExternaId(webCart.Id);
    Test.stopTest();

    System.assert( webCartExtId != null, 'No External Id');
  }
}