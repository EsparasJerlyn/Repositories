/**
 * @description Test Class for GroupBookingFormCtrl Test
 * @see ../lwc/GroupBookingFormCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | June 20, 2022         | DEPP-3141            | Created file                 |
      | john.m.tambasen           | September 23, 2022    | DEPP-4367            | birthdate validation         |
 */
@isTest
public with sharing class GroupBookingFormCtrlTest {

  private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

  @testSetup
  static void setupMethod() {
    Test.startTest();
    TestDataFactoryUser.generateUserSystemAdministrator();
    Test.stopTest();
    //create account

    User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
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

    ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
    insert prodCatalog;

    ProductCategory prodCateg = new ProductCategory(
      Name = 'Products',
      CatalogId = prodCatalog.Id
    );
    insert prodCateg;
    
  }

  

  @isTest
  static void saveBookingTest(){
    System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
      Test.startTest();
      Contact newContact = new Contact(
        Email ='testemail12@email.com', 
        FirstName ='tetfirstnam2e', 
        lastname ='lastnametes2tda', 
        Birthdate = Date.Today().addYears(-15),
        hed__AlternateEmail__c = 'testemail12@email.com',
        hed__Preferred_Email__c = 'Alternate Email'
      );
      insert newContact;

      Contact newContact1 = new Contact(  
        Registered_Email__c ='testemail@email1.com', 
        FirstName ='tetfirstname', 
        lastname ='lastnametestda', 
        Birthdate = Date.Today().addYears(-15),
        hed__AlternateEmail__c = 'testemail@email1.com',
        hed__Preferred_Email__c = 'Alternate Email'
      );

      Map<String,Contact> participantsMap = new Map<String, Contact>();
      GroupBookingFormCtrl.FileUpload fileLoad = new GroupBookingFormCtrl.FileUpload();
      List<GroupBookingFormCtrl.FileUpload> fileLoadList = new List<GroupBookingFormCtrl.FileUpload>();
      Map<String,String> fileUploadMap = new Map<String,String>();
      participantsMap.put('PARTICIPANT 1',newContact1);

      String courseOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
      List<Related_Answer__c> relatedAnswerList = [SELECT Id,Questionnaire__c FROM Related_Answer__c LIMIT 2];
      Map<String,List<Answer__c>> answerMap = new Map<String,List<Answer__c>>();
      List<Answer__c> answerList = new List<Answer__c>();
      Answer__c newAnswer;
      for(Related_Answer__c relatedA: relatedAnswerList){
          newAnswer = new Answer__c(
                  Response__c = relatedA.Id,
                  Related_Answer__c = relatedA.Id
          );
          answerList.add(newAnswer);

          fileLoad = new GroupBookingFormCtrl.FileUpload();
          fileLoad.Base64 = 'Test Content';
          fileLoad.FileName = relatedA.Id;
          fileLoad.RelatedAnswerId = relatedA.Id;
          fileLoadList.add(fileLoad);
      }
      answerMap.put('PARTICIPANT 1', answerList);
      fileUploadMap.put('PARTICIPANT 1',JSON.serialize(fileLoadList));

      GroupBookingFormCtrl.SaveBookingDetails details = new GroupBookingFormCtrl.SaveBookingDetails();
      details.participants = participantsMap;
      details.offeringId = courseOfferingId;
      details.relatedAnswer = relatedAnswerList;
      details.answerMap = answerMap;
      details.fileUpload = fileUploadMap;
      details.isPrescribed = false;
      GroupBookingFormCtrl.saveBooking(details);

      Test.stopTest();

      System.assert(![SELECT Id FROM Contact LIMIT 1].isEmpty(),'No contact created');
    }
  }

  @isTest
  static void addCartItemsTest(){
    System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
      Product2 product = [SELECT Id, Name FROM Product2 LIMIT 1];
      hed__Course_Offering__c offering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
      PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry Limit 1];
      WebCart cart = [SELECT Id, OwnerId FROM WebCart WHERE Status = 'Active' LIMIT 1];
      List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];

      Test.startTest();

      GroupBookingFormCtrl.CartItemDetails details = new GroupBookingFormCtrl.CartItemDetails();
      details.productId = product.Id;
      details.productName = product.Name;
      details.isPrescribed = false;
      details.offeringId = offering.Id;
      details.pricebookEntryId = pbEntry.Id;
      details.pricebookUnitPrice = pbEntry.UnitPrice;
      details.contacts = contacts;
      details.cartId = cart.Id;
      GroupBookingFormCtrl.addCartItems(details);

      Test.stopTest();
      System.assert(![SELECT Id FROM CartItem WHERE Contact__c =: contacts[0].Id].isEmpty(),'no cartitems linked to contact created');
    }
  }


  @isTest
  static void removeCartItemsTest(){
    System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
      CartItem cartItem = [SELECT Id, Cart.OwnerId FROM CartItem WHERE Cart.Status = 'Active' LIMIT 1];
      Id ownerId = cartItem.Cart.OwnerId;
      Id cartItemId = cartItem.Id;
      Test.startTest();

      GroupBookingFormCtrl.removeCartItems(ownerId);

      Test.stopTest();
      List<CartItem> deletedCartItems = [SELECT Id, Cart.OwnerId FROM CartItem WHERE Id=: cartItemId];
      System.assert(deletedCartItems.isEmpty(),'no cartitems deleted');
    }
  }

  @isTest
  static void getAvailableSeatsTest(){
    System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
      String courseOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
      Test.startTest();
      Decimal availableSeats = GroupBookingFormCtrl.getAvailableSeats(courseOfferingId, false);
      Test.stopTest();
      System.assert(availableSeats > 0,'No available seats');
    }
  }
}