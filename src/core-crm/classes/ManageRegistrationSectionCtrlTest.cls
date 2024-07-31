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
          Test.startTest();
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
          Test.stopTest();
          createRecord(RT_ACTIVITY_ID);
     }

     @isTest
     static void getRegisteredEmailTest(){        
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
          User programUser = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
          System.runAs(programUser){
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
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){               
               Test.startTest();
               Boolean isAvailable = ManageRegistrationSectionCtrl.checkOfferingAvailability([
                    SELECT Id 
                    FROM hed__Course_Offering__c 
                    WHERE Registration_End_Date__c = NULL 
                    OR Registration_End_Date__c < TODAY
                    LIMIT 1 ].Id);
               Test.stopTest();
               System.assert(isAvailable,'Offering is not available');
          }
     }

     @isTest
     static void getPaidInFullValuesTest(){        
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){               
               Test.startTest();
               List<String> paidInFullValues = ManageRegistrationSectionCtrl.getPaidInFullValues();
               Test.stopTest();
               System.assert(!paidInFullValues.isEmpty(), 'Paid in Full Values must not be empty.');
          }
     }

     @isTest
     static void getRegistrationStatusValuesTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getRegistrationStatusValues();
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Registration Status Values must not be empty.');
          }
     }

     @isTest
     static void getPricingValidationValuesTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getPricingValidationValues();
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Pricing Validation Values must not be empty.');
          }
     }

     @isTest
     static void getQuestionsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               Test.startTest();
               List<Related_Answer__c> relatedAnswerList = ManageRegistrationSectionCtrl.getQuestions(prodReqId);
               Test.stopTest();
               system.assert(!relatedAnswerList.isEmpty(),'Empty related answer');
          }
     }

     @isTest
     static void getSearchedContactsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               List<hed__Course_Offering__c> courseOfferings = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               Test.startTest();
               List<Map<String,String>> pbEntriesMap = ManageRegistrationSectionCtrl.getPBEntries(courseOfferings[0].Id, false);
               Test.stopTest();
               system.assert(!pbEntriesMap.isEmpty(),'Empty pricebook entries map');
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Id offeringId = null;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account account : accounts){
                    account.RecordTypeId = ACCT_UNIV_DEP_ID;
                    account.Organization_Unit_Level__c = '2';
                }
               insert accounts;

               Account act = new Account(Name = 'QUT Experiencee');
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