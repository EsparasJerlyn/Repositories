/**
 * @description Test Class for ManageRegistrationSectionCtrl
 * @see ../class/ManageRegistrationSectionCtrl
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 08, 2022     | DEPP-1482            | Created file                 | 
      | eccarius.karl.munoz       | February 28, 2022     | DEPP-1819            | Removed handling for Program | 
      |                           |                       |                      | Plan due to program offering | 
      |                           |                       |                      | id removal.                  | 
      | rhea.b.torres             | August 1, 2022        | DEPP-3594            | testing for registered email |
      | john.m.tambasen           | August, 16 2022       | DEPP-1946            | Single/Group Coaching changes|
      | Tiffany.Zhang             | Aug 22, 2022          | DEPP-3486            | Add test cladd for manage    |
      |                           |                       |                      | registration                 |
      | eccarius.karl.munoz       | August 31, 2022       | DEPP-3754            | Updated add registration test| 
 */
@isTest
public with sharing class ManageRegistrationSectionCtrlTest{

     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
     private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
     private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
     private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
     private static final Integer NUMBER_OF_RECORDS = 100;

     @testSetup
     static void makeData(){
          BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
          insert bypass;
          TestDataFactory.generateTestUsers();
          Test.startTest();
          createRecord(RT_ACTIVITY_ID);
          Test.stopTest();
     }

     @isTest
     static void getRegisteredEmailTest(){        
          System.runAs(TestDataFactory.getProgramAdminUser()){
               Test.startTest();
               Contact con1 = [SELECT Id, Registered_Email__c FROM Contact WHERE Registered_Email__c != null LIMIT 1];
               Contact con2 = [SELECT Id, Registered_Email__c FROM Contact WHERE Registered_Email__c = null LIMIT 1];

               String registeredEmail1 = ManageRegistrationSectionCtrl.getRegisteredEmail(con1.Id);
               String registeredEmail2 = ManageRegistrationSectionCtrl.getRegisteredEmail(con2.Id);

               System.assert(String.isNotBlank(registeredEmail1), 'Registered Email is empty');
               System.assert(registeredEmail2==null, 'Registered Email is NOT empty'); 
               Test.stopTest();
          }      
     }

     @isTest
     static void getEmailOptionsTest(){
          User programUser = TestDataFactory.getProgramAdminUser();
          System.runAs(programUser){
               List<Contact> conList = new List<Contact>();
               Test.startTest();
               
               //Get Contact with no registered email
               List<Contact> conWithRegisteredEmail = [SELECT Id,
                                                  Registered_Email__c,
                                                  Email, 
                                                  QUT_Learner_Email__c, 
                                                  QUT_Staff_Email__c,
                                                  Work_Email__c 
                                             FROM Contact WHERE Registered_Email__c != null LIMIT 1];

               //Get Contact with no registered email
               List<Contact> conWithoutRegEmailList = [SELECT Id,
                                             Registered_Email__c,
                                             Email, 
                                             QUT_Learner_Email__c, 
                                             QUT_Staff_Email__c,
                                             Work_Email__c 
                                        FROM Contact WHERE Registered_Email__c = null 
                                        AND CreatedById =:programUser.Id LIMIT 1];
               conWithoutRegEmailList[0].QUT_Learner_Email__c = 'qutLearnerEmail@emailtest.com';
               conWithoutRegEmailList[0].QUT_Staff_Email__c = 'qutstaff@emailtest.com';
               conWithoutRegEmailList[0].Work_Email__c = 'work@emailtest.com';
               conWithoutRegEmailList[0].hed__Preferred_Email__c = 'Alternate Email';
               conWithoutRegEmailList[0].hed__AlternateEmail__c = 'test@email.com';
               update conWithoutRegEmailList;

               List<Map<String,String>> mapList1 = ManageRegistrationSectionCtrl.getEmailOptions(conWithoutRegEmailList[0].Id);
               List<Map<String,String>> mapList2 = ManageRegistrationSectionCtrl.getEmailOptions(conWithRegisteredEmail[0].Id);
               System.assert(!mapList1.isEmpty(), 'map is empty');
               System.assert(mapList2.isEmpty(), 'map is not empty');
               Test.stopTest();
          }
     }

     @isTest
     static void checkOfferingAvailabilityTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){               
               Test.startTest();
               Boolean isAvailable = ManageRegistrationSectionCtrl.checkOfferingAvailability([
                    SELECT Id 
                    FROM hed__Course_Offering__c 
                    WHERE Registration_End_Date__c = NULL 
                    OR Registration_End_Date__c < TODAY
                    LIMIT 1 ].Id);
               Test.stopTest();
               System.assert(!isAvailable,'Offering is available');
          }
     }

     @isTest
     static void getPaidInFullValuesTest(){        
          System.runAs(TestDataFactory.getProgramAdminUser()){               
               Test.startTest();
               List<String> paidInFullValues = ManageRegistrationSectionCtrl.getPaidInFullValues();
               Test.stopTest();
               System.assert(!paidInFullValues.isEmpty(), 'Paid in Full Values must not be empty.');
          }
     }

     @isTest
     static void getRegistrationStatusValuesTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getRegistrationStatusValues();
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Registration Status Values must not be empty.');
          }
     }

     @isTest
     static void getPricingValidationValuesTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getPricingValidationValues();
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Pricing Validation Values must not be empty.');
          }
     }

     @isTest
     static void getRegDetailsForNonProgPlanTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               String childRecordId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Test.startTest();
               List<ManageRegistrationSectionCtrl.ManageRegistrationDetails> registrationDetails = ManageRegistrationSectionCtrl.getRegistrations(childRecordId, false);
               Test.stopTest();
              System.assertEquals(NUMBER_OF_RECORDS*2, registrationDetails.size(), 'Incorrect number of records retrieved.');
          }
     }

     @isTest
     static void updateRegistrationTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               String studentId = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1].Id;
               String questionId = [SELECT Id FROM Questionnaire_Response_Summary__c LIMIT 1].Id;
               String regStatus= 'Confirmed';
               String paidInFull= 'No';
               String pricingValidation= 'Successful';
               Test.startTest();
               String updateReponse = ManageRegistrationSectionCtrl.updateRegistration(studentId, questionId, regStatus, paidInFull, pricingValidation, '', '');
               Test.stopTest();
               System.assertEquals('Success', updateReponse, 'Update of record failed.');
          }
     }

     @isTest
     static void getQuestionsTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               Test.startTest();
               List<Related_Answer__c> relatedAnswerList = ManageRegistrationSectionCtrl.getQuestions(prodReqId);
               Test.stopTest();
               system.assert(!relatedAnswerList.isEmpty(),'Empty related answer');
          }
     }

     @isTest
     static void getSearchedContactsTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               Test.startTest();
               List<Id> contactIds = new List<Id>();
               contactIds.add([SELECT Id FROM Contact Where Name LIKE :'Test%' AND Recordtype.DeveloperName = 'Person' LIMIT 1].Id);
               Test.setFixedSearchResults(contactIds);
               List<Map<String,String>> contactMap = ManageRegistrationSectionCtrl.getSearchedContacts('Test',new List<Id>());
               Test.stopTest();
               system.assert(!contactMap.isEmpty(),'Empty contact map');
          }
     }

     @isTest
     static void getPBEntriesTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               List<hed__Course_Offering__c> courseOfferings = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               Test.startTest();
               List<Map<String,String>> pbEntriesMap = ManageRegistrationSectionCtrl.getPBEntries(courseOfferings[0].Id, false);
               Test.stopTest();
               system.assert(!pbEntriesMap.isEmpty(),'Empty pricebook entries map');
          }
     }

     @isTest
     static void addRegistrationTest(){
          final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
          BypassTriggers__c bypass =[SELECT Id, Bypass__c FROM BypassTriggers__c WHERE Bypass__c = True LIMIT 1];
          bypass.Bypass__c = False;
          System.runAs(PORTAL_SYS_ADMIN){
               Account portalAccount = new Account(Name='TestAccount', OwnerId = PORTAL_SYS_ADMIN.Id);
               Database.insert(portalAccount);

               Contact learnerContact = new Contact(FirstName = 'learner', LastName = 'test', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com', Registered_Email__c ='learner@email.com', Birthdate = Date.newInstance(1991, 2, 17), MobilePhone ='012345');
               Contact newContact = new Contact(FirstName = 'testqtest', LastName = 'testqtest', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com', Registered_Email__c ='email@email.com', Birthdate = Date.newInstance(1990, 2, 17), MobilePhone ='012345');
               insert newContact;

               User portalUser = TestDataFactory.createPortalUserRecords(1, 'Corporate Partner User', newContact.Id).iterator().next();
               Database.insert(portalUser);

               WebStore testWebStore = new WebStore(
                    Name = 'Study',
                    DefaultLanguage = 'en_US'
               );
               insert testWebStore;

               WebCart cart = new WebCart(
                    Name = 'Cart',
                    AccountId = portalAccount.Id,
                    Status = 'Closed',
                    Status__c = 'Active',
                    WebStoreId = testWebStore.Id,
                    OwnerId = portalUser.Id
               );
               insert cart;

               CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                    CartId = cart.Id,
                    Name = 'Default Delivery'
               );
               insert cartDeliveryGroup;

               String cOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Id relatedQuestionnaireId = [SELECT Id FROM Questionnaire__c  LIMIT 1].Id;

               List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
               insert questionList;

               List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(5,relatedQuestionnaireId,questionList);
               insert relatedAnswers;
               List<ManageRegistrationSectionCtrl.FileUpload> fileLoadList = new List<ManageRegistrationSectionCtrl.FileUpload>();
               List<Answer__c> answerList = new List<Answer__c>();
               Answer__c newAnswer;
               ManageRegistrationSectionCtrl.FileUpload fileLoad = new ManageRegistrationSectionCtrl.FileUpload();
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

               Id pbeId;
               List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry LIMIT 1];
               for(PricebookEntry pbe : pbeList){ pbeId = pbe.Id; }

               Test.startTest();
               ManageRegistrationSectionCtrl.ManageRegistrationDetails wrapper = new ManageRegistrationSectionCtrl.ManageRegistrationDetails();
               update bypass;
               wrapper = ManageRegistrationSectionCtrl.addRegistration(learnerContact,cOfferingId,relatedAnswers,answerList,JSON.serialize(fileLoadList),false,pbeId, false, 10,null);
               List<ManageRegistrationSectionCtrl.ManageRegistrationDetails> registrationDetails = ManageRegistrationSectionCtrl.getRegistrations(cOfferingId, false);
               Test.stopTest();
               system.assert(![SELECT Id FROM ContentVersion].isEmpty(), 'Document not created');
               system.assert(![SELECT Id FROM Answer__c].isEmpty(), 'Answer not created');
               system.assert(String.isNotBlank(wrapper.paymentURL), 'Response is invalid');
          }
     }

     @isTest
     static void addRegistrationProceedNoInvoiceTest(){
          final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
          System.runAs(PORTAL_SYS_ADMIN){
               Account portalAccount = new Account(Name='TestAccount', OwnerId = PORTAL_SYS_ADMIN.Id);
               Database.insert(portalAccount);

               Contact learnerContact = new Contact(FirstName = 'learner', LastName = 'test', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com', Registered_Email__c ='learner@email.com', Birthdate = Date.newInstance(1991, 2, 17), MobilePhone ='012345');
               Contact newContact = new Contact(FirstName = 'testqtest', LastName = 'testqtest', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com',Registered_Email__c ='email@email.com', Birthdate = Date.newInstance(1990, 2, 17), MobilePhone ='012345');
               insert newContact;

               User portalUser = TestDataFactory.createPortalUserRecords(1, 'Corporate Partner User', newContact.Id).iterator().next();
               Database.insert(portalUser);

               WebStore testWebStore = new WebStore(
                    Name = 'Study',
                    DefaultLanguage = 'en_US'
               );
               insert testWebStore;

               WebCart cart = new WebCart(
                    Name = 'Cart',
                    AccountId = portalAccount.Id,
                    Status = 'Closed',
                    Status__c = 'Active',
                    WebStoreId = testWebStore.Id,
                    OwnerId = portalUser.Id
               );
               insert cart;

               CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                    CartId = cart.Id,
                    Name = 'Default Delivery'
               );
               insert cartDeliveryGroup;

               String cOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Id relatedQuestionnaireId = [SELECT Id FROM Questionnaire__c  LIMIT 1].Id;

               List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
               insert questionList;

               List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(5,relatedQuestionnaireId,questionList);
               insert relatedAnswers;
               List<ManageRegistrationSectionCtrl.FileUpload> fileLoadList = new List<ManageRegistrationSectionCtrl.FileUpload>();
               List<Answer__c> answerList = new List<Answer__c>();
               Answer__c newAnswer;
               ManageRegistrationSectionCtrl.FileUpload fileLoad = new ManageRegistrationSectionCtrl.FileUpload();
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

               Id pbeId;
               List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry LIMIT 1];
               for(PricebookEntry pbe : pbeList){ pbeId = pbe.Id; }

               Test.startTest();
               ManageRegistrationSectionCtrl.addRegistration(learnerContact,cOfferingId,relatedAnswers,answerList,JSON.serialize(fileLoadList),false,pbeId,true,0,null);
               Test.stopTest();
               system.assert(![SELECT Id FROM ContentVersion].isEmpty(), 'Document not created');
               system.assert(![SELECT Id FROM Answer__c].isEmpty(), 'Answer not created');
               system.assert(![SELECT Id FROM Contact].isEmpty(), 'Contact not created');
          }
     }

     @isTest
     static void getDiscountTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){

               //getDiscount(String selectedPBId, String standardPBId, String offeringId, Boolean prescribedProgram, String couponCode) {

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];

               Test.startTest();
               ManageRegistrationSectionCtrl.DiscountData discountData = new ManageRegistrationSectionCtrl.DiscountData();
               discountData = ManageRegistrationSectionCtrl.getDiscount(samplePbe[0].Id, samplePbe[0].Id, sampleOffering[0].Id, false, 'test123');
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     @istest
     static void getDiscountProductTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];

               //create promotion
               Promotion promotionTest = new Promotion(
                    Name = 'Test Promotion2',
                    IsActive = true
               );
               insert promotionTest;

               Coupon couponTest = new Coupon(
                    CouponCode = 'test124',
                    Status = 'Active',
                    StartDateTime = System.now() - 1,
                    EndDateTime = System.now() + 1,
                    PromotionId = promotionTest.Id
               );
               insert couponTest;

               PromotionTarget promotionTargetTest = new PromotionTarget(
                    TargetType ='Product',
                    AdjustmentType = 'PercentageDiscount',  
                    AdjustmentPercent = 50,
                    PromotionId = promotionTest.Id,
                    TargetId = sampleProduct[0].Id
               );
               insert promotionTargetTest;

               Test.startTest();
               ManageRegistrationSectionCtrl.DiscountData discountData = new ManageRegistrationSectionCtrl.DiscountData();
               discountData = ManageRegistrationSectionCtrl.getDiscount(samplePbe[0].Id, samplePbe[0].Id, sampleOffering[0].Id, false, 'test124');
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     @istest
     static void getDiscountProductCategoryTest(){
          System.runAs(TestDataFactory.getProgramAdminUser()){

               //get sample data
               List<Product2> sampleProduct = [SELECT Id, Name FROM Product2 ORDER BY NAME LIMIT 1];
               List<hed__Course_Offering__c> sampleOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<PricebookEntry> samplePbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :sampleProduct[0].Id LIMIT 1];

               WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
               insert testWebStore;
     
               ProductCatalog prodCatalog = new ProductCatalog(Name = 'CCE Catalog');
               insert prodCatalog;
     
               ProductCategory prodCategCB = new ProductCategory(
               Name = 'Test Category',
               CatalogId = prodCatalog.Id
               );
               insert prodCategCB;
     
               ProductCategory prodCategQLS = new ProductCategory(
                    Name = 'Test Category',
                    CatalogId = prodCatalog.Id
                    );
               insert prodCategQLS;

               //create promotion
               Promotion promotionTest = new Promotion(
                    Name = 'Test Promotion2',
                    IsActive = true
               );
               insert promotionTest;

               //create promotion
               Promotion_Product__c promotiontProductTest = new Promotion_Product__c(
                    IsActive__c = true,
                    Product__c = sampleProduct[0].Id,
                    Promotion__c = promotionTest.Id
               );
               insert promotiontProductTest;

               Coupon couponTest = new Coupon(
                    CouponCode = 'test124',
                    Status = 'Active',
                    StartDateTime = System.now() - 1,
                    EndDateTime = System.now() + 1,
                    PromotionId = promotionTest.Id
               );
               insert couponTest;

               PromotionTarget promotionTargetTest = new PromotionTarget(
                    TargetType ='ProductCategory',
                    AdjustmentType = 'PercentageDiscount',  
                    AdjustmentPercent = 50,
                    PromotionId = promotionTest.Id,
                    TargetId = prodCategCB.Id
               );
               insert promotionTargetTest;

               Test.startTest();
               ManageRegistrationSectionCtrl.DiscountData discountData = new ManageRegistrationSectionCtrl.DiscountData();
               discountData = ManageRegistrationSectionCtrl.getDiscount(samplePbe[0].Id, samplePbe[0].Id, sampleOffering[0].Id, false, 'test124');
               Test.stopTest();

               system.assertNotEquals(discountData.discount, Double.valueOf(0), 'Discount should not be 0');
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(TestDataFactory.getProgramAdminUser()){
               Id offeringId = null;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account account : accounts){
                    account.RecordTypeId = ACCT_UNIV_DEP_ID;
                    account.Organization_Unit_Level__c = '2';
                }
               insert accounts;

               Account act = new Account(Name = 'OPE Catalogue');
               insert act;

               List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
               for(Product_Request__c productRequest : productRequests){
                    productRequest.RecordTypeId = productRequestRecordType;
               }
               insert productRequests;

               List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
               insert courses;

               Pricebook2 priceBook;
               pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
               update pricebook;

               Product2 product = new Product2(Name = courses[0].Name, Course__c = courses[0].Id);
               insert product;

               PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, IsActive = true, Pricebook2Id = priceBook.Id, UnitPrice = 250.00);
               insert pbe;

               List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
               insert terms;

               List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
               insert courseOfferings;

               offeringId = courseOfferings[0].Id;

               // insert 100 Contact with Registered Email and 100 without Registered Email
               List<Contact> contacts = TestDataFactory.createTestContactRecords(NUMBER_OF_RECORDS*2);
               for(Integer i =0;i<NUMBER_OF_RECORDS;i++){
                    contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
               }
               insert contacts;

               List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
               for(Contact contact : contacts){
                    hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                    student.hed__Contact__c = contact.Id;
                    student.RecordTypeId = STUDENT_RT_ID;
                    student.Paid_in_Full__c = 'No';
                    student.Payment_Method__c = 'Invoice';
                    student.hed__Course_Offering__c = offeringId;
                    students.add(student);
               }
               insert students;

               Questionnaire__c questionnaire = new Questionnaire__c();
               questionnaire.Questionnaire_Type__c = 'Registration Questions';
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

               //create promotion
               Promotion promotionTest = new Promotion(
                    Name = 'Test Promotion',
                    IsActive = true
               );
               insert promotionTest;

               Coupon couponTest = new Coupon(
                    CouponCode = 'test123',
                    Status = 'Active',
                    StartDateTime = System.now() - 1,
                    EndDateTime = System.now() + 1,
                    PromotionId = promotionTest.Id
               );
               insert couponTest;

               PromotionTarget promotionTargetTest = new PromotionTarget(
                    TargetType ='Transaction',
                    AdjustmentType = 'PercentageDiscount',  
                    AdjustmentPercent = 50,
                    PromotionId = promotionTest.Id
               );
               insert promotionTargetTest;
               
          }
     } 
}