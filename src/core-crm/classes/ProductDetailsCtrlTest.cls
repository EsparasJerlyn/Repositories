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
  private static final string studentRT = System.Label.RT_CourseConnection_Student;
  private static final String rtProdRequestActivity = System.Label.RT_ProductRequest_Activity;
  private static final Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
  private static final Id opeActProdReqRecType = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestActivity).getRecordTypeId();
  private static final Integer numberOfRecords = 100;  
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(ACCT_UNIV_DEP)
    .getRecordTypeId();
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
      Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(
        Name = 'test123',
        New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com'
      );
      insert customEmail;

      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for (Account account : accounts) {
        account.RecordTypeId = ACCT_UNIV_DEP_ID;
        account.Organization_Unit_Level__c = '2';
      }
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

  @isTest
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
  }
    
     @IsTest
     static void getQuestionsTest(){     
           User currUsr = [
          SELECT Id
          FROM User
          WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
          LIMIT 1
          ];        
         
          System.runAs(currUsr){     
               createRecord(opeActProdReqRecType); 
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;           
               Test.startTest();
               List<Related_Answer__c> relatedAnswerList = ProductDetailsCtrl.getQuestions(prodReqId); 
               Test.stopTest();
               system.assert(relatedAnswerList.isEmpty(),'Empty related answer');
          }      
     }    
    
     @IsTest
     static void addRegistrationTest(){   
      User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
      ];
         
          System.runAs(currUsr){     
               createRecord(opeActProdReqRecType); 
               String cOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Contact newContact = new Contact(FirstName = 'testqtest123', LastName = 'testqtest', Email = 'testqtest123@emailemail.com');  

               Id relatedQuestionnaireId = [SELECT Id FROM Questionnaire__c  LIMIT 1].Id;
               
               List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
               insert questionList;

               List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(5,relatedQuestionnaireId,questionList);
               insert relatedAnswers;
               List<ProductDetailsCtrl.FileUpload> fileLoadList = new List<ProductDetailsCtrl.FileUpload>();
               List<Answer__c> answerList = new List<Answer__c>();
               Answer__c newAnswer;
               ProductDetailsCtrl.FileUpload fileLoad = new ProductDetailsCtrl.FileUpload();
               for(Related_Answer__c relatedA: relatedAnswers){
                    newAnswer = new Answer__c(
                         Response__c = relatedA.Id,
                         Related_Answer__c = relatedA.Id
                    );
                    answerList.add(newAnswer);

                    fileLoad.Base64 = 'Test Content';
                    fileLoad.FileName = relatedA.Id;
                    fileLoad.RelatedAnswerId = relatedA.Id;

                    fileLoadList.add(fileLoad);
               }
               
               Test.startTest();
               ProductDetailsCtrl.addRegistration(newContact,cOfferingId,relatedAnswers,answerList,JSON.serialize(fileLoadList)); 
               Test.stopTest();
               system.assert(![SELECT Id FROM ContentVersion].isEmpty(), 'Document not created');
               system.assert(![SELECT Id FROM Answer__c].isEmpty(), 'Answer not created');
          }      
     } 
    
        private static void createRecord(String productRequestRecordType){
          User currUsr = [
          SELECT Id
          FROM User
          WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
          LIMIT 1
          ];
            
            System.runAs(currUsr){
               Id offeringId = null;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account account : accounts){
                    account.RecordTypeId = ACCT_UNIV_DEP_ID;
                    account.Organization_Unit_Level__c = '2';
                }
               insert accounts;
               
               List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
               for(Product_Request__c productRequest : productRequests){
                    productRequest.RecordTypeId = productRequestRecordType;
               }
               insert productRequests;

               List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
               insert courses;

               List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
               insert terms;

               List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
               insert courseOfferings;

               offeringId = courseOfferings[0].Id;          

               List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
               for(Integer i =0;i<contacts.size();i++){
                    contacts[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
                }
               insert contacts;

               List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
               for(Contact contact : contacts){
                    hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                    student.hed__Contact__c = contact.Id;
                    student.RecordTypeId = studentRecTypeId;
                    student.Paid_in_Full__c = 'Yes';
                    student.hed__Course_Offering__c = offeringId;
                    students.add(student);
               }
               insert students;

               Questionnaire__c questionnaire = new Questionnaire__c();
               questionnaire.Questionnaire_Type__c = 'Application Questions';
               questionnaire.Parent_Record_ID__c = productRequests[0].Id;
               insert questionnaire;
                    
               List<Questionnaire_Response_Summary__c> questionnaireResponseList = new List<Questionnaire_Response_Summary__c>();
               for(Contact contact : contacts){
                    Questionnaire_Response_Summary__c questionResp = new Questionnaire_Response_Summary__c();
                    questionResp.Contact__c = contact.Id;
                    questionResp.Registration_Status__c = 'Confirmed';       
                    questionResp.Questionnaire__c =  questionnaire.Id;          
                    questionResp.Course_Offering__c = offeringId;
                    questionnaireResponseList.add(questionResp);
               }
               insert questionnaireResponseList;

               Related_Answer__c mewRelatedAnswer = new Related_Answer__c(Questionnaire__c = questionnaire.Id);
               insert mewRelatedAnswer;
          }
     }  
    
}