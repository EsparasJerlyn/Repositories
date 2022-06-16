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
      |                           |                       |                      |                              |
 */
@isTest(SeeAllData=false)
public with sharing class ManageRegistrationSectionCtrlTest{

     private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
     private static final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
     private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
     private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;     
     private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
     private static final Integer NUMBER_OF_RECORDS = 100;

     @IsTest
     static void getPaidInFullValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> paidInFullValues = ManageRegistrationSectionCtrl.getPaidInFullValues();                 
               Test.stopTest();
               System.assert(!paidInFullValues.isEmpty(), 'Paid in Full Values must not be empty.');
          }      
     } 
     
     @IsTest
     static void getRegistrationStatusValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getRegistrationStatusValues();      
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Registration Status Values must not be empty.');
          }      
     }

     @IsTest
     static void getPricingValidationValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getPricingValidationValues();      
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Pricing Validation Values must not be empty.');
          }      
     }

     @IsTest
     static void getRegDetailsForNonProgPlanTest(){        
          System.runAs(currentUser){               
               createRecord(RT_ACTIVITY_ID);  
               String childRecordId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;             
               Test.startTest();
               List<ManageRegistrationSectionCtrl.ManageRegistrationDetails> registrationDetails = ManageRegistrationSectionCtrl.getRegistrations(childRecordId, false);      
               Test.stopTest();
              System.assertEquals(NUMBER_OF_RECORDS, registrationDetails.size(), 'Incorrect number of records retrieved.');
          }      
     }    

     @IsTest
     static void updateRegistrationTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID);    
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
     
     @IsTest
     static void getQuestionsTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID); 
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;           
               Test.startTest();
               List<Related_Answer__c> relatedAnswerList = ManageRegistrationSectionCtrl.getQuestions(prodReqId); 
               Test.stopTest();
               system.assert(!relatedAnswerList.isEmpty(),'Empty related answer');
          }      
     }  

     @IsTest
     static void getSearchedContactsTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID);       
               Test.startTest();
               List<Map<String,String>> contactMap = ManageRegistrationSectionCtrl.getSearchedContacts('Test',new List<Id>()); 
               Test.stopTest();
               system.assert(!contactMap.isEmpty(),'Empty contact map');
          }      
     }  

     @IsTest
     static void getPBEntriesTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID);    
               List<hed__Course_Offering__c> courseOfferings = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];   
               Test.startTest();
               List<Map<String,String>> pbEntriesMap = ManageRegistrationSectionCtrl.getPBEntries(courseOfferings[0].Id, false); 
               Test.stopTest();
               system.assert(!pbEntriesMap.isEmpty(),'Empty pricebook entries map');
          }      
     } 

     @IsTest
     static void addRegistrationTest(){  
          System.runAs(PORTAL_SYS_ADMIN){   
               Account portalAccount = new Account(Name='TestAccount', OwnerId = PORTAL_SYS_ADMIN.Id); 
               Database.insert(portalAccount);

               Contact newContact = new Contact(FirstName = 'testqtest', LastName = 'testqtest', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com', Birthdate = Date.newInstance(1990, 2, 17), MobilePhone ='012345');  
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

               createRecord(RT_ACTIVITY_ID); 
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
               String resp = ManageRegistrationSectionCtrl.addRegistration(newContact,cOfferingId,relatedAnswers,answerList,JSON.serialize(fileLoadList),false,pbeId); 

               Test.stopTest();
               system.assert(![SELECT Id FROM ContentVersion].isEmpty(), 'Document not created');
               system.assert(![SELECT Id FROM Answer__c].isEmpty(), 'Answer not created');
               system.assert(String.isNotBlank(resp), 'Response is invalid');
          }      
     } 


     private static void createRecord(String productRequestRecordType){
          System.runAs(currentUser){
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

               List<Contact> contacts = TestDataFactory.createTestContactRecords(NUMBER_OF_RECORDS);
               for(Integer i =0;i<contacts.size();i++){
                    contacts[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
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
          }
     } 
}